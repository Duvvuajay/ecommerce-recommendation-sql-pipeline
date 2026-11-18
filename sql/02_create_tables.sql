-- ==============================================================================
-- Module 02: Table Definitions (Core Relational Schema)
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

USE recommendation_engine;

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    registration_date DATETIME NOT NULL,
    city VARCHAR(100),
    user_status ENUM('active', 'inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL,
    product_status ENUM('active', 'inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. PRODUCT PROPERTIES TABLE (Content-Based Metadata)
CREATE TABLE IF NOT EXISTS product_properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    property_name VARCHAR(100) NOT NULL,
    property_value VARCHAR(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. PRODUCT AVAILABILITY TABLE (SCD Type 2 Historical Inventory)
CREATE TABLE IF NOT EXISTS product_availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    stock_quantity INT NOT NULL,
    availability_status ENUM('available', 'out_of_stock') NOT NULL,
    effective_from DATETIME NOT NULL,
    effective_to DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. USER EVENTS TABLE (Raw Telemetry / Clickstream)
CREATE TABLE IF NOT EXISTS user_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    source_event_id VARCHAR(100) NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    event_type ENUM('impression', 'view', 'click', 'add_to_cart', 'wishlist') NOT NULL,
    event_timestamp DATETIME NOT NULL,
    ingestion_timestamp DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. ORDERS TABLE (Sales Transactions Header)
CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. ORDER ITEMS TABLE (Sales Line Items Detail)
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. RETURNS TABLE (Post-Purchase Reversals)
CREATE TABLE IF NOT EXISTS returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    return_date DATETIME NOT NULL,
    return_quantity INT NOT NULL,
    return_reason ENUM('damaged', 'wrong_item', 'size_or_fit', 'changed_mind', 'other') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
