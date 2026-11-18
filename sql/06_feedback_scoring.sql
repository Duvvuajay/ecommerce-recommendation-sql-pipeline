-- ==============================================================================
-- Module 06: Behavioral Event Classification and Feedback Weighting
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- UNIFIED INTERACTION EVENTS REPOSITORY
-- ------------------------------------------------------------------------------
-- Combines clean digital clickstream events, transactional purchases, and 
-- reverse logistics returns into a unified behavioral interaction log.

DROP TABLE IF EXISTS interaction_events;

CREATE TABLE interaction_events AS

-- 1. Clickstream & Browsing Events
SELECT
    user_id,
    product_id,
    event_timestamp AS interaction_time,
    event_type AS behavior,
    CASE
        WHEN event_type = 'impression'  THEN 0.0
        WHEN event_type = 'view'        THEN 1.0
        WHEN event_type = 'click'       THEN 2.0
        WHEN event_type = 'add_to_cart' THEN 3.0
        WHEN event_type = 'wishlist'    THEN 3.0
    END AS feedback_weight,
    CASE
        WHEN event_type = 'impression'  THEN 'neutral'
        ELSE 'positive'
    END AS feedback_type
FROM clean_user_events

UNION ALL

-- 2. Transactional Purchases (Positive Commitment)
SELECT
    o.user_id,
    oi.product_id,
    o.order_date AS interaction_time,
    'purchase' AS behavior,
    5.0 AS feedback_weight,
    'positive' AS feedback_type
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('confirmed', 'shipped', 'delivered')

UNION ALL

-- 3. Merchandise Returns (Negative Reversal)
SELECT
    o.user_id,
    oi.product_id,
    r.return_date AS interaction_time,
    'return' AS behavior,
    -3.0 AS feedback_weight,
    'negative' AS feedback_type
FROM returns r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
JOIN orders o ON oi.order_id = o.order_id;

-- Indexing for multi-dimensional analytical queries
CREATE INDEX idx_interaction_user_prod_time ON interaction_events (user_id, product_id, interaction_time);
CREATE INDEX idx_interaction_behavior ON interaction_events (behavior, feedback_type);

-- Verification Breakdown
SELECT
    behavior,
    feedback_type,
    feedback_weight,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS distinct_users,
    COUNT(DISTINCT product_id) AS distinct_products
FROM interaction_events
GROUP BY behavior, feedback_type, feedback_weight
ORDER BY feedback_weight DESC;
