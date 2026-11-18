-- ==============================================================================
-- Module 12: Deterministic Negative Sampling Pipeline
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @eval_cutoff = COALESCE(@eval_cutoff, NOW());
SET @negatives_per_user = 5; -- Configurable negative sampling ratio
SET @sampling_seed = 'RECOMMENDER_SEED_2026';

-- ------------------------------------------------------------------------------
-- NEGATIVE SAMPLING POOL
-- ------------------------------------------------------------------------------
-- Candidates must:
-- 1. Be eligible available items from recommendation_candidates (stock > 0 at cutoff).
-- 2. NOT have been interacted with in the historical training period (user_item_interactions).
-- 3. NOT be a held-out ground truth item in the future test evaluation period (data leakage prevention).
-- 4. Be sampled deterministically using a cryptographic hash rank to guarantee reproducibility.

DROP TABLE IF EXISTS negative_sampling_candidates;

CREATE TABLE negative_sampling_candidates AS
WITH held_out_future_test_items AS (
    -- Positive engagement during future test period (must NEVER be sampled as negative)
    SELECT DISTINCT
        user_id,
        product_id
    FROM interaction_events
    WHERE interaction_time > @train_cutoff
      AND interaction_time <= @eval_cutoff
      AND feedback_type = 'positive'
),
ranked_unobserved_candidates AS (
    SELECT
        rc.user_id,
        rc.product_id,
        rc.category,
        rc.price,
        rc.available_stock_at_cutoff,
        CAST(@train_cutoff AS DATETIME) AS prediction_cutoff_time,
        
        -- Deterministic pseudo-random rank based on user, product, and fixed seed
        ROW_NUMBER() OVER (
            PARTITION BY rc.user_id
            ORDER BY MD5(CONCAT(rc.user_id, ':', rc.product_id, ':', @sampling_seed))
        ) AS sample_rank

    FROM recommendation_candidates rc
    -- Exclude items with observed positive training interactions
    LEFT JOIN user_item_interactions ui
        ON rc.user_id = ui.user_id
       AND rc.product_id = ui.product_id
       AND ui.interaction_score > 0
    -- Exclude held-out future evaluation ground-truth positives
    LEFT JOIN held_out_future_test_items hti
        ON rc.user_id = hti.user_id
       AND rc.product_id = hti.product_id
    WHERE ui.product_id IS NULL   -- Unobserved in historical training
      AND hti.product_id IS NULL  -- Not a future test positive
)
SELECT
    user_id,
    product_id,
    category,
    price,
    available_stock_at_cutoff,
    prediction_cutoff_time,
    sample_rank,
    'SAMPLED_UNOBSERVED_NEGATIVE' AS feedback_classification
FROM ranked_unobserved_candidates
WHERE sample_rank <= @negatives_per_user;

ALTER TABLE negative_sampling_candidates ADD PRIMARY KEY (user_id, product_id);
CREATE INDEX idx_neg_sample_user ON negative_sampling_candidates (user_id);

-- Verification: Sampled Negatives Summary
SELECT
    feedback_classification,
    COUNT(*) AS total_negative_samples,
    COUNT(DISTINCT user_id) AS distinct_users_covered,
    COUNT(DISTINCT product_id) AS distinct_products_sampled,
    ROUND(COUNT(*) / COUNT(DISTINCT user_id), 1) AS avg_samples_per_user
FROM negative_sampling_candidates
GROUP BY feedback_classification;
