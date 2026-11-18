-- ==============================================================================
-- Module 10: Point-in-Time Historical Interaction Snapshots
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- CONFIGURABLE RECOMMENDATION CUTOFF
-- ------------------------------------------------------------------------------
-- Freezes system history at exact timestamp T_cutoff for point-in-time reproducibility
SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));

-- ------------------------------------------------------------------------------
-- HISTORICAL INTERACTION SNAPSHOT REPOSITORY
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS historical_interaction_snapshots;

CREATE TABLE historical_interaction_snapshots AS
SELECT
    ie.user_id,
    ie.product_id,
    CAST(@train_cutoff AS DATETIME) AS snapshot_cutoff_time,
    COUNT(*) AS historical_interaction_count,
    ROUND(SUM(ie.feedback_weight), 2) AS historical_implicit_score,
    SUM(CASE WHEN ie.behavior = 'purchase' THEN 1 ELSE 0 END) AS historical_purchase_count,
    SUM(CASE WHEN ie.behavior = 'view'     THEN 1 ELSE 0 END) AS historical_view_count,
    SUM(CASE WHEN ie.behavior = 'click'    THEN 1 ELSE 0 END) AS historical_click_count,
    SUM(CASE WHEN ie.behavior = 'add_to_cart' THEN 1 ELSE 0 END) AS historical_cart_count,
    MIN(ie.interaction_time) AS snapshot_first_interaction,
    MAX(ie.interaction_time) AS snapshot_last_interaction
FROM interaction_events ie
WHERE ie.interaction_time >= @window_start
  AND ie.interaction_time <= @train_cutoff
GROUP BY ie.user_id, ie.product_id;

ALTER TABLE historical_interaction_snapshots MODIFY snapshot_cutoff_time DATETIME NOT NULL;
ALTER TABLE historical_interaction_snapshots ADD PRIMARY KEY (user_id, product_id, snapshot_cutoff_time);
CREATE INDEX idx_snapshot_user_score ON historical_interaction_snapshots (user_id, historical_implicit_score DESC);

-- Snapshot Verification & Temporal Boundary Audit
SELECT
    snapshot_cutoff_time,
    COUNT(*) AS total_snapshot_pairs,
    COUNT(DISTINCT user_id) AS distinct_users,
    COUNT(DISTINCT product_id) AS distinct_products,
    MIN(snapshot_first_interaction) AS earliest_event_captured,
    MAX(snapshot_last_interaction) AS latest_event_captured,
    (SELECT COUNT(*) FROM interaction_events WHERE interaction_time > @train_cutoff) AS future_events_excluded
FROM historical_interaction_snapshots
GROUP BY snapshot_cutoff_time;
