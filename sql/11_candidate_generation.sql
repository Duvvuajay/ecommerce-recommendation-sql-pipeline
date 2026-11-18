-- ==============================================================================
-- Module 11: Recommendation Candidate Generation & Availability Constraints
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));

-- ------------------------------------------------------------------------------
-- ELIGIBLE CANDIDATE POOL GENERATION
-- ------------------------------------------------------------------------------
-- Rule 1: Product catalog status must be 'active'.
-- Rule 2: Point-in-time stock availability check at @train_cutoff (SCD Type 2).
--         Products with zero stock or 'out_of_stock' status at cutoff are EXCLUDED.
-- Rule 3: Candidate Exclusion: Exclude products already purchased and retained by the user.
--         Products merely viewed or carted REMAIN ELIGIBLE.

DROP TABLE IF EXISTS recommendation_candidates;

CREATE TABLE recommendation_candidates AS
WITH available_products_at_cutoff AS (
    -- Temporal join on SCD Type 2 availability intervals
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        pa.stock_quantity,
        pa.availability_status,
        pa.effective_from,
        pa.effective_to
    FROM products p
    JOIN product_availability pa
        ON p.product_id = pa.product_id
       AND pa.effective_from <= @train_cutoff
       AND (pa.effective_to IS NULL OR pa.effective_to > @train_cutoff)
    WHERE p.product_status = 'active'
      AND pa.availability_status = 'available'
      AND pa.stock_quantity > 0
),
user_prior_purchases AS (
    -- Identifies items already purchased and not returned prior to cutoff
    SELECT DISTINCT
        o.user_id,
        oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN returns r ON oi.order_item_id = r.order_item_id AND r.return_date <= @train_cutoff
    WHERE o.order_date <= @train_cutoff
      AND o.order_status IN ('confirmed', 'shipped', 'delivered')
      AND r.return_id IS NULL -- Retained purchase
)
SELECT
    u.user_id,
    ap.product_id,
    ap.product_name,
    ap.category,
    ap.price,
    ap.stock_quantity AS available_stock_at_cutoff,
    CAST(@train_cutoff AS DATETIME) AS prediction_cutoff_time,

    -- Prior Engagement Flag (Viewed vs New Discovery)
    CASE
        WHEN ui.user_id IS NOT NULL THEN 'PREVIOUSLY_VIEWED_ENGAGED'
        ELSE 'UNOBSERVED_DISCOVERY'
    END AS candidate_affinity_type

FROM users u
CROSS JOIN available_products_at_cutoff ap
-- Exclude previously purchased & retained items
LEFT JOIN user_prior_purchases upp
    ON u.user_id = upp.user_id
   AND ap.product_id = upp.product_id
-- Check prior interaction history (views, clicks, carts)
LEFT JOIN user_item_interactions ui
    ON u.user_id = ui.user_id
   AND ap.product_id = ui.product_id
WHERE u.user_status = 'active'
  AND upp.product_id IS NULL; -- Excluded prior purchases

-- Primary Key & Indexing
ALTER TABLE recommendation_candidates ADD PRIMARY KEY (user_id, product_id);
CREATE INDEX idx_candidate_cat ON recommendation_candidates (user_id, category);
CREATE INDEX idx_candidate_affinity ON recommendation_candidates (candidate_affinity_type);

-- Verification Audit of Candidate Set
SELECT
    COUNT(*) AS total_candidate_pairs,
    COUNT(DISTINCT user_id) AS distinct_users,
    COUNT(DISTINCT product_id) AS eligible_available_products,
    ROUND(COUNT(*) / COUNT(DISTINCT user_id), 1) AS avg_candidate_pool_per_user
FROM recommendation_candidates;
