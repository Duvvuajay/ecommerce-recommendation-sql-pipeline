# Database Design & Architecture Document
## E-Commerce Recommendation Engine Relational Database Specification

### 1. Database Schema Overview
- **Database Name**: `recommendation_engine`
- **RDBMS Engine**: MySQL 8.0+ (InnoDB)
- **Character Set**: `utf8mb4`
- **Collation**: `utf8mb4_0900_ai_ci`
- **Design Philosophy**: High normalization (3NF) for transaction processing and data consistency, augmented with optimized indexing and temporal interval tracking for point-in-time analytical transformations.

---

### 2. Entity Specifications

#### 2.1 Table: `users`
Captures registered platform customers.
- `user_id` (INT, PK, AUTO_INCREMENT): Unique customer identifier.
- `user_name` (VARCHAR(100), NOT NULL): Customer display name.
- `email` (VARCHAR(150), NOT NULL, UNIQUE): Unique email identifier.
- `registration_date` (DATETIME, NOT NULL): Account creation timestamp.
- `city` (VARCHAR(100)): Primary location for regional analysis.
- `user_status` (ENUM('active', 'inactive'), DEFAULT 'active'): Account active status.

#### 2.2 Table: `products`
The base catalog of items available for recommendation.
- `product_id` (INT, PK, AUTO_INCREMENT): Unique item identifier.
- `product_name` (VARCHAR(150), NOT NULL): Item title.
- `category` (VARCHAR(100), NOT NULL): Item retail category (Electronics, Fashion, Home & Kitchen, Books, Sports, Beauty, Accessories).
- `price` (DECIMAL(10,2), NOT NULL, CHECK price >= 0): Listed price.
- `created_at` (DATETIME, NOT NULL): Catalog insertion timestamp.
- `product_status` (ENUM('active', 'inactive'), DEFAULT 'active'): Commercial status.

#### 2.3 Table: `product_properties`
Key-value metadata supporting Content-Based Filtering.
- `property_id` (INT, PK, AUTO_INCREMENT): Property record ID.
- `product_id` (INT, NOT NULL, FK -> `products.product_id`): Parent product reference.
- `property_name` (VARCHAR(100), NOT NULL): Attribute name (e.g., Brand, Warranty, Material, Color, Author).
- `property_value` (VARCHAR(200), NOT NULL): Attribute value.

#### 2.4 Table: `product_availability`
Slowly Changing Dimension (SCD Type 2) preserving inventory history over time.
- `availability_id` (INT, PK, AUTO_INCREMENT): Snapshot record ID.
- `product_id` (INT, NOT NULL, FK -> `products.product_id`): Item reference.
- `stock_quantity` (INT, NOT NULL, CHECK stock_quantity >= 0): Available stock units.
- `availability_status` (ENUM('available', 'out_of_stock'), NOT NULL): Point-in-time availability flag.
- `effective_from` (DATETIME, NOT NULL): Start of valid interval.
- `effective_to` (DATETIME, NULL): End of valid interval (NULL if currently open).

#### 2.5 Table: `user_events`
Raw clickstream and behavioral telemetry.
- `event_id` (INT, PK, AUTO_INCREMENT): Internal surrogate key.
- `source_event_id` (VARCHAR(100), NOT NULL): Upstream telemetry ID used for deduplication.
- `user_id` (INT, NOT NULL, FK -> `users.user_id`): Customer identifier.
- `product_id` (INT, NOT NULL, FK -> `products.product_id`): Target item.
- `event_type` (ENUM('impression', 'view', 'click', 'add_to_cart', 'wishlist'), NOT NULL): Behavioral event.
- `event_timestamp` (DATETIME, NOT NULL): Client-side event generation timestamp.
- `ingestion_timestamp` (DATETIME, NOT NULL): Server-side ingestion timestamp.

#### 2.6 Table: `orders`
Header table for transactional sales.
- `order_id` (INT, PK, AUTO_INCREMENT): Order number.
- `user_id` (INT, NOT NULL, FK -> `users.user_id`): Purchasing user.
- `order_date` (DATETIME, NOT NULL): Timestamp of checkout.
- `order_status` (ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'), DEFAULT 'pending'): Fulfillment state.
- `total_amount` (DECIMAL(10,2), NOT NULL, DEFAULT 0.00): Total monetary value.

#### 2.7 Table: `order_items`
Line-item detail for completed purchases.
- `order_item_id` (INT, PK, AUTO_INCREMENT): Line item identifier.
- `order_id` (INT, NOT NULL, FK -> `orders.order_id`): Parent order reference.
- `product_id` (INT, NOT NULL, FK -> `products.product_id`): Purchased product.
- `quantity` (INT, NOT NULL, CHECK quantity > 0): Units purchased.
- `unit_price` (DECIMAL(10,2), NOT NULL): Price per unit at purchase time.

#### 2.8 Table: `returns`
Reverse logistics tracking returned merchandise.
- `return_id` (INT, PK, AUTO_INCREMENT): Return record identifier.
- `order_item_id` (INT, NOT NULL, FK -> `order_items.order_item_id`): Target order line.
- `return_date` (DATETIME, NOT NULL): Timestamp when return was registered.
- `return_quantity` (INT, NOT NULL, CHECK return_quantity > 0): Number of returned units.
- `return_reason` (ENUM('damaged', 'wrong_item', 'size_or_fit', 'changed_mind', 'other'), NOT NULL): Justification.

---

### 3. Database Normalization Analysis
- **First Normal Form (1NF)**: Every table has an explicit primary key, all columns hold atomic values, and no repeating groups exist.
- **Second Normal Form (2NF)**: All non-key attributes depend entirely on the primary key (no partial dependencies on composite keys).
- **Third Normal Form (3NF)**: No transitive dependencies exist. For example, order totals are derived from order items, customer attributes reside strictly in `users`, and product metadata resides in `products` and `product_properties`.

---

### 4. Indexing Strategy for Analytical Transformations
- `idx_user_events_dedup`: `(source_event_id, ingestion_timestamp)` for fast windowed deduplication.
- `idx_user_events_user_prod_time`: `(user_id, product_id, event_timestamp)` for point-in-time lookups.
- `idx_orders_user_time`: `(user_id, order_date, order_status)` for transactional customer histories.
- `idx_availability_prod_intervals`: `(product_id, effective_from, effective_to)` for high-speed SCD Type 2 point-in-time point-in-interval temporal joins.
