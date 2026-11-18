-- ==============================================================================
-- Module 09: User Activity Profiling & Engagement Segmentation
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));

DROP TABLE IF EXISTS user_activity_profiles;

CREATE TABLE user_activity_profiles AS
WITH user_aggregates AS (
    SELECT
        u.user_id,
        u.user_name,
        u.email,
        u.city,
        u.registration_date,
        u.user_status,

        COUNT(ie.user_id) AS total_interactions,
        COUNT(DISTINCT ie.product_id) AS unique_products_interacted,

        SUM(CASE WHEN ie.behavior = 'impression'  THEN 1 ELSE 0 END) AS total_impressions,
        SUM(CASE WHEN ie.behavior = 'view'        THEN 1 ELSE 0 END) AS total_views,
        SUM(CASE WHEN ie.behavior = 'click'       THEN 1 ELSE 0 END) AS total_clicks,
        SUM(CASE WHEN ie.behavior = 'add_to_cart' THEN 1 ELSE 0 END) AS total_cart_additions,
        SUM(CASE WHEN ie.behavior = 'wishlist'    THEN 1 ELSE 0 END) AS total_wishlists,
        SUM(CASE WHEN ie.behavior = 'purchase'    THEN 1 ELSE 0 END) AS total_purchases,
        SUM(CASE WHEN ie.behavior = 'return'      THEN 1 ELSE 0 END) AS total_returns,

        SUM(CASE WHEN ie.feedback_type = 'positive' THEN 1 ELSE 0 END) AS total_positive_actions,
        SUM(CASE WHEN ie.feedback_type = 'negative' THEN 1 ELSE 0 END) AS total_negative_actions,
        ROUND(COALESCE(SUM(ie.feedback_weight), 0.0), 2) AS total_implicit_score,

        MIN(ie.interaction_time) AS first_activity_time,
        MAX(ie.interaction_time) AS last_activity_time,
        GREATEST(0, DATEDIFF(@train_cutoff, MAX(ie.interaction_time))) AS recency_days_at_cutoff

    FROM users u
    LEFT JOIN interaction_events ie
        ON u.user_id = ie.user_id
       AND ie.interaction_time >= @window_start
       AND ie.interaction_time <= @train_cutoff
    GROUP BY u.user_id, u.user_name, u.email, u.city, u.registration_date, u.user_status
)
SELECT
    user_id,
    user_name,
    email,
    city,
    registration_date,
    user_status,
    total_interactions,
    unique_products_interacted,
    total_impressions,
    total_views,
    total_clicks,
    total_cart_additions,
    total_wishlists,
    total_purchases,
    total_returns,
    total_positive_actions,
    total_negative_actions,
    total_implicit_score,
    first_activity_time,
    last_activity_time,
    recency_days_at_cutoff,

    -- User Activity Classification
    CASE
        WHEN total_interactions >= 25 THEN 'HIGHLY_ACTIVE'
        WHEN total_interactions >= 10 THEN 'MODERATELY_ACTIVE'
        WHEN total_interactions >= 1  THEN 'LOW_ACTIVITY'
        ELSE 'INACTIVE'
    END AS activity_tier

FROM user_aggregates;

ALTER TABLE user_activity_profiles ADD PRIMARY KEY (user_id);
CREATE INDEX idx_user_activity_tier ON user_activity_profiles (activity_tier);

-- Summary of User Activity Tiers
SELECT
    activity_tier,
    COUNT(*) AS total_users,
    ROUND(AVG(total_interactions), 1) AS avg_interactions_per_user,
    ROUND(AVG(total_purchases), 1) AS avg_purchases_per_user,
    ROUND(AVG(total_implicit_score), 2) AS avg_score
FROM user_activity_profiles
GROUP BY activity_tier
ORDER BY total_users DESC;
