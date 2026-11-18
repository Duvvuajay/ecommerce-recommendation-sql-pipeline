-- ==============================================================================
-- Module 17: Chart & Graphical Analytics Queries on user_item_interactions
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- CHART 1: BEHAVIORAL STATE DISTRIBUTION (DONUT / BAR CHART)
-- ------------------------------------------------------------------------------
-- Shows proportion of interactions converting to purchases vs. views vs. cart abandons
SELECT
    behavioral_state,
    COUNT(*) AS total_user_product_pairs,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_item_interactions), 2) AS percentage_of_total,
    ROUND(AVG(interaction_score), 2) AS avg_implicit_score,
    SUM(purchase_count) AS total_purchases,
    SUM(cart_count) AS total_cart_adds,
    SUM(view_count) AS total_views
FROM user_item_interactions
GROUP BY behavioral_state
ORDER BY total_user_product_pairs DESC;

-- ------------------------------------------------------------------------------
-- CHART 2: IMPLICIT FEEDBACK SCORE DISTRIBUTION (HISTOGRAM / DENSITY PLOT)
-- ------------------------------------------------------------------------------
-- Visualizes the skew of implicit feedback scores across users and items
SELECT
    CASE
        WHEN interaction_score = 0 THEN '0 (Neutral Exposure Only)'
        WHEN interaction_score BETWEEN 0.01 AND 2.00 THEN '0.01 - 2.00 (Low Affinity: Views/Clicks)'
        WHEN interaction_score BETWEEN 2.01 AND 5.00 THEN '2.01 - 5.00 (Moderate: Carts/1 Purchase)'
        WHEN interaction_score BETWEEN 5.01 AND 10.00 THEN '5.01 - 10.00 (High: Multi-Engagement)'
        ELSE '> 10.00 (Very High: Loyal / Repeat Buyer)'
    END AS score_bucket,
    COUNT(*) AS pair_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_item_interactions), 2) AS bucket_percentage,
    ROUND(AVG(interaction_score), 2) AS mean_score_in_bucket
FROM user_item_interactions
GROUP BY 
    CASE
        WHEN interaction_score = 0 THEN '0 (Neutral Exposure Only)'
        WHEN interaction_score BETWEEN 0.01 AND 2.00 THEN '0.01 - 2.00 (Low Affinity: Views/Clicks)'
        WHEN interaction_score BETWEEN 2.01 AND 5.00 THEN '2.01 - 5.00 (Moderate: Carts/1 Purchase)'
        WHEN interaction_score BETWEEN 5.01 AND 10.00 THEN '5.01 - 10.00 (High: Multi-Engagement)'
        ELSE '> 10.00 (Very High: Loyal / Repeat Buyer)'
    END
ORDER BY MIN(interaction_score) ASC;

-- ------------------------------------------------------------------------------
-- CHART 3: TOTAL EVENT VOLUME BY BEHAVIOR (FUNNEL CHART)
-- ------------------------------------------------------------------------------
-- Visualizes the e-commerce conversion drop-off across the interaction matrix
SELECT
    '1. Impressions (Exposure)' AS conversion_funnel_stage,
    SUM(impression_count) AS total_event_volume
FROM user_item_interactions
UNION ALL
SELECT
    '2. Views (Inspection)',
    SUM(view_count)
FROM user_item_interactions
UNION ALL
SELECT
    '3. Clicks (Engagement)',
    SUM(click_count)
FROM user_item_interactions
UNION ALL
SELECT
    '4. Add to Cart (Intent)',
    SUM(cart_count)
FROM user_item_interactions
UNION ALL
SELECT
    '5. Wishlist (Affinity)',
    SUM(wishlist_count)
FROM user_item_interactions
UNION ALL
SELECT
    '6. Purchases (Conversion)',
    SUM(purchase_count)
FROM user_item_interactions
UNION ALL
SELECT
    '7. Returns (Reversals)',
    SUM(return_count)
FROM user_item_interactions;

-- ------------------------------------------------------------------------------
-- CHART 4: RECENCY DECAY DISTRIBUTION (TIME-DECAY LINE / BAR CHART)
-- ------------------------------------------------------------------------------
-- Analyzes interaction recency at the recommendation cutoff timestamp
SELECT
    CASE
        WHEN recency_days_at_cutoff <= 7 THEN '0 - 7 Days (Fresh / Active)'
        WHEN recency_days_at_cutoff <= 14 THEN '8 - 14 Days (Recent)'
        WHEN recency_days_at_cutoff <= 21 THEN '15 - 21 Days (Moderate Aging)'
        ELSE '22 - 30+ Days (Cold / Latent)'
    END AS recency_window,
    COUNT(*) AS total_interactions_in_window,
    ROUND(AVG(interaction_score), 2) AS avg_score,
    SUM(purchase_count) AS purchases
FROM user_item_interactions
GROUP BY 
    CASE
        WHEN recency_days_at_cutoff <= 7 THEN '0 - 7 Days (Fresh / Active)'
        WHEN recency_days_at_cutoff <= 14 THEN '8 - 14 Days (Recent)'
        WHEN recency_days_at_cutoff <= 21 THEN '15 - 21 Days (Moderate Aging)'
        ELSE '22 - 30+ Days (Cold / Latent)'
    END
ORDER BY MIN(recency_days_at_cutoff) ASC;

-- ------------------------------------------------------------------------------
-- CHART 5: TOP 10 MOST HIGHLY ENGAGED PRODUCTS BY IMPLICIT SCORE
-- ------------------------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COUNT(DISTINCT uii.user_id) AS unique_customers_engaged,
    SUM(uii.purchase_count) AS total_units_bought,
    SUM(uii.view_count) AS total_views,
    ROUND(SUM(uii.interaction_score), 2) AS aggregate_implicit_score
FROM user_item_interactions uii
JOIN products p ON uii.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY aggregate_implicit_score DESC
LIMIT 10;
