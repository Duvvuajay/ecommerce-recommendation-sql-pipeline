-- ==============================================================================
-- Module 15: Model-Specific Analytical Views and Export Staging
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- 1. COLLABORATIVE FILTERING EXPORT VIEW
-- ------------------------------------------------------------------------------
-- Target: Matrix Factorization, ALS (Alternating Least Squares), BPR, Neural CF
-- Structure: Sparse user-item implicit ratings matrix with interaction recency.

CREATE OR REPLACE VIEW view_export_collaborative_filtering AS
SELECT
    user_id,
    product_id,
    interaction_score,
    total_interactions,
    purchase_count,
    view_count,
    cart_count,
    behavioral_state,
    first_interaction,
    last_interaction,
    recency_days_at_cutoff
FROM user_item_interactions
WHERE interaction_score > 0
ORDER BY user_id, interaction_score DESC;

-- ------------------------------------------------------------------------------
-- 2. POPULARITY BASELINE EXPORT VIEW
-- ------------------------------------------------------------------------------
-- Target: Cold-start fallback models, top-N trending category widgets
-- Structure: Category-partitioned ranking and score metrics.

CREATE OR REPLACE VIEW view_export_popularity_baseline AS
SELECT
    product_id,
    product_name,
    category,
    analytical_period,
    popularity_score,
    category_popularity_rank,
    purchase_count,
    view_count,
    click_count,
    unique_engaging_users,
    product_age_days,
    freshness_tier,
    interaction_sufficiency
FROM product_popularity
ORDER BY category, category_popularity_rank ASC;

-- ------------------------------------------------------------------------------
-- 3. CONTENT-BASED MODELING EXPORT VIEW
-- ------------------------------------------------------------------------------
-- Target: TF-IDF, Vector Embeddings, Item-Item Cosine Similarity
-- Structure: Product catalog attributes denormalized with metadata key-values.

CREATE OR REPLACE VIEW view_export_content_based AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.product_status,
    p.created_at AS catalog_launch_date,
    MAX(CASE WHEN pp.property_name = 'Brand' THEN pp.property_value END) AS brand,
    MAX(CASE WHEN pp.property_name = 'Warranty' THEN pp.property_value END) AS warranty,
    MAX(CASE WHEN pp.property_name = 'Connectivity' THEN pp.property_value END) AS connectivity,
    MAX(CASE WHEN pp.property_name = 'Material' THEN pp.property_value END) AS material,
    MAX(CASE WHEN pp.property_name = 'Size' THEN pp.property_value END) AS size,
    MAX(CASE WHEN pp.property_name = 'Author' THEN pp.property_value END) AS author,
    MAX(CASE WHEN pp.property_name = 'Color' THEN pp.property_value END) AS color,
    MAX(CASE WHEN pp.property_name = 'Skin Type' THEN pp.property_value END) AS skin_type
FROM products p
LEFT JOIN product_properties pp ON p.product_id = pp.product_id
WHERE p.product_status = 'active'
GROUP BY p.product_id, p.product_name, p.category, p.price, p.product_status, p.created_at
ORDER BY p.product_id;

-- Sample audit of export views
SELECT 'Collaborative Filtering Records' AS dataset, COUNT(*) AS total_rows FROM view_export_collaborative_filtering
UNION ALL
SELECT 'Popularity Baseline Records', COUNT(*) FROM view_export_popularity_baseline
UNION ALL
SELECT 'Content-Based Catalog Items', COUNT(*) FROM view_export_content_based;
