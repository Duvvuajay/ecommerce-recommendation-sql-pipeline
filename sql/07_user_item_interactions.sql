-- ==============================================================================
-- Module 07: User-Item Interaction Matrix & Behavioral Segmentation
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- CONFIGURABLE TIME WINDOW PARAMETERS
-- ------------------------------------------------------------------------------
-- Default: 30-day lookback ending at the training cutoff (7 days ago)
SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));

-- ------------------------------------------------------------------------------
-- USER-ITEM INTERACTION MATRIX
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS user_item_interactions;

CREATE TABLE user_item_interactions AS
SELECT
    user_id,
    product_id,
    COUNT(*) AS total_interactions,
    
    -- Specific Event Frequency Counters
    SUM(CASE WHEN behavior = 'impression'  THEN 1 ELSE 0 END) AS impression_count,
    SUM(CASE WHEN behavior = 'view'        THEN 1 ELSE 0 END) AS view_count,
    SUM(CASE WHEN behavior = 'click'       THEN 1 ELSE 0 END) AS click_count,
    SUM(CASE WHEN behavior = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_count,
    SUM(CASE WHEN behavior = 'wishlist'    THEN 1 ELSE 0 END) AS wishlist_count,
    SUM(CASE WHEN behavior = 'purchase'    THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN behavior = 'return'      THEN 1 ELSE 0 END) AS return_count,

    -- Sentiment Aggregations
    SUM(CASE WHEN feedback_type = 'positive' THEN 1 ELSE 0 END) AS positive_interactions,
    SUM(CASE WHEN feedback_type = 'negative' THEN 1 ELSE 0 END) AS negative_interactions,
    SUM(CASE WHEN feedback_type = 'neutral'  THEN 1 ELSE 0 END) AS neutral_interactions,

    -- Cumulative Implicit Feedback Score
    ROUND(SUM(feedback_weight), 2) AS interaction_score,

    -- Temporal Features
    MIN(interaction_time) AS first_interaction,
    MAX(interaction_time) AS last_interaction,
    ROUND(DATEDIFF(@train_cutoff, MAX(interaction_time)), 1) AS recency_days_at_cutoff,

    -- Behavioral State Categorization (Task 7 Requirement)
    CASE
        WHEN SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) > SUM(CASE WHEN behavior = 'return' THEN 1 ELSE 0 END)
            THEN 'PURCHASED_AND_RETAINED'
        WHEN SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) > 0 AND SUM(CASE WHEN behavior = 'return' THEN 1 ELSE 0 END) >= SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END)
            THEN 'PURCHASED_AND_RETURNED'
        WHEN SUM(CASE WHEN behavior = 'add_to_cart' THEN 1 ELSE 0 END) > 0 AND SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) = 0
            THEN 'CART_ABANDONED'
        WHEN (SUM(CASE WHEN behavior = 'view' THEN 1 ELSE 0 END) > 0 OR SUM(CASE WHEN behavior = 'click' THEN 1 ELSE 0 END) > 0) 
             AND SUM(CASE WHEN behavior = 'add_to_cart' THEN 1 ELSE 0 END) = 0 AND SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) = 0
            THEN 'VIEWED_ONLY'
        WHEN SUM(CASE WHEN behavior = 'impression' THEN 1 ELSE 0 END) > 0
            THEN 'EXPOSED_ONLY'
        ELSE 'OTHER'
    END AS behavioral_state

FROM interaction_events
WHERE interaction_time >= @window_start
  AND interaction_time <= @train_cutoff
GROUP BY user_id, product_id;

-- Primary Key and Indexing
ALTER TABLE user_item_interactions ADD PRIMARY KEY (user_id, product_id);
CREATE INDEX idx_user_item_score ON user_item_interactions (interaction_score DESC);
CREATE INDEX idx_user_item_state ON user_item_interactions (behavioral_state);

-- Verification: Behavioral State Distribution
SELECT
    behavioral_state,
    COUNT(*) AS user_product_pairs,
    ROUND(AVG(interaction_score), 2) AS avg_implicit_score,
    SUM(purchase_count) AS total_purchases,
    SUM(view_count) AS total_views
FROM user_item_interactions
GROUP BY behavioral_state
ORDER BY user_product_pairs DESC;
