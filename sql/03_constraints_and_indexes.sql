-- ==============================================================================
-- Module 03: Constraints, Foreign Keys, and Performance Indexes
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- ------------------------------------------------------------------------------
-- 1. FOREIGN KEY CONSTRAINTS
-- ------------------------------------------------------------------------------

-- product -> product_properties
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'product_properties' 
                    AND CONSTRAINT_NAME = 'fk_properties_product');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE product_properties ADD CONSTRAINT fk_properties_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 
    'SELECT "fk_properties_product already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- products -> product_availability
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'product_availability' 
                    AND CONSTRAINT_NAME = 'fk_availability_product');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE product_availability ADD CONSTRAINT fk_availability_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 
    'SELECT "fk_availability_product already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- users -> user_events
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'user_events' 
                    AND CONSTRAINT_NAME = 'fk_events_user');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE user_events ADD CONSTRAINT fk_events_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;', 
    'SELECT "fk_events_user already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- products -> user_events
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'user_events' 
                    AND CONSTRAINT_NAME = 'fk_events_product');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE user_events ADD CONSTRAINT fk_events_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 
    'SELECT "fk_events_product already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- users -> orders
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'orders' 
                    AND CONSTRAINT_NAME = 'fk_orders_user');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE orders ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;', 
    'SELECT "fk_orders_user already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- orders -> order_items
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'order_items' 
                    AND CONSTRAINT_NAME = 'fk_order_items_order');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE;', 
    'SELECT "fk_order_items_order already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- products -> order_items
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'order_items' 
                    AND CONSTRAINT_NAME = 'fk_order_items_product');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 
    'SELECT "fk_order_items_product already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- order_items -> returns
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' 
                    AND TABLE_NAME = 'returns' 
                    AND CONSTRAINT_NAME = 'fk_returns_order_item');
SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE returns ADD CONSTRAINT fk_returns_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id) ON DELETE CASCADE;', 
    'SELECT "fk_returns_order_item already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------------------------
-- 2. ANALYTICAL PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------

-- Deduplication index
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND INDEX_NAME = 'idx_events_source_ingestion');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_events_source_ingestion ON user_events (source_event_id, ingestion_timestamp);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Interaction history index
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND INDEX_NAME = 'idx_events_user_prod_time');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_events_user_prod_time ON user_events (user_id, product_id, event_timestamp);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Category-level popularity index
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'products' AND INDEX_NAME = 'idx_products_cat_status');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_products_cat_status ON products (category, product_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Availability interval index for point-in-time temporal joins
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'product_availability' AND INDEX_NAME = 'idx_avail_prod_effective');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_avail_prod_effective ON product_availability (product_id, effective_from, effective_to, availability_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Orders date index
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'orders' AND INDEX_NAME = 'idx_orders_user_date_status');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_orders_user_date_status ON orders (user_id, order_date, order_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
