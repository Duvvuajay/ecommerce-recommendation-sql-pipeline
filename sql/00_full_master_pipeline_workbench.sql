-- ==============================================================================
-- PROJECT 38: COMPLETE MASTER PIPELINE (FOR MYSQL WORKBENCH GUI)
-- E-Commerce Recommendation Engine Dataset Using Behavioral & Transactional SQL
-- Single-File Self-Contained Execution for MySQL Workbench
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. DATABASE INITIALIZATION
-- ------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS recommendation_engine
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE recommendation_engine;

SELECT 
    DATABASE() AS current_database,
    @@character_set_database AS charset,
    @@collation_database AS collation;

-- ------------------------------------------------------------------------------
-- 2. SCHEMA TABLE DEFINITIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    registration_date DATETIME NOT NULL,
    city VARCHAR(100),
    user_status ENUM('active', 'inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL,
    product_status ENUM('active', 'inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS product_properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    property_name VARCHAR(100) NOT NULL,
    property_value VARCHAR(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS product_availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    stock_quantity INT NOT NULL,
    availability_status ENUM('available', 'out_of_stock') NOT NULL,
    effective_from DATETIME NOT NULL,
    effective_to DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS user_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    source_event_id VARCHAR(100) NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    event_type ENUM('impression', 'view', 'click', 'add_to_cart', 'wishlist') NOT NULL,
    event_timestamp DATETIME NOT NULL,
    ingestion_timestamp DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    return_date DATETIME NOT NULL,
    return_quantity INT NOT NULL,
    return_reason ENUM('damaged', 'wrong_item', 'size_or_fit', 'changed_mind', 'other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------------------------
-- 3. CONSTRAINTS & PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'product_properties' AND CONSTRAINT_NAME = 'fk_properties_product');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE product_properties ADD CONSTRAINT fk_properties_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'product_availability' AND CONSTRAINT_NAME = 'fk_availability_product');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE product_availability ADD CONSTRAINT fk_availability_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND CONSTRAINT_NAME = 'fk_events_user');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE user_events ADD CONSTRAINT fk_events_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND CONSTRAINT_NAME = 'fk_events_product');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE user_events ADD CONSTRAINT fk_events_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'orders' AND CONSTRAINT_NAME = 'fk_orders_user');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE orders ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'order_items' AND CONSTRAINT_NAME = 'fk_order_items_order');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'order_items' AND CONSTRAINT_NAME = 'fk_order_items_product');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'returns' AND CONSTRAINT_NAME = 'fk_returns_order_item');
SET @sql = IF(@fk_exists = 0, 'ALTER TABLE returns ADD CONSTRAINT fk_returns_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id) ON DELETE CASCADE;', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND INDEX_NAME = 'idx_events_source_ingestion');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_events_source_ingestion ON user_events (source_event_id, ingestion_timestamp);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'user_events' AND INDEX_NAME = 'idx_events_user_prod_time');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_events_user_prod_time ON user_events (user_id, product_id, event_timestamp);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'products' AND INDEX_NAME = 'idx_products_cat_status');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_products_cat_status ON products (category, product_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'product_availability' AND INDEX_NAME = 'idx_avail_prod_effective');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_avail_prod_effective ON product_availability (product_id, effective_from, effective_to, availability_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'recommendation_engine' AND TABLE_NAME = 'orders' AND INDEX_NAME = 'idx_orders_user_date_status');
SET @sql = IF(@idx_exists = 0, 'CREATE INDEX idx_orders_user_date_status ON orders (user_id, order_date, order_status);', 'SELECT 1;');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------------------------
-- 4. DATA POPULATION (IDEMPOTENT INSERTS)
-- ------------------------------------------------------------------------------
INSERT INTO users (user_id, user_name, email, registration_date, city, user_status)
VALUES
(1, 'Arjun Kumar', 'arjun01@example.com', '2026-01-05 10:30:00', 'Hyderabad', 'active'),
(2, 'Priya Sharma', 'priya02@example.com', '2026-01-08 11:15:00', 'Bangalore', 'active'),
(3, 'Rahul Reddy', 'rahul03@example.com', '2026-01-12 09:45:00', 'Warangal', 'active'),
(4, 'Sneha Patel', 'sneha04@example.com', '2026-01-15 14:20:00', 'Mumbai', 'inactive'),
(5, 'Kiran Rao', 'kiran05@example.com', '2026-01-18 16:00:00', 'Chennai', 'active'),
(6, 'Ananya Das', 'ananya06@example.com', '2026-01-20 12:10:00', 'Kolkata', 'active'),
(7, 'Vikram Singh', 'vikram07@example.com', '2026-01-22 08:30:00', 'Delhi', 'inactive'),
(8, 'Meera Nair', 'meera08@example.com', '2026-01-25 13:45:00', 'Kochi', 'active'),
(9, 'Sanjay Verma', 'sanjay09@example.com', '2026-01-28 15:30:00', 'Pune', 'active'),
(10, 'Divya Reddy', 'divya10@example.com', '2026-02-01 10:00:00', 'Vijayawada', 'active'),
(11, 'Akhil Varma', 'akhil11@example.com', '2026-02-02 09:15:00', 'Hyderabad', 'active'),
(12, 'Pooja Reddy', 'pooja12@example.com', '2026-02-03 10:30:00', 'Vijayawada', 'active'),
(13, 'Suresh Kumar', 'suresh13@example.com', '2026-02-04 11:00:00', 'Chennai', 'inactive'),
(14, 'Keerthi Rao', 'keerthi14@example.com', '2026-02-05 12:15:00', 'Bangalore', 'active'),
(15, 'Naveen Kumar', 'naveen15@example.com', '2026-02-06 13:20:00', 'Warangal', 'active'),
(16, 'Lakshmi Devi', 'lakshmi16@example.com', '2026-02-07 14:10:00', 'Hyderabad', 'active'),
(17, 'Rohit Sharma', 'rohit17@example.com', '2026-02-08 15:30:00', 'Mumbai', 'inactive'),
(18, 'Harika Reddy', 'harika18@example.com', '2026-02-09 09:45:00', 'Visakhapatnam', 'active'),
(19, 'Manoj Kumar', 'manoj19@example.com', '2026-02-10 10:20:00', 'Delhi', 'active'),
(20, 'Swathi Nair', 'swathi20@example.com', '2026-02-11 11:35:00', 'Kochi', 'active'),
(21, 'Praveen Rao', 'praveen21@example.com', '2026-02-12 12:40:00', 'Pune', 'active'),
(22, 'Divya Sharma', 'divya22@example.com', '2026-02-13 13:15:00', 'Jaipur', 'inactive'),
(23, 'Sai Krishna', 'saikrishna23@example.com', '2026-02-14 14:25:00', 'Hyderabad', 'active'),
(24, 'Bhavana Patel', 'bhavana24@example.com', '2026-02-15 15:10:00', 'Ahmedabad', 'active'),
(25, 'Tarun Reddy', 'tarun25@example.com', '2026-02-16 09:30:00', 'Warangal', 'active'),
(26, 'Mounika Rao', 'mounika26@example.com', '2026-02-17 10:45:00', 'Vijayawada', 'inactive'),
(27, 'Karthik Iyer', 'karthik27@example.com', '2026-02-18 11:50:00', 'Chennai', 'active'),
(28, 'Sravani Das', 'sravani28@example.com', '2026-02-19 12:30:00', 'Kolkata', 'active'),
(29, 'Abhishek Verma', 'abhishek29@example.com', '2026-02-20 13:40:00', 'Delhi', 'active'),
(30, 'Nithya Menon', 'nithya30@example.com', '2026-02-21 14:20:00', 'Kochi', 'active'),
(31, 'Vamsi Krishna', 'vamsi31@example.com', '2026-02-22 09:10:00', 'Hyderabad', 'active'),
(32, 'Anusha Reddy', 'anusha32@example.com', '2026-02-23 10:25:00', 'Warangal', 'active'),
(33, 'Gowtham Rao', 'gowtham33@example.com', '2026-02-24 11:40:00', 'Bangalore', 'inactive'),
(34, 'Snehal Patil', 'snehal34@example.com', '2026-02-25 12:55:00', 'Pune', 'active'),
(35, 'Chaitanya Kumar', 'chaitanya35@example.com', '2026-02-26 13:30:00', 'Visakhapatnam', 'active'),
(36, 'Deepika Sharma', 'deepika36@example.com', '2026-02-27 14:45:00', 'Jaipur', 'active'),
(37, 'Rakesh Naidu', 'rakesh37@example.com', '2026-02-28 15:20:00', 'Vijayawada', 'inactive'),
(38, 'Sushma Devi', 'sushma38@example.com', '2026-03-01 09:35:00', 'Hyderabad', 'active'),
(39, 'Aditya Rao', 'aditya39@example.com', '2026-03-02 10:50:00', 'Chennai', 'active'),
(40, 'Kavya Nair', 'kavya40@example.com', '2026-03-03 11:15:00', 'Kochi', 'active'),
(41, 'Ravi Teja', 'raviteja41@example.com', '2026-03-04 12:20:00', 'Warangal', 'active'),
(42, 'Meghana Reddy', 'meghana42@example.com', '2026-03-05 13:35:00', 'Hyderabad', 'inactive'),
(43, 'Aravind Kumar', 'aravind43@example.com', '2026-03-06 14:50:00', 'Bangalore', 'active'),
(44, 'Pallavi Shah', 'pallavi44@example.com', '2026-03-07 15:25:00', 'Mumbai', 'active'),
(45, 'Sandeep Yadav', 'sandeep45@example.com', '2026-03-08 09:40:00', 'Delhi', 'active'),
(46, 'Tejaswini Rao', 'tejaswini46@example.com', '2026-03-09 10:55:00', 'Vijayawada', 'active'),
(47, 'Madhav Reddy', 'madhav47@example.com', '2026-03-10 11:10:00', 'Visakhapatnam', 'inactive'),
(48, 'Aishwarya Iyer', 'aishwarya48@example.com', '2026-03-11 12:25:00', 'Chennai', 'active'),
(49, 'Lokesh Kumar', 'lokesh49@example.com', '2026-03-12 13:40:00', 'Hyderabad', 'active'),
(50, 'Shalini Das', 'shalini50@example.com', '2026-03-13 14:55:00', 'Kolkata', 'active'),
(51, 'Pranay Varma', 'pranay51@example.com', '2026-03-14 09:20:00', 'Warangal', 'active'),
(52, 'Nandini Rao', 'nandini52@example.com', '2026-03-15 10:35:00', 'Bangalore', 'inactive'),
(53, 'Harish Kumar', 'harish53@example.com', '2026-03-16 11:50:00', 'Pune', 'active'),
(54, 'Ritika Sharma', 'ritika54@example.com', '2026-03-17 12:15:00', 'Jaipur', 'active'),
(55, 'Sai Charan', 'saicharan55@example.com', '2026-03-18 13:30:00', 'Hyderabad', 'active'),
(56, 'Janani Krishnan', 'janani56@example.com', '2026-03-19 14:45:00', 'Chennai', 'active'),
(57, 'Mahesh Babu', 'mahesh57@example.com', '2026-03-20 15:10:00', 'Vijayawada', 'inactive'),
(58, 'Sindhu Reddy', 'sindhu58@example.com', '2026-03-21 09:25:00', 'Warangal', 'active'),
(59, 'Vivek Patel', 'vivek59@example.com', '2026-03-22 10:40:00', 'Ahmedabad', 'active'),
(60, 'Rohini Nair', 'rohini60@example.com', '2026-03-23 11:55:00', 'Kochi', 'active'),
(61, 'Ajay Prasad', 'ajay61@example.com', '2026-03-24 12:20:00', 'Hyderabad', 'active'),
(62, 'Sowmya Rao', 'sowmya62@example.com', '2026-03-25 13:35:00', 'Bangalore', 'inactive'),
(63, 'Nikhil Sharma', 'nikhil63@example.com', '2026-03-26 14:50:00', 'Delhi', 'active'),
(64, 'Rupa Devi', 'rupa64@example.com', '2026-03-27 15:15:00', 'Visakhapatnam', 'active'),
(65, 'Kiranmayi Reddy', 'kiranmayi65@example.com', '2026-03-28 09:30:00', 'Warangal', 'active'),
(66, 'Dinesh Kumar', 'dinesh66@example.com', '2026-03-29 10:45:00', 'Chennai', 'active'),
(67, 'Swetha Patel', 'swetha67@example.com', '2026-03-30 11:00:00', 'Mumbai', 'inactive'),
(68, 'Varun Teja', 'varun68@example.com', '2026-03-31 12:15:00', 'Hyderabad', 'active'),
(69, 'Amrutha Nair', 'amrutha69@example.com', '2026-04-01 13:30:00', 'Kochi', 'active'),
(70, 'Rajesh Verma', 'rajesh70@example.com', '2026-04-02 14:45:00', 'Pune', 'active'),
(71, 'Sahithi Rao', 'sahithi71@example.com', '2026-04-03 15:10:00', 'Vijayawada', 'active'),
(72, 'Mohan Krishna', 'mohan72@example.com', '2026-04-04 09:25:00', 'Warangal', 'inactive'),
(73, 'Preethi Sharma', 'preethi73@example.com', '2026-04-05 10:40:00', 'Delhi', 'active'),
(74, 'Srinivas Reddy', 'srinivas74@example.com', '2026-04-06 11:55:00', 'Hyderabad', 'active'),
(75, 'Neha Kulkarni', 'neha75@example.com', '2026-04-07 12:20:00', 'Pune', 'active'),
(76, 'Rahul Nair', 'rahul76@example.com', '2026-04-08 13:35:00', 'Kochi', 'inactive'),
(77, 'Lavanya Das', 'lavanya77@example.com', '2026-04-09 14:50:00', 'Kolkata', 'active'),
(78, 'Sathish Kumar', 'sathish78@example.com', '2026-04-10 15:15:00', 'Chennai', 'active'),
(79, 'Krishna Varma', 'krishna79@example.com', '2026-04-11 09:30:00', 'Visakhapatnam', 'active'),
(80, 'Pavani Reddy', 'pavani80@example.com', '2026-04-12 10:45:00', 'Hyderabad', 'active'),
(81, 'Naveena Rao', 'naveena81@example.com', '2026-04-13 11:00:00', 'Warangal', 'inactive'),
(82, 'Akash Patel', 'akash82@example.com', '2026-04-14 12:15:00', 'Ahmedabad', 'active'),
(83, 'Gayathri Iyer', 'gayathri83@example.com', '2026-04-15 13:30:00', 'Chennai', 'active'),
(84, 'Manasa Kumar', 'manasa84@example.com', '2026-04-16 14:45:00', 'Vijayawada', 'active'),
(85, 'Rohit Reddy', 'rohit85@example.com', '2026-04-17 15:10:00', 'Hyderabad', 'inactive'),
(86, 'Bhargavi Rao', 'bhargavi86@example.com', '2026-04-18 09:25:00', 'Bangalore', 'active'),
(87, 'Anil Sharma', 'anil87@example.com', '2026-04-19 10:40:00', 'Jaipur', 'active'),
(88, 'Sravya Nair', 'sravya88@example.com', '2026-04-20 11:55:00', 'Kochi', 'active'),
(89, 'Teja Krishna', 'teja89@example.com', '2026-04-21 12:20:00', 'Warangal', 'active'),
(90, 'Monika Patel', 'monika90@example.com', '2026-04-22 13:35:00', 'Mumbai', 'inactive'),
(91, 'Vishal Kumar', 'vishal91@example.com', '2026-04-23 14:50:00', 'Delhi', 'active'),
(92, 'Srilatha Reddy', 'srilatha92@example.com', '2026-04-24 15:15:00', 'Hyderabad', 'active'),
(93, 'Girish Rao', 'girish93@example.com', '2026-04-25 09:30:00', 'Bangalore', 'active'),
(94, 'Aparna Menon', 'aparna94@example.com', '2026-04-26 10:45:00', 'Kochi', 'active'),
(95, 'Pavan Kumar', 'pavan95@example.com', '2026-04-27 11:00:00', 'Vijayawada', 'inactive'),
(96, 'Sanjana Das', 'sanjana96@example.com', '2026-04-28 12:15:00', 'Kolkata', 'active'),
(97, 'Ramesh Naidu', 'ramesh97@example.com', '2026-04-29 13:30:00', 'Visakhapatnam', 'active'),
(98, 'Keerthana Sharma', 'keerthana98@example.com', '2026-04-30 14:45:00', 'Jaipur', 'active'),
(99, 'Abhinav Reddy', 'abhinav99@example.com', '2026-05-01 15:10:00', 'Warangal', 'active'),
(100, 'Niharika Rao', 'niharika100@example.com', '2026-05-02 09:25:00', 'Hyderabad', 'active')
ON DUPLICATE KEY UPDATE user_name = VALUES(user_name);

INSERT INTO products (product_id, product_name, category, price, created_at, product_status)
VALUES
(1, 'Samsung Galaxy S24', 'Electronics', 74999.00, '2026-01-05 10:00:00', 'active'),
(2, 'Apple iPhone 15', 'Electronics', 69999.00, '2026-01-06 11:00:00', 'active'),
(3, 'OnePlus 12', 'Electronics', 64999.00, '2026-01-07 12:00:00', 'active'),
(4, 'Redmi Note 13 Pro', 'Electronics', 24999.00, '2026-01-08 13:00:00', 'active'),
(5, 'Samsung Galaxy M35', 'Electronics', 19999.00, '2026-01-09 14:00:00', 'active'),
(6, 'Apple MacBook Air M2', 'Electronics', 89999.00, '2026-01-10 10:00:00', 'active'),
(7, 'HP Pavilion Laptop', 'Electronics', 62999.00, '2026-01-11 11:00:00', 'active'),
(8, 'Dell Inspiron Laptop', 'Electronics', 57999.00, '2026-01-12 12:00:00', 'active'),
(9, 'Lenovo IdeaPad Slim 5', 'Electronics', 54999.00, '2026-01-13 13:00:00', 'active'),
(10, 'ASUS VivoBook 15', 'Electronics', 45999.00, '2026-01-14 14:00:00', 'active'),
(11, 'Sony Wireless Headphones', 'Electronics', 8999.00, '2026-01-15 10:00:00', 'active'),
(12, 'JBL Bluetooth Speaker', 'Electronics', 4999.00, '2026-01-16 11:00:00', 'active'),
(13, 'Boat Rockerz 450', 'Electronics', 1499.00, '2026-01-17 12:00:00', 'active'),
(14, 'Samsung 43 Inch Smart TV', 'Electronics', 32999.00, '2026-01-18 13:00:00', 'active'),
(15, 'LG 55 Inch Smart TV', 'Electronics', 54999.00, '2026-01-19 14:00:00', 'active'),
(16, 'Canon EOS 1500D Camera', 'Electronics', 42999.00, '2026-01-20 10:00:00', 'active'),
(17, 'Nikon DSLR Camera', 'Electronics', 51999.00, '2026-01-21 11:00:00', 'active'),
(18, 'Apple iPad 10th Generation', 'Electronics', 39999.00, '2026-01-22 12:00:00', 'active'),
(19, 'Samsung Galaxy Tab S9', 'Electronics', 52999.00, '2026-01-23 13:00:00', 'active'),
(20, 'Realme Pad 2', 'Electronics', 17999.00, '2026-01-24 14:00:00', 'active'),
(21, 'Logitech Wireless Mouse', 'Electronics', 799.00, '2026-01-25 10:00:00', 'active'),
(22, 'HP Wireless Keyboard', 'Electronics', 1299.00, '2026-01-26 11:00:00', 'active'),
(23, 'Samsung 1TB SSD', 'Electronics', 8999.00, '2026-01-27 12:00:00', 'active'),
(24, 'WD External Hard Drive', 'Electronics', 5499.00, '2026-01-28 13:00:00', 'active'),
(25, 'TP Link WiFi Router', 'Electronics', 2499.00, '2026-01-29 14:00:00', 'active'),
(26, 'Portronics Power Bank', 'Electronics', 1799.00, '2026-01-30 10:00:00', 'active'),
(27, 'Apple AirPods Pro', 'Electronics', 24999.00, '2026-01-31 11:00:00', 'active'),
(28, 'Noise Smart Watch', 'Electronics', 2999.00, '2026-02-01 12:00:00', 'active'),
(29, 'Mi 32 Inch Smart TV', 'Electronics', 16999.00, '2026-02-02 13:00:00', 'inactive'),
(30, 'Boat Airdopes 141', 'Electronics', 1299.00, '2026-02-03 14:00:00', 'inactive'),
(31, 'Men Cotton Casual Shirt', 'Fashion', 999.00, '2026-02-04 10:00:00', 'active'),
(32, 'Men Slim Fit Jeans', 'Fashion', 1499.00, '2026-02-05 11:00:00', 'active'),
(33, 'Women Floral Kurti', 'Fashion', 899.00, '2026-02-06 12:00:00', 'active'),
(34, 'Women Denim Jeans', 'Fashion', 1299.00, '2026-02-07 13:00:00', 'active'),
(35, 'Men Formal Trousers', 'Fashion', 1199.00, '2026-02-08 14:00:00', 'active'),
(36, 'Women Cotton Saree', 'Fashion', 1999.00, '2026-02-09 10:00:00', 'active'),
(37, 'Men Printed T Shirt', 'Fashion', 599.00, '2026-02-10 11:00:00', 'active'),
(38, 'Women Party Wear Dress', 'Fashion', 2499.00, '2026-02-11 12:00:00', 'active'),
(39, 'Men Leather Jacket', 'Fashion', 3499.00, '2026-02-12 13:00:00', 'active'),
(40, 'Women Winter Sweater', 'Fashion', 1599.00, '2026-02-13 14:00:00', 'active'),
(41, 'Men Track Pants', 'Fashion', 799.00, '2026-02-14 10:00:00', 'active'),
(42, 'Women Leggings', 'Fashion', 499.00, '2026-02-15 11:00:00', 'active'),
(43, 'Men Sports T Shirt', 'Fashion', 699.00, '2026-02-16 12:00:00', 'active'),
(44, 'Women Palazzo Pants', 'Fashion', 899.00, '2026-02-17 13:00:00', 'active'),
(45, 'Men Hooded Sweatshirt', 'Fashion', 1299.00, '2026-02-18 14:00:00', 'active'),
(46, 'Women Long Kurta', 'Fashion', 1199.00, '2026-02-19 10:00:00', 'active'),
(47, 'Men Casual Shorts', 'Fashion', 599.00, '2026-02-20 11:00:00', 'active'),
(48, 'Women Denim Jacket', 'Fashion', 1899.00, '2026-02-21 12:00:00', 'active'),
(49, 'Men Ethnic Kurta', 'Fashion', 1399.00, '2026-02-22 13:00:00', 'active'),
(50, 'Women Anarkali Dress', 'Fashion', 2799.00, '2026-02-23 14:00:00', 'active'),
(51, 'Men Checked Shirt', 'Fashion', 1099.00, '2026-02-24 10:00:00', 'active'),
(52, 'Women Printed Top', 'Fashion', 699.00, '2026-02-25 11:00:00', 'active'),
(53, 'Men Cargo Pants', 'Fashion', 1599.00, '2026-02-26 12:00:00', 'active'),
(54, 'Women Winter Coat', 'Fashion', 2999.00, '2026-02-27 13:00:00', 'inactive'),
(55, 'Men Blazer', 'Fashion', 3999.00, '2026-02-28 14:00:00', 'inactive'),
(56, 'Prestige Pressure Cooker', 'Home & Kitchen', 2499.00, '2026-03-01 10:00:00', 'active'),
(57, 'Philips Mixer Grinder', 'Home & Kitchen', 3299.00, '2026-03-02 11:00:00', 'active'),
(58, 'Bajaj Electric Kettle', 'Home & Kitchen', 1299.00, '2026-03-03 12:00:00', 'active'),
(59, 'Hawkins Non Stick Pan', 'Home & Kitchen', 999.00, '2026-03-04 13:00:00', 'active'),
(60, 'Milton Water Bottle', 'Home & Kitchen', 499.00, '2026-03-05 14:00:00', 'active'),
(61, 'Cello Dinner Set', 'Home & Kitchen', 1599.00, '2026-03-06 10:00:00', 'active'),
(62, 'Wakefit Memory Foam Pillow', 'Home & Kitchen', 1299.00, '2026-03-07 11:00:00', 'active'),
(63, 'Sleepwell Mattress', 'Home & Kitchen', 8999.00, '2026-03-08 12:00:00', 'active'),
(64, 'Godrej Storage Cabinet', 'Home & Kitchen', 5999.00, '2026-03-09 13:00:00', 'active'),
(65, 'IKEA Study Table', 'Home & Kitchen', 4499.00, '2026-03-10 14:00:00', 'active'),
(66, 'Amazon Basics Office Chair', 'Home & Kitchen', 6999.00, '2026-03-11 10:00:00', 'active'),
(67, 'Philips LED Table Lamp', 'Home & Kitchen', 899.00, '2026-03-12 11:00:00', 'active'),
(68, 'Havells Ceiling Fan', 'Home & Kitchen', 2499.00, '2026-03-13 12:00:00', 'active'),
(69, 'Kent Water Purifier', 'Home & Kitchen', 12999.00, '2026-03-14 13:00:00', 'active'),
(70, 'IFB Front Load Washing Machine', 'Home & Kitchen', 28999.00, '2026-03-15 14:00:00', 'active'),
(71, 'LG Refrigerator', 'Home & Kitchen', 24999.00, '2026-03-16 10:00:00', 'active'),
(72, 'Prestige Induction Cooktop', 'Home & Kitchen', 2199.00, '2026-03-17 11:00:00', 'active'),
(73, 'Pigeon Sandwich Maker', 'Home & Kitchen', 1199.00, '2026-03-18 12:00:00', 'active'),
(74, 'Home Centre Wall Clock', 'Home & Kitchen', 799.00, '2026-03-19 13:00:00', 'inactive'),
(75, 'Borosil Glass Set', 'Home & Kitchen', 699.00, '2026-03-20 14:00:00', 'inactive'),
(76, 'Python Programming for Beginners', 'Books', 499.00, '2026-03-21 10:00:00', 'active'),
(77, 'Learning SQL Database Design', 'Books', 599.00, '2026-03-22 11:00:00', 'active'),
(78, 'Machine Learning with Python', 'Books', 899.00, '2026-03-23 12:00:00', 'active'),
(79, 'Deep Learning Fundamentals', 'Books', 999.00, '2026-03-24 13:00:00', 'active'),
(80, 'Data Structures and Algorithms', 'Books', 699.00, '2026-03-25 14:00:00', 'active'),
(81, 'Introduction to Artificial Intelligence', 'Books', 799.00, '2026-03-26 10:00:00', 'active'),
(82, 'Rich Dad Poor Dad', 'Books', 299.00, '2026-03-27 11:00:00', 'active'),
(83, 'Atomic Habits', 'Books', 399.00, '2026-03-28 12:00:00', 'active'),
(84, 'The Psychology of Money', 'Books', 349.00, '2026-03-29 13:00:00', 'active'),
(85, 'Think and Grow Rich', 'Books', 249.00, '2026-03-30 14:00:00', 'active'),
(86, 'Clean Code', 'Books', 799.00, '2026-03-31 10:00:00', 'active'),
(87, 'The Pragmatic Programmer', 'Books', 899.00, '2026-04-01 11:00:00', 'active'),
(88, 'Computer Networks Fundamentals', 'Books', 649.00, '2026-04-02 12:00:00', 'active'),
(89, 'Operating System Concepts', 'Books', 999.00, '2026-04-03 13:00:00', 'active'),
(90, 'Database System Concepts', 'Books', 1099.00, '2026-04-04 14:00:00', 'active'),
(91, 'Introduction to Statistics', 'Books', 549.00, '2026-04-05 10:00:00', 'active'),
(92, 'The Alchemist', 'Books', 299.00, '2026-04-06 11:00:00', 'active'),
(93, 'Wings of Fire', 'Books', 250.00, '2026-04-07 12:00:00', 'active'),
(94, 'Effective Java', 'Books', 899.00, '2026-04-08 13:00:00', 'inactive'),
(95, 'HTML CSS and JavaScript Guide', 'Books', 499.00, '2026-04-09 14:00:00', 'inactive'),
(96, 'Yonex Badminton Racket', 'Sports', 1999.00, '2026-04-10 10:00:00', 'active'),
(97, 'Cosco Football', 'Sports', 899.00, '2026-04-11 11:00:00', 'active'),
(98, 'Nivia Basketball', 'Sports', 1199.00, '2026-04-12 12:00:00', 'active'),
(99, 'Strauss Cricket Bat', 'Sports', 2499.00, '2026-04-13 13:00:00', 'active'),
(100, 'SG Cricket Helmet', 'Sports', 1599.00, '2026-04-14 14:00:00', 'active'),
(101, 'Boldfit Yoga Mat', 'Sports', 799.00, '2026-04-15 10:00:00', 'active'),
(102, 'Decathlon Dumbbell Set', 'Sports', 2499.00, '2026-04-16 11:00:00', 'active'),
(103, 'Kobo Resistance Bands', 'Sports', 499.00, '2026-04-17 12:00:00', 'active'),
(104, 'Nivia Running Shoes', 'Sports', 2299.00, '2026-04-18 13:00:00', 'active'),
(105, 'Adidas Sports Bag', 'Sports', 1799.00, '2026-04-19 14:00:00', 'active'),
(106, 'Speedo Swimming Goggles', 'Sports', 999.00, '2026-04-20 10:00:00', 'active'),
(107, 'Vector X Volleyball', 'Sports', 799.00, '2026-04-21 11:00:00', 'active'),
(108, 'Cosco Skipping Rope', 'Sports', 299.00, '2026-04-22 12:00:00', 'active'),
(109, 'Fitness Exercise Cycle', 'Sports', 12999.00, '2026-04-23 13:00:00', 'inactive'),
(110, 'Cricket Practice Stumps', 'Sports', 699.00, '2026-04-24 14:00:00', 'inactive'),
(111, 'Lakme Sunscreen SPF 50', 'Beauty & Personal Care', 499.00, '2026-04-25 10:00:00', 'active'),
(112, 'Nivea Body Lotion', 'Beauty & Personal Care', 299.00, '2026-04-26 11:00:00', 'active'),
(113, 'Mamaearth Face Wash', 'Beauty & Personal Care', 249.00, '2026-04-27 12:00:00', 'active'),
(114, 'Minimalist Vitamin C Serum', 'Beauty & Personal Care', 699.00, '2026-04-28 13:00:00', 'active'),
(115, 'Maybelline Lipstick', 'Beauty & Personal Care', 399.00, '2026-04-29 14:00:00', 'active'),
(116, 'LOreal Shampoo', 'Beauty & Personal Care', 349.00, '2026-04-30 10:00:00', 'active'),
(117, 'Dove Conditioner', 'Beauty & Personal Care', 279.00, '2026-05-01 11:00:00', 'active'),
(118, 'Himalaya Face Cream', 'Beauty & Personal Care', 199.00, '2026-05-02 12:00:00', 'active'),
(119, 'Philips Hair Dryer', 'Beauty & Personal Care', 1499.00, '2026-05-03 13:00:00', 'active'),
(120, 'Vega Hair Straightener', 'Beauty & Personal Care', 1799.00, '2026-05-04 14:00:00', 'active'),
(121, 'Gillette Shaving Kit', 'Beauty & Personal Care', 599.00, '2026-05-05 10:00:00', 'active'),
(122, 'Cetaphil Gentle Cleanser', 'Beauty & Personal Care', 499.00, '2026-05-06 11:00:00', 'active'),
(123, 'Biotique Face Scrub', 'Beauty & Personal Care', 199.00, '2026-05-07 12:00:00', 'active'),
(124, 'Mamaearth Hair Oil', 'Beauty & Personal Care', 349.00, '2026-05-08 13:00:00', 'inactive'),
(125, 'Lakme Compact Powder', 'Beauty & Personal Care', 299.00, '2026-05-09 14:00:00', 'inactive'),
(126, 'Wildcraft Laptop Backpack', 'Accessories', 1999.00, '2026-05-10 10:00:00', 'active'),
(127, 'Fossil Analog Watch', 'Accessories', 6999.00, '2026-05-11 11:00:00', 'active'),
(128, 'Ray Ban Sunglasses', 'Accessories', 4999.00, '2026-05-12 12:00:00', 'active'),
(129, 'Leather Office Wallet', 'Accessories', 999.00, '2026-05-13 13:00:00', 'active'),
(130, 'Casio Digital Watch', 'Accessories', 1499.00, '2026-05-14 14:00:00', 'active'),
(131, 'American Tourister Trolley Bag', 'Accessories', 4999.00, '2026-05-15 10:00:00', 'active'),
(132, 'Skybags College Backpack', 'Accessories', 1299.00, '2026-05-16 11:00:00', 'active'),
(133, 'Fastrack Sunglasses', 'Accessories', 1199.00, '2026-05-17 12:00:00', 'active'),
(134, 'Leather Laptop Sleeve', 'Accessories', 899.00, '2026-05-18 13:00:00', 'active'),
(135, 'Woodland Leather Belt', 'Accessories', 999.00, '2026-05-19 14:00:00', 'active'),
(136, 'Titan Analog Watch', 'Accessories', 3499.00, '2026-05-20 10:00:00', 'active'),
(137, 'Travel Neck Pillow', 'Accessories', 599.00, '2026-05-21 11:00:00', 'active'),
(138, 'Safari Cabin Suitcase', 'Accessories', 2999.00, '2026-05-22 12:00:00', 'active'),
(139, 'Noise Smart Watch Strap', 'Accessories', 499.00, '2026-05-23 13:00:00', 'inactive'),
(140, 'Canvas Messenger Bag', 'Accessories', 1499.00, '2026-05-24 14:00:00', 'inactive'),
(141, 'Premium Leather Laptop Bag', 'Accessories', 2499.00, '2026-05-25 10:00:00', 'active'),
(142, 'Stainless Steel Water Bottle', 'Accessories', 699.00, '2026-05-26 11:00:00', 'active'),
(143, 'Men Classic Leather Wallet', 'Accessories', 899.00, '2026-05-27 12:00:00', 'active'),
(144, 'Women Handbag', 'Accessories', 1999.00, '2026-05-28 13:00:00', 'active'),
(145, 'Bluetooth Tracker Tag', 'Accessories', 1299.00, '2026-05-29 14:00:00', 'active'),
(146, 'Travel Duffel Bag', 'Accessories', 1799.00, '2026-05-30 10:00:00', 'active'),
(147, 'Polarized Sports Sunglasses', 'Accessories', 1499.00, '2026-05-31 11:00:00', 'active'),
(148, 'Adjustable Laptop Stand', 'Accessories', 999.00, '2026-06-01 12:00:00', 'active'),
(149, 'Premium Card Holder', 'Accessories', 599.00, '2026-06-02 13:00:00', 'inactive'),
(150, 'Smart Watch Protective Case', 'Accessories', 399.00, '2026-06-03 14:00:00', 'active')
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name);

INSERT INTO product_properties (product_id, property_name, property_value)
SELECT
    p.product_id,
    CASE
        WHEN p.category = 'Electronics' THEN ELT(n.n, 'Brand', 'Warranty', 'Connectivity')
        WHEN p.category = 'Fashion' THEN ELT(n.n, 'Brand', 'Size', 'Material')
        WHEN p.category = 'Books' THEN ELT(n.n, 'Author', 'Language', 'Format')
        WHEN p.category = 'Home & Kitchen' THEN ELT(n.n, 'Material', 'Color', 'Capacity')
        WHEN p.category = 'Sports' THEN ELT(n.n, 'Brand', 'Sport Type', 'Material')
        WHEN p.category = 'Beauty & Personal Care' THEN ELT(n.n, 'Brand', 'Skin Type', 'Volume')
        ELSE ELT(n.n, 'Brand', 'Material', 'Color')
    END,
    CASE
        WHEN p.category = 'Electronics' THEN
            ELT(MOD(p.product_id+n.n,5)+1, 'Samsung','Sony','Dell','HP','Lenovo')
        WHEN p.category = 'Fashion' AND n.n = 1 THEN
            ELT(MOD(p.product_id,5)+1, 'Nike','Adidas','Puma','Levis','Allen Solly')
        WHEN p.category = 'Fashion' AND n.n = 2 THEN
            ELT(MOD(p.product_id,5)+1, 'S','M','L','XL','XXL')
        WHEN p.category = 'Fashion' THEN
            ELT(MOD(p.product_id,4)+1, 'Cotton','Polyester','Denim','Cotton Blend')
        WHEN p.category = 'Books' AND n.n = 1 THEN
            ELT(MOD(p.product_id,5)+1, 'R. K. Narayan','Chetan Bhagat','A. P. J. Abdul Kalam','George Orwell','Paulo Coelho')
        WHEN p.category = 'Books' AND n.n = 2 THEN 'English'
        WHEN p.category = 'Books' THEN 'Paperback'
        WHEN p.category = 'Home & Kitchen' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Stainless Steel','Plastic','Glass','Ceramic')
        WHEN p.category = 'Home & Kitchen' AND n.n = 2 THEN
            ELT(MOD(p.product_id,4)+1, 'Black','White','Silver','Blue')
        WHEN p.category = 'Home & Kitchen' THEN '1 Litre'
        WHEN p.category = 'Sports' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Nike','Adidas','Puma','Decathlon')
        WHEN p.category = 'Sports' AND n.n = 2 THEN 'Fitness'
        WHEN p.category = 'Sports' THEN 'Rubber'
        WHEN p.category = 'Beauty & Personal Care' AND n.n = 1 THEN
            ELT(MOD(p.product_id,4)+1, 'Nivea','Dove','Lakme','Mamaearth')
        WHEN p.category = 'Beauty & Personal Care' AND n.n = 2 THEN 'All Skin Types'
        WHEN p.category = 'Beauty & Personal Care' THEN '100 ml'
        ELSE
            ELT(MOD(p.product_id,4)+1, 'Boat','Noise','Portronics','Amazon Basics')
    END
FROM products p
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
WHERE NOT EXISTS (SELECT 1 FROM product_properties pp WHERE pp.product_id = p.product_id);

INSERT INTO product_availability (product_id, stock_quantity, availability_status, effective_from, effective_to)
SELECT
    p.product_id,
    CASE WHEN s.snapshot = 1 THEN 10 + MOD(p.product_id * 7, 80) ELSE MOD(p.product_id * 13, 60) END,
    CASE WHEN MOD(p.product_id * 13, 60) = 0 AND s.snapshot = 2 THEN 'out_of_stock' ELSE 'available' END,
    CASE WHEN s.snapshot = 1 THEN DATE_SUB(NOW(), INTERVAL 30 DAY) ELSE DATE_SUB(NOW(), INTERVAL 15 DAY) END,
    CASE WHEN s.snapshot = 1 THEN DATE_SUB(NOW(), INTERVAL 15 DAY) ELSE NULL END
FROM products p
CROSS JOIN (SELECT 1 AS snapshot UNION ALL SELECT 2) s
WHERE NOT EXISTS (SELECT 1 FROM product_availability pa WHERE pa.product_id = p.product_id);

INSERT INTO user_events (source_event_id, user_id, product_id, event_type, event_timestamp, ingestion_timestamp)
SELECT
    CONCAT('SRC-', x.n + 1),
    1 + MOD(x.n, 100),
    1 + MOD(x.n * 7, 150),
    CASE
        WHEN MOD(x.n, 100) < 45 THEN 'impression'
        WHEN MOD(x.n, 100) < 75 THEN 'view'
        WHEN MOD(x.n, 100) < 90 THEN 'click'
        WHEN MOD(x.n, 100) < 97 THEN 'add_to_cart'
        ELSE 'wishlist'
    END,
    DATE_SUB(NOW(), INTERVAL MOD(x.n, 30) DAY),
    DATE_ADD(DATE_SUB(NOW(), INTERVAL MOD(x.n, 30) DAY), INTERVAL 5 MINUTE)
FROM (
    SELECT a.d * 100 + b.d * 10 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
) x
WHERE NOT EXISTS (SELECT 1 FROM user_events WHERE event_id = 1);

INSERT INTO user_events (source_event_id, user_id, product_id, event_type, event_timestamp, ingestion_timestamp)
SELECT
    source_event_id,
    user_id,
    product_id,
    event_type,
    event_timestamp,
    DATE_ADD(ingestion_timestamp, INTERVAL 10 MINUTE)
FROM user_events
WHERE event_id IN (10, 20, 30, 40, 50)
  AND (SELECT COUNT(*) FROM user_events WHERE source_event_id = 'SRC-11') <= 1;

INSERT INTO orders (user_id, order_date, order_status, total_amount)
SELECT
    1 + MOD(x.n * 3, 100),
    DATE_SUB(NOW(), INTERVAL (MOD(x.n, 45) + 1) DAY),
    CASE
        WHEN MOD(x.n, 10) <= 6 THEN 'delivered'
        WHEN MOD(x.n, 10) = 7 THEN 'shipped'
        WHEN MOD(x.n, 10) = 8 THEN 'confirmed'
        ELSE 'pending'
    END,
    0.00
FROM (
    SELECT a.d * 20 + b.d * 2 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1) c
) x
WHERE x.n < 200
  AND NOT EXISTS (SELECT 1 FROM orders WHERE order_id = 1);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    CASE WHEN x.n < 200 THEN x.n + 1 ELSE x.n - 199 END,
    p.product_id,
    1 + MOD(x.n, 3),
    p.price
FROM (
    SELECT a.d * 100 + b.d * 10 + c.d AS n
    FROM (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2) c
) x
JOIN products p ON p.product_id = 1 + MOD(x.n * 7, 150)
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_item_id = 1);

UPDATE orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS calculated_total
    FROM order_items
    GROUP BY order_id
) oi ON o.order_id = oi.order_id
SET o.total_amount = oi.calculated_total;

INSERT INTO returns (order_item_id, return_date, return_quantity, return_reason)
SELECT
    oi.order_item_id,
    DATE_ADD(o.order_date, INTERVAL 2 DAY),
    1,
    ELT(MOD(oi.order_item_id, 5) + 1, 'damaged', 'wrong_item', 'size_or_fit', 'changed_mind', 'other')
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND oi.quantity >= 1
  AND NOT EXISTS (SELECT 1 FROM returns WHERE return_id = 1)
ORDER BY oi.order_item_id
LIMIT 30;

-- ------------------------------------------------------------------------------
-- 5. EVENT DEDUPLICATION
-- ------------------------------------------------------------------------------
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

ALTER TABLE clean_user_events ADD PRIMARY KEY (event_id);
CREATE INDEX idx_clean_events_user_prod_time ON clean_user_events (user_id, product_id, event_timestamp);

-- ------------------------------------------------------------------------------
-- 6. BEHAVIORAL FEEDBACK SCORING
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS interaction_events;

CREATE TABLE interaction_events AS
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

CREATE INDEX idx_interaction_user_prod_time ON interaction_events (user_id, product_id, interaction_time);
CREATE INDEX idx_interaction_behavior ON interaction_events (behavior, feedback_type);

-- ------------------------------------------------------------------------------
-- 7. USER-ITEM INTERACTION MATRIX
-- ------------------------------------------------------------------------------
SET @train_cutoff = COALESCE(@train_cutoff, DATE_SUB(NOW(), INTERVAL 7 DAY));
SET @window_start = COALESCE(@window_start, DATE_SUB(NOW(), INTERVAL 37 DAY));

DROP TABLE IF EXISTS user_item_interactions;

CREATE TABLE user_item_interactions AS
SELECT
    user_id,
    product_id,
    COUNT(*) AS total_interactions,
    SUM(CASE WHEN behavior = 'impression'  THEN 1 ELSE 0 END) AS impression_count,
    SUM(CASE WHEN behavior = 'view'        THEN 1 ELSE 0 END) AS view_count,
    SUM(CASE WHEN behavior = 'click'       THEN 1 ELSE 0 END) AS click_count,
    SUM(CASE WHEN behavior = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_count,
    SUM(CASE WHEN behavior = 'wishlist'    THEN 1 ELSE 0 END) AS wishlist_count,
    SUM(CASE WHEN behavior = 'purchase'    THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN behavior = 'return'      THEN 1 ELSE 0 END) AS return_count,

    SUM(CASE WHEN feedback_type = 'positive' THEN 1 ELSE 0 END) AS positive_interactions,
    SUM(CASE WHEN feedback_type = 'negative' THEN 1 ELSE 0 END) AS negative_interactions,
    SUM(CASE WHEN feedback_type = 'neutral'  THEN 1 ELSE 0 END) AS neutral_interactions,

    ROUND(SUM(feedback_weight), 2) AS interaction_score,
    MIN(interaction_time) AS first_interaction,
    MAX(interaction_time) AS last_interaction,
    ROUND(DATEDIFF(@train_cutoff, MAX(interaction_time)), 1) AS recency_days_at_cutoff,

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

ALTER TABLE user_item_interactions ADD PRIMARY KEY (user_id, product_id);
CREATE INDEX idx_user_item_score ON user_item_interactions (interaction_score DESC);
CREATE INDEX idx_user_item_state ON user_item_interactions (behavioral_state);

-- ------------------------------------------------------------------------------
-- 8. PRODUCT POPULARITY & FRESHNESS
-- ------------------------------------------------------------------------------
SET @cold_start_threshold = 5;

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

        ROUND(
            (SUM(CASE WHEN ie.behavior = 'purchase' THEN 1 ELSE 0 END) * 5.0) +
            (SUM(CASE WHEN ie.behavior = 'add_to_cart' THEN 1 ELSE 0 END) * 3.0) +
            (SUM(CASE WHEN ie.behavior = 'click' THEN 1 ELSE 0 END) * 2.0) +
            (SUM(CASE WHEN ie.behavior = 'view' THEN 1 ELSE 0 END) * 1.0) -
            (SUM(CASE WHEN ie.behavior = 'return' THEN 1 ELSE 0 END) * 3.0)
        , 2) AS popularity_score,

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

    CASE
        WHEN product_age_days <= 14 THEN 'NEW_RELEASE'
        WHEN product_age_days <= 45 THEN 'GROWTH'
        ELSE 'MATURE_CATALOG'
    END AS freshness_tier,

    CASE
        WHEN total_interactions < @cold_start_threshold THEN 'COLD_START_INSUFFICIENT'
        ELSE 'WARM_INTERACTION_HISTORY'
    END AS interaction_sufficiency,

    DENSE_RANK() OVER (
        PARTITION BY category, analytical_period
        ORDER BY popularity_score DESC, total_interactions DESC
    ) AS category_popularity_rank

FROM product_period_metrics;

ALTER TABLE product_popularity ADD PRIMARY KEY (product_id, analytical_period);
CREATE INDEX idx_popularity_cat_rank ON product_popularity (category, category_popularity_rank);

-- ------------------------------------------------------------------------------
-- 9. USER ACTIVITY PROFILES
-- ------------------------------------------------------------------------------
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

    CASE
        WHEN total_interactions >= 25 THEN 'HIGHLY_ACTIVE'
        WHEN total_interactions >= 10 THEN 'MODERATELY_ACTIVE'
        WHEN total_interactions >= 1  THEN 'LOW_ACTIVITY'
        ELSE 'INACTIVE'
    END AS activity_tier

FROM user_aggregates;

ALTER TABLE user_activity_profiles ADD PRIMARY KEY (user_id);
CREATE INDEX idx_user_activity_tier ON user_activity_profiles (activity_tier);

-- ------------------------------------------------------------------------------
-- 10. HISTORICAL INTERACTION SNAPSHOTS
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

-- ------------------------------------------------------------------------------
-- 11. RECOMMENDATION CANDIDATES & AVAILABILITY CONSTRAINTS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS recommendation_candidates;

CREATE TABLE recommendation_candidates AS
WITH available_products_at_cutoff AS (
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
    SELECT DISTINCT
        o.user_id,
        oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN returns r ON oi.order_item_id = r.order_item_id AND r.return_date <= @train_cutoff
    WHERE o.order_date <= @train_cutoff
      AND o.order_status IN ('confirmed', 'shipped', 'delivered')
      AND r.return_id IS NULL
)
SELECT
    u.user_id,
    ap.product_id,
    ap.product_name,
    ap.category,
    ap.price,
    ap.stock_quantity AS available_stock_at_cutoff,
    CAST(@train_cutoff AS DATETIME) AS prediction_cutoff_time,
    CASE
        WHEN ui.user_id IS NOT NULL THEN 'PREVIOUSLY_VIEWED_ENGAGED'
        ELSE 'UNOBSERVED_DISCOVERY'
    END AS candidate_affinity_type
FROM users u
CROSS JOIN available_products_at_cutoff ap
LEFT JOIN user_prior_purchases upp
    ON u.user_id = upp.user_id
   AND ap.product_id = upp.product_id
LEFT JOIN user_item_interactions ui
    ON u.user_id = ui.user_id
   AND ap.product_id = ui.product_id
WHERE u.user_status = 'active'
  AND upp.product_id IS NULL;

ALTER TABLE recommendation_candidates ADD PRIMARY KEY (user_id, product_id);

-- ------------------------------------------------------------------------------
-- 12. DETERMINISTIC NEGATIVE SAMPLING
-- ------------------------------------------------------------------------------
SET @eval_cutoff = COALESCE(@eval_cutoff, NOW());
SET @negatives_per_user = 5;
SET @sampling_seed = 'RECOMMENDER_SEED_2026';

DROP TABLE IF EXISTS negative_sampling_candidates;

CREATE TABLE negative_sampling_candidates AS
WITH held_out_future_test_items AS (
    SELECT DISTINCT user_id, product_id
    FROM interaction_events
    WHERE interaction_time > @train_cutoff
      AND interaction_time <= @eval_cutoff
      AND feedback_type = 'positive'
),
ranked_unobserved_candidates AS (
    SELECT
        rc.user_id,
        rc.product_id,
        rc.category,
        rc.price,
        rc.available_stock_at_cutoff,
        CAST(@train_cutoff AS DATETIME) AS prediction_cutoff_time,
        ROW_NUMBER() OVER (
            PARTITION BY rc.user_id
            ORDER BY MD5(CONCAT(rc.user_id, ':', rc.product_id, ':', @sampling_seed))
        ) AS sample_rank
    FROM recommendation_candidates rc
    LEFT JOIN user_item_interactions ui
        ON rc.user_id = ui.user_id
       AND rc.product_id = ui.product_id
       AND ui.interaction_score > 0
    LEFT JOIN held_out_future_test_items hti
        ON rc.user_id = hti.user_id
       AND rc.product_id = hti.product_id
    WHERE ui.product_id IS NULL
      AND hti.product_id IS NULL
)
SELECT
    user_id,
    product_id,
    category,
    price,
    available_stock_at_cutoff,
    prediction_cutoff_time,
    sample_rank,
    'SAMPLED_UNOBSERVED_NEGATIVE' AS feedback_classification
FROM ranked_unobserved_candidates
WHERE sample_rank <= @negatives_per_user;

ALTER TABLE negative_sampling_candidates ADD PRIMARY KEY (user_id, product_id);

-- ------------------------------------------------------------------------------
-- 13. CHRONOLOGICAL TRAIN/TEST SPLIT
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS train_interactions;

CREATE TABLE train_interactions AS
SELECT
    user_id,
    product_id,
    interaction_time,
    behavior,
    feedback_weight,
    feedback_type,
    'TRAIN' AS dataset_split
FROM interaction_events
WHERE interaction_time >= @window_start
  AND interaction_time <= @train_cutoff;

DROP TABLE IF EXISTS test_interactions;

CREATE TABLE test_interactions AS
SELECT
    user_id,
    product_id,
    interaction_time,
    behavior,
    feedback_weight,
    feedback_type,
    'TEST_HELD_OUT' AS dataset_split
FROM interaction_events
WHERE interaction_time > @train_cutoff
  AND interaction_time <= @eval_cutoff;

DROP TABLE IF EXISTS test_ground_truth_relevant;

CREATE TABLE test_ground_truth_relevant AS
SELECT
    user_id,
    product_id,
    COUNT(*) AS test_interactions_count,
    SUM(CASE WHEN behavior = 'purchase' THEN 1 ELSE 0 END) AS test_purchases,
    SUM(CASE WHEN behavior IN ('click', 'view', 'add_to_cart') THEN 1 ELSE 0 END) AS test_engagements,
    ROUND(SUM(feedback_weight), 2) AS test_implicit_score,
    MIN(interaction_time) AS first_test_interaction,
    1 AS is_relevant
FROM test_interactions
WHERE feedback_type = 'positive'
GROUP BY user_id, product_id;

ALTER TABLE test_ground_truth_relevant ADD PRIMARY KEY (user_id, product_id);

-- ------------------------------------------------------------------------------
-- 14. EVALUATION BENCHMARK DATASETS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS evaluation_ranking_dataset;

CREATE TABLE evaluation_ranking_dataset AS
SELECT
    gtr.user_id,
    gtr.product_id,
    p.category,
    p.price,
    gtr.test_purchases,
    gtr.test_engagements,
    gtr.test_implicit_score,
    1 AS is_relevant,
    'HELD_OUT_POSITIVE' AS evaluation_label,
    CAST(@train_cutoff AS DATETIME) AS evaluation_cutoff_time
FROM test_ground_truth_relevant gtr
JOIN products p ON gtr.product_id = p.product_id

UNION ALL

SELECT
    nsc.user_id,
    nsc.product_id,
    nsc.category,
    nsc.price,
    0 AS test_purchases,
    0 AS test_engagements,
    0.00 AS test_implicit_score,
    0 AS is_relevant,
    'SAMPLED_NEGATIVE' AS evaluation_label,
    CAST(@train_cutoff AS DATETIME) AS evaluation_cutoff_time
FROM negative_sampling_candidates nsc;

ALTER TABLE evaluation_ranking_dataset ADD PRIMARY KEY (user_id, product_id);

DROP TABLE IF EXISTS evaluation_user_summary;

CREATE TABLE evaluation_user_summary AS
SELECT
    user_id,
    COUNT(*) AS total_evaluation_candidates,
    SUM(CASE WHEN is_relevant = 1 THEN 1 ELSE 0 END) AS held_out_relevant_items,
    SUM(CASE WHEN is_relevant = 0 THEN 1 ELSE 0 END) AS sampled_negative_items,
    ROUND(SUM(CASE WHEN is_relevant = 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS base_hit_opportunity_ratio
FROM evaluation_ranking_dataset
GROUP BY user_id;

ALTER TABLE evaluation_user_summary ADD PRIMARY KEY (user_id);

-- ------------------------------------------------------------------------------
-- 15. DOWNSTREAM MODEL EXPORT VIEWS
-- ------------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------------
-- 16. VALIDATION AND AUDIT ASSERTIONS
-- ------------------------------------------------------------------------------
SELECT
    'TEST-01: Table Creation & Population' AS test_id,
    CASE WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'recommendation_engine') >= 12 THEN 'PASS' ELSE 'FAIL' END AS status,
    CONCAT((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'recommendation_engine'), ' tables/views verified') AS details
UNION ALL
SELECT
    'TEST-02: Telemetry Ingestion Deduplication',
    CASE WHEN (SELECT COUNT(*) - COUNT(DISTINCT source_event_id) FROM clean_user_events) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Zero duplicated source_event_id records present in clean_user_events'
UNION ALL
SELECT
    'TEST-03: Implicit Feedback Bounds',
    CASE
        WHEN (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'positive' AND feedback_weight <= 0) = 0
         AND (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'negative' AND feedback_weight >= 0) = 0
         AND (SELECT COUNT(*) FROM interaction_events WHERE feedback_type = 'neutral'  AND feedback_weight != 0) = 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    'Weights adhere strictly to feedback taxonomy (+5/+3/+2/+1 for positive, 0 for neutral, -3 for negative)'
UNION ALL
SELECT
    'TEST-04: Historical Feature Temporal Leakage',
    CASE WHEN (SELECT COUNT(*) FROM user_item_interactions WHERE last_interaction > @train_cutoff) = 0 THEN 'PASS' ELSE 'FAIL' END,
    'Zero future interactions contaminated the historical training matrix'
UNION ALL
SELECT
    'TEST-05: Point-in-Time Availability Enforcement',
    CASE 
        WHEN (
            SELECT COUNT(*) 
            FROM recommendation_candidates rc
            JOIN product_availability pa 
              ON rc.product_id = pa.product_id
             AND pa.effective_from <= @train_cutoff
             AND (pa.effective_to IS NULL OR pa.effective_to > @train_cutoff)
            WHERE pa.availability_status = 'out_of_stock' OR pa.stock_quantity <= 0
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    'Zero out-of-stock items entered the candidate recommendation pool'
UNION ALL
SELECT
    'TEST-06: Prior Purchase Candidate Exclusion',
    CASE 
        WHEN (
            SELECT COUNT(*)
            FROM recommendation_candidates rc
            JOIN user_item_interactions uii
              ON rc.user_id = uii.user_id
             AND rc.product_id = uii.product_id
            WHERE uii.behavioral_state = 'PURCHASED_AND_RETAINED'
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    'Prior retained purchases are 100% excluded from candidate sets'
UNION ALL
SELECT
    'TEST-07: Negative Sampling Contamination Audit',
    CASE 
        WHEN (
            SELECT COUNT(*)
            FROM negative_sampling_candidates nsc
            JOIN test_ground_truth_relevant gtr
              ON nsc.user_id = gtr.user_id
             AND nsc.product_id = gtr.product_id
        ) = 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    'Zero ground-truth evaluation positives leaked into sampled negative distractors'
UNION ALL
SELECT
    'TEST-08: Evaluation Candidate Set Structural Integrity',
    CASE 
        WHEN (SELECT COUNT(*) FROM evaluation_user_summary WHERE total_evaluation_candidates <= 0) = 0
         AND (SELECT COUNT(*) FROM evaluation_user_summary) > 0
        THEN 'PASS' ELSE 'FAIL'
    END,
    CONCAT((SELECT COUNT(*) FROM evaluation_user_summary), ' evaluated users have properly structured candidate benchmarks');
