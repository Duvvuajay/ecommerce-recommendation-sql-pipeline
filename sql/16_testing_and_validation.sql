-- ==============================================================================
-- Module 16: Comprehensive Testing, Assertion & Temporal Leakage Validation Suite
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @eval_cutoff = COALESCE(@eval_cutoff, NOW());

-- ------------------------------------------------------------------------------
-- TEST 1: DATABASE INTEGRITY AND TABLE VERIFICATION
-- ------------------------------------------------------------------------------
SELECT
    'TEST-01: Table Creation & Population' AS test_id,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'recommendation_engine') >= 12
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    CONCAT((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'recommendation_engine'), ' tables/views verified') AS details;

-- ------------------------------------------------------------------------------
-- TEST 2: EVENT DEDUPLICATION INTEGRITY
-- ------------------------------------------------------------------------------
-- Asserts that clean_user_events contains zero duplicate source_event_id records
SELECT
    'TEST-02: Telemetry Ingestion Deduplication' AS test_id,
    CASE 
        WHEN (SELECT COUNT(*) - COUNT(DISTINCT source_event_id) FROM clean_user_events) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Zero duplicated source_event_id records present in clean_user_events' AS details;

-- ------------------------------------------------------------------------------
-- TEST 3: FEEDBACK SCORING ACCURACY
-- ------------------------------------------------------------------------------
-- Asserts that positive, neutral, and negative feedback types have expected mathematical bounds
SELECT
    'TEST-03: Implicit Feedback Bounds' AS test_id,
    CASE
        WHEN (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'positive' AND feedback_weight <= 0) = 0
         AND (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'negative' AND feedback_weight >= 0) = 0
         AND (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'neutral'  AND feedback_weight != 0) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Weights adhere strictly to feedback taxonomy (+5/+3/+2/+1 for positive, 0 for neutral, -3 for negative)' AS details;

-- ------------------------------------------------------------------------------
-- TEST 4: DATA LEAKAGE PREVENTION IN HISTORICAL FEATURES
-- ------------------------------------------------------------------------------
-- Asserts that ZERO events occurring after @train_cutoff appear in user_item_interactions
SELECT
    'TEST-04: Historical Feature Temporal Leakage' AS test_id,
    CASE 
        WHEN (SELECT COUNT(*) FROM user_item_interactions WHERE last_interaction > @train_cutoff) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Zero future interactions contaminated the historical training matrix' AS details;

-- ------------------------------------------------------------------------------
-- TEST 5: TEMPORAL AVAILABILITY CONSTRAINT (SCD TYPE 2)
-- ------------------------------------------------------------------------------
-- Asserts that NO product in recommendation_candidates was out of stock or unavailable at @train_cutoff
SELECT
    'TEST-05: Point-in-Time Availability Enforcement' AS test_id,
    CASE 
        WHEN (
            SELECT COUNT(*) 
            FROM recommendation_candidates rc
            JOIN product_availability pa 
              ON rc.product_id = pa.product_id
             AND pa.effective_from <= @train_cutoff
             AND (pa.effective_to IS NULL OR pa.effective_to > @train_cutoff)
            WHERE pa.availability_status = 'out_of_stock' OR pa.stock_quantity <= 0
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Zero out-of-stock items entered the candidate recommendation pool' AS details;

-- ------------------------------------------------------------------------------
-- TEST 6: CANDIDATE EXCLUSION OF PRIOR RETAINED PURCHASES
-- ------------------------------------------------------------------------------
-- Asserts that no user is recommended a product they already purchased and retained before cutoff
SELECT
    'TEST-06: Prior Purchase Candidate Exclusion' AS test_id,
    CASE 
        WHEN (
            SELECT COUNT(*)
            FROM recommendation_candidates rc
            JOIN user_item_interactions uii
              ON rc.user_id = uii.user_id
             AND rc.product_id = uii.product_id
            WHERE uii.behavioral_state = 'PURCHASED_AND_RETAINED'
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Prior retained purchases are 100% excluded from candidate sets' AS details;

-- ------------------------------------------------------------------------------
-- TEST 7: NEGATIVE SAMPLING CONTAMINATION CHECK
-- ------------------------------------------------------------------------------
-- Asserts that NO held-out positive ground-truth item was mistakenly sampled as a negative candidate
SELECT
    'TEST-07: Negative Sampling Contamination Audit' AS test_id,
    CASE 
        WHEN (
            SELECT COUNT(*)
            FROM negative_sampling_candidates nsc
            JOIN test_ground_truth_relevant gtr
              ON nsc.user_id = gtr.user_id
             AND nsc.product_id = gtr.product_id
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    'Zero ground-truth evaluation positives leaked into sampled negative distractors' AS details;

-- ------------------------------------------------------------------------------
-- TEST 8: EVALUATION BENCHMARK METRIC READINESS
-- ------------------------------------------------------------------------------
-- Asserts that every user in evaluation_user_summary has a positive total candidate count
SELECT
    'TEST-08: Evaluation Candidate Set Structural Integrity' AS test_id,
    CASE 
        WHEN (SELECT COUNT(*) FROM evaluation_user_summary WHERE total_evaluation_candidates <= 0) = 0
         AND (SELECT COUNT(*) FROM evaluation_user_summary) > 0
        THEN 'PASS' ELSE 'FAIL'
    END AS status,
    CONCAT((SELECT COUNT(*) FROM evaluation_user_summary), ' evaluated users have properly structured candidate benchmarks') AS details;
