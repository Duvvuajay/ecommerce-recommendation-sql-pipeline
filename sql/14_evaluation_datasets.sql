-- ==============================================================================
-- Module 14: Recommendation Evaluation Benchmark Datasets
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @eval_cutoff = COALESCE(@eval_cutoff, NOW());

-- ------------------------------------------------------------------------------
-- UNIFIED EVALUATION BENCHMARK TABLE
-- ------------------------------------------------------------------------------
-- For each evaluating user, combines:
-- 1. Held-Out Ground Truth Positives (is_relevant = 1) from test_ground_truth_relevant.
-- 2. Sampled Negative Candidates (is_relevant = 0) from negative_sampling_candidates.
-- This formats the dataset directly for ranking evaluations (Hit Rate@K, NDCG@K, Precision@K).

DROP TABLE IF EXISTS evaluation_ranking_dataset;

CREATE TABLE evaluation_ranking_dataset AS
-- 1. Ground Truth Positives in Evaluation Window
SELECT
    gtr.user_id,
    gtr.product_id,
    p.category,
    p.price,
    gtr.test_purchases,
    gtr.test_engagements,
    gtr.test_implicit_score,
    1 AS is_relevant,
    'HELD_OUT_POSITIVE' AS evaluation_label,
    CAST(@train_cutoff AS DATETIME) AS evaluation_cutoff_time
FROM test_ground_truth_relevant gtr
JOIN products p ON gtr.product_id = p.product_id

UNION ALL

-- 2. Contrastive Negative Candidates
SELECT
    nsc.user_id,
    nsc.product_id,
    nsc.category,
    nsc.price,
    0 AS test_purchases,
    0 AS test_engagements,
    0.00 AS test_implicit_score,
    0 AS is_relevant,
    'SAMPLED_NEGATIVE' AS evaluation_label,
    CAST(@train_cutoff AS DATETIME) AS evaluation_cutoff_time
FROM negative_sampling_candidates nsc;

ALTER TABLE evaluation_ranking_dataset ADD PRIMARY KEY (user_id, product_id);
CREATE INDEX idx_eval_user_rel ON evaluation_ranking_dataset (user_id, is_relevant);

-- ------------------------------------------------------------------------------
-- USER-LEVEL EVALUATION CANDIDATE SET SIZES
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS evaluation_user_summary;

CREATE TABLE evaluation_user_summary AS
SELECT
    user_id,
    COUNT(*) AS total_evaluation_candidates,
    SUM(CASE WHEN is_relevant = 1 THEN 1 ELSE 0 END) AS held_out_relevant_items,
    SUM(CASE WHEN is_relevant = 0 THEN 1 ELSE 0 END) AS sampled_negative_items,
    ROUND(SUM(CASE WHEN is_relevant = 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS base_hit_opportunity_ratio
FROM evaluation_ranking_dataset
GROUP BY user_id;

ALTER TABLE evaluation_user_summary ADD PRIMARY KEY (user_id);

-- Evaluation Setup Audit
SELECT
    COUNT(DISTINCT user_id) AS total_evaluated_users,
    SUM(held_out_relevant_items) AS total_held_out_positives,
    SUM(sampled_negative_items) AS total_negative_distractors,
    ROUND(AVG(total_evaluation_candidates), 1) AS avg_eval_pool_size_per_user
FROM evaluation_user_summary;
