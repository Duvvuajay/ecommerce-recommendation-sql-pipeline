-- ==============================================================================
-- Module 05: Event Deduplication Pipeline
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- 1. DEDUPLICATE REPEATED EVENT INGESTION
-- ------------------------------------------------------------------------------
-- Technical duplicates arise from telemetry retries and mirror identical source_event_id.
-- Genuine repeated actions (e.g. user viewing the same product on multiple days)
-- carry distinct source_event_id values and are strictly retained.

DROP TABLE IF EXISTS clean_user_events;

CREATE TABLE clean_user_events AS
WITH ranked_events AS (
    SELECT
        event_id,
        source_event_id,
        user_id,
        product_id,
        event_type,
        event_timestamp,
        ingestion_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY source_event_id
            ORDER BY ingestion_timestamp ASC, event_id ASC
        ) AS ingestion_rank
    FROM user_events
)
SELECT
    event_id,
    source_event_id,
    user_id,
    product_id,
    event_type,
    event_timestamp,
    ingestion_timestamp
FROM ranked_events
WHERE ingestion_rank = 1;

-- Add primary key and analytical index to deduplicated staging table
ALTER TABLE clean_user_events ADD PRIMARY KEY (event_id);
CREATE INDEX idx_clean_events_user_prod_time ON clean_user_events (user_id, product_id, event_timestamp);

-- Deduplication Audit Report
SELECT
    (SELECT COUNT(*) FROM user_events) AS total_raw_events,
    (SELECT COUNT(*) FROM clean_user_events) AS total_deduplicated_events,
    ((SELECT COUNT(*) FROM user_events) - (SELECT COUNT(*) FROM clean_user_events)) AS redundant_ingestions_removed;
