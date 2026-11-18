-- ==============================================================================
-- Module 08: Product Popularity, Freshness & Cold-Start Identification
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));
SET @cold_start_threshold = 5; -- Configurable interaction minimum

-- ------------------------------------------------------------------------------
-- 1. CATEGORY & PERIOD-LEVEL PRODUCT POPULARITY TABLE
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS product_popularity;

CREATE TABLE product_popularity AS
WITH product_period_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.created_at AS catalog_date,
        DATE_FORMAT(ie.interaction_time, '%Y-%m') AS analytical_period,

        COUNT(*) AS total_interactions,
        COUNT(DISTINCT ie.user_id) AS unique_engaging_users,
        SUM(CASE WHEN ie.behavior = 'impression'  THEN 1 ELSE 0 END) AS impression_count,
        SUM(CASE WHEN ie.behavior = 'view'        THEN 1 ELSE 0 END) AS view_count,
        SUM(CASE WHEN ie.behavior = 'click'       THEN 1 ELSE 0 END) AS click_count,
        SUM(CASE WHEN ie.behavior = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_count,
        SUM(CASE WHEN ie.behavior = 'purchase'    THEN 1 ELSE 0 END) AS purchase_count,
        SUM(CASE WHEN ie.behavior = 'return'      THEN 1 ELSE 0 END) AS return_count,

        -- Popularity Score Formulation: Purchase-heavy weighted aggregation
        ROUND(
            (SUM(CASE WHEN ie.behavior = 'purchase' THEN 1 ELSE 0 END) * 5.0) +
            (SUM(CASE WHEN ie.behavior = 'add_to_cart' THEN 1 ELSE 0 END) * 3.0) +
            (SUM(CASE WHEN ie.behavior = 'click' THEN 1 ELSE 0 END) * 2.0) +
            (SUM(CASE WHEN ie.behavior = 'view' THEN 1 ELSE 0 END) * 1.0) -
            (SUM(CASE WHEN ie.behavior = 'return' THEN 1 ELSE 0 END) * 3.0)
        , 2) AS popularity_score,

        -- Freshness Indicator: Days between product catalog launch and cutoff
        GREATEST(0, DATEDIFF(@train_cutoff, p.created_at)) AS product_age_days

    FROM products p
    LEFT JOIN interaction_events ie
        ON p.product_id = ie.product_id
       AND ie.interaction_time >= @window_start
       AND ie.interaction_time <= @train_cutoff
    WHERE p.product_status = 'active'
    GROUP BY p.product_id, p.product_name, p.category, p.created_at, DATE_FORMAT(ie.interaction_time, '%Y-%m')
)
SELECT
    product_id,
    product_name,
    category,
    COALESCE(analytical_period, DATE_FORMAT(@train_cutoff, '%Y-%m')) AS analytical_period,
    total_interactions,
    unique_engaging_users,
    impression_count,
    view_count,
    click_count,
    cart_count,
    purchase_count,
    return_count,
    popularity_score,
    product_age_days,

    -- Product Freshness Segmentation
    CASE
        WHEN product_age_days <= 14 THEN 'NEW_RELEASE'
        WHEN product_age_days <= 45 THEN 'GROWTH'
        ELSE 'MATURE_CATALOG'
    END AS freshness_tier,

    -- Cold-Start / Insufficient Interaction Identification (Task 6)
    CASE
        WHEN total_interactions < @cold_start_threshold THEN 'COLD_START_INSUFFICIENT'
        ELSE 'WARM_INTERACTION_HISTORY'
    END AS interaction_sufficiency,

    -- Category-Level Popularity Ranking (Task 5)
    DENSE_RANK() OVER (
        PARTITION BY category, analytical_period
        ORDER BY popularity_score DESC, total_interactions DESC
    ) AS category_popularity_rank

FROM product_period_metrics;

-- Primary Key & Indexes
ALTER TABLE product_popularity ADD PRIMARY KEY (product_id, analytical_period);
CREATE INDEX idx_popularity_cat_rank ON product_popularity (category, category_popularity_rank);
CREATE INDEX idx_popularity_sufficiency ON product_popularity (interaction_sufficiency);

-- Sample Query: Top 3 Popular Products Per Category
SELECT
    category,
    category_popularity_rank,
    product_name,
    popularity_score,
    purchase_count,
    view_count,
    freshness_tier,
    interaction_sufficiency
FROM product_popularity
WHERE category_popularity_rank <= 3
ORDER BY category, category_popularity_rank;
