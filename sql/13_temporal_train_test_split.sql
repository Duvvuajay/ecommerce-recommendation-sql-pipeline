-- ==============================================================================
-- Module 13: Chronological Training and Test Datasets (Time-Aware Split)
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @eval_cutoff = COALESCE(@eval_cutoff, NOW());
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));

-- ------------------------------------------------------------------------------
-- 1. CHRONOLOGICAL TRAINING DATASET (Historical Features & Interactions)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS train_interactions;

CREATE TABLE train_interactions AS
SELECT
    user_id,
    product_id,
    interaction_time,
    behavior,
    feedback_weight,
    feedback_type,
    'TRAIN' AS dataset_split
FROM interaction_events
WHERE interaction_time >= @window_start
  AND interaction_time <= @train_cutoff;

CREATE INDEX idx_train_user_prod ON train_interactions (user_id, product_id);
CREATE INDEX idx_train_time ON train_interactions (interaction_time);

-- ------------------------------------------------------------------------------
-- 2. CHRONOLOGICAL TEST DATASET (Held-Out Future Ground Truth)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS test_interactions;

CREATE TABLE test_interactions AS
SELECT
    user_id,
    product_id,
    interaction_time,
    behavior,
    feedback_weight,
    feedback_type,
    'TEST_HELD_OUT' AS dataset_split
FROM interaction_events
WHERE interaction_time > @train_cutoff
  AND interaction_time <= @eval_cutoff;

CREATE INDEX idx_test_user_prod ON test_interactions (user_id, product_id);
CREATE INDEX idx_test_time ON test_interactions (interaction_time);

-- ------------------------------------------------------------------------------
-- 3. HELD-OUT RELEVANT GROUND TRUTH ITEMS (Positives for Metric Computation)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS test_ground_truth_relevant;

CREATE TABLE test_ground_truth_relevant AS
SELECT
    user_id,
    product_id,
    COUNT(*) AS test_interactions_count,
    SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) AS test_purchases,
    SUM(CASE WHEN behavior IN ('click', 'view', 'add_to_cart') THEN 1 ELSE 0 END) AS test_engagements,
    ROUND(SUM(feedback_weight), 2) AS test_implicit_score,
    MIN(interaction_time) AS first_test_interaction,
    1 AS is_relevant
FROM test_interactions
WHERE feedback_type = 'positive'
GROUP BY user_id, product_id;

ALTER TABLE test_ground_truth_relevant ADD PRIMARY KEY (user_id, product_id);

-- Verification: Chronological Split Boundaries and Metrics
SELECT
    'TRAIN' AS split_name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS distinct_users,
    COUNT(DISTINCT product_id) AS distinct_products,
    MIN(interaction_time) AS min_timestamp,
    MAX(interaction_time) AS max_timestamp
FROM train_interactions
UNION ALL
SELECT
    'TEST',
    COUNT(*),
    COUNT(DISTINCT user_id),
    COUNT(DISTINCT product_id),
    MIN(interaction_time),
    MAX(interaction_time)
FROM test_interactions;
