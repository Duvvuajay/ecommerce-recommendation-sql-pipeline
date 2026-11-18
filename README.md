# Project 38: E-Commerce Recommendation Engine Dataset Pipeline
### Behavioral and Transactional SQL Data Preparation System
**Database Engine**: MySQL 8.0+ | **Design Paradigm**: 3NF Relational + SCD Type 2 Temporal + Leakage-Free Analytics

---

## 1. Project Overview & Business Problem
Modern e-commerce platforms rely on recommendation models (Collaborative Filtering, Deep Learning, Hybrid Popularity) to serve personalized product catalogs to customers. However, training models directly on raw, messy transactional and telemetry logs leads to catastrophic real-world failures:
- **Telemetry Ingestion Retries**: Redundant network payloads duplicate events without reflecting genuine customer actions.
- **Temporal Data Leakage**: Conventional random train/test splits bleed future customer actions into historical features, giving inflated, unrepresentative offline metrics.
- **Inventory Mismatch**: Recommending items that were out-of-stock or discontinued at prediction time.
- **Lack of Negative Contrast**: Implicit feedback systems capture primarily positive actions, requiring principled negative sampling to train ranking algorithms.

This project implements a complete, reproducible, production-grade SQL data preparation pipeline in MySQL 8.0 that transforms raw clickstream and transactional logs into clean, point-in-time, leakage-free datasets ready for downstream machine learning.

---

## 2. Relational Architecture & Database Design
The system runs on the `recommendation_engine` database using the **InnoDB** storage engine with full 3NF normalization.

### Core Tables
1. **`users`**: Registered platform customers (`user_id`, `user_name`, `email`, `registration_date`, `city`, `user_status`).
2. **`products`**: Merchandising catalog across 7 retail categories (`product_id`, `product_name`, `category`, `price`, `created_at`, `product_status`).
3. **`product_properties`**: Key-value attribute metadata for Content-Based Modeling (`property_id`, `product_id`, `property_name`, `property_value`).
4. **`product_availability`**: Slowly Changing Dimension (SCD Type 2) tracking historical stock intervals (`availability_id`, `product_id`, `stock_quantity`, `availability_status`, `effective_from`, `effective_to`).
5. **`user_events`**: Raw telemetry clickstream (`event_id`, `source_event_id`, `user_id`, `product_id`, `event_type`, `event_timestamp`, `ingestion_timestamp`).
6. **`orders`**: Sales transaction headers (`order_id`, `user_id`, `order_date`, `order_status`, `total_amount`).
7. **`order_items`**: Line-item transaction details (`order_item_id`, `order_id`, `product_id`, `quantity`, `unit_price`).
8. **`returns`**: Reverse logistics records (`return_id`, `order_item_id`, `return_date`, `return_quantity`, `return_reason`).

---

## 3. Project Directory Structure
```
project__38/
├── documentation/
│   ├── Project_Requirements.md         # Full requirements specification
│   ├── Requirement_Checklist.md        # Mapping each task to implementation
│   ├── Database_Design.md              # 3NF schema, tables, constraints, indexes
│   ├── Business_Rules.md               # Analytical business logic & rules
│   ├── Feedback_Weighting_Policy.md    # Implicit scoring taxonomy & math
│   ├── Candidate_Sampling_Policy.md    # Candidate generation & negative sampling
│   └── Temporal_Evaluation_Design.md   # Time-aware split & anti-leakage rules
│
├── sql/
│   ├── 01_create_database.sql          # Database initialization
│   ├── 02_create_tables.sql            # Table DDL definitions
│   ├── 03_constraints_and_indexes.sql  # Foreign keys and analytical indexes
│   ├── 04_insert_sample_data.sql       # High-fidelity realistic dataset
│   ├── 05_event_deduplication.sql      # Windowed telemetry deduplication
│   ├── 06_feedback_scoring.sql         # Unified interaction events taxonomy
│   ├── 07_user_item_interactions.sql   # Interaction matrix & behavioral states
│   ├── 08_product_popularity.sql       # Category ranking & cold-start tagging
│   ├── 09_user_activity_profiles.sql   # Customer engagement tiers
│   ├── 10_historical_snapshots.sql     # Point-in-time temporal freeze
│   ├── 11_candidate_generation.sql     # Available candidate pool generation
│   ├── 12_negative_sampling.sql        # Deterministic MD5 negative sampling
│   ├── 13_temporal_train_test_split.sql# Time-aware train/test separation
│   ├── 14_evaluation_datasets.sql      # Benchmark ranking evaluation dataset
│   ├── 15_model_exports.sql            # Collaborative, Popularity, Content views
│   ├── 16_testing_and_validation.sql   # Comprehensive test & assertion suite
│   └── run_all_pipeline.sql            # Master end-to-end execution script
│
├── reports/
│   ├── implementation_report.md        # Architecture & methodology report
│   ├── testing_report.md               # Test cases and execution evidence
│   ├── performance_report.md           # Query optimization & EXPLAIN review
│   ├── query_results.md                # Output tables and sample query results
│   └── final_requirement_audit.md      # 100% compliance audit matrix
│
├── diagrams/
│   └── database_er_diagram.md          # Complete Mermaid ER diagram
│
└── README.md                           # Master project guide (this document)
```

---

## 4. Analytical Pipeline Methodology

### 4.1 Ingestion Deduplication vs. Genuine User Actions
Telemetry streams often duplicate events due to client retries. In `05_event_deduplication.sql`, technical duplicates sharing the same `source_event_id` are removed via:
```sql
ROW_NUMBER() OVER (
    PARTITION BY source_event_id 
    ORDER BY ingestion_timestamp ASC, event_id ASC
)
```
Genuine repeated actions across distinct user sessions have distinct `source_event_id` keys and are strictly retained.

### 4.2 Behavioral Feedback Classification
In `06_feedback_scoring.sql`, interactions are unified and weighted:
- `purchase`: **+5.0** (High-intent financial conversion)
- `add_to_cart` / `wishlist`: **+3.0** (Strong prospective affinity)
- `click`: **+2.0** (Active engagement)
- `view`: **+1.0** (Low-friction discovery)
- `impression`: **0.0** (Neutral exposure)
- `return`: **-3.0** (Dissatisfaction / negative reversal)

### 4.3 Behavioral State Categorization
In `07_user_item_interactions.sql`, user-product relationships are categorized into:
- `PURCHASED_AND_RETAINED` (Customer bought and kept the item)
- `PURCHASED_AND_RETURNED` (Customer bought but returned the item)
- `CART_ABANDONED` (Added to bag but never checked out)
- `VIEWED_ONLY` (Browsed details page without adding to cart)
- `EXPOSED_ONLY` (Displayed as impression only)

### 4.4 Point-in-Time Availability & Leakage Prevention
In `11_candidate_generation.sql`, candidate items must be in stock at prediction time $T_{\text{cutoff}}$ using an SCD Type 2 interval join:
```sql
JOIN product_availability pa 
  ON p.product_id = pa.product_id
 AND pa.effective_from <= @train_cutoff
 AND (pa.effective_to IS NULL OR pa.effective_to > @train_cutoff)
WHERE pa.availability_status = 'available' 
  AND pa.stock_quantity > 0;
```
Items already purchased and retained prior to cutoff are excluded from recommendations to foster new product discovery.

### 4.5 Deterministic Negative Sampling
In `12_negative_sampling.sql`, unobserved items are sampled using a cryptographic hash rank:
```sql
ROW_NUMBER() OVER (
    PARTITION BY rc.user_id 
    ORDER BY MD5(CONCAT(rc.user_id, ':', rc.product_id, ':', 'RECOMMENDER_SEED_2026'))
)
```
Items positively interacted with in historical training **and** future test ground truth items are strictly excluded to avoid corrupting evaluation benchmarks.

---

## 5. Execution Instructions (MySQL Workbench & CLI)

### Running via MySQL Workbench
1. Launch **MySQL Workbench** and connect to your instance (`Local instance MySQL6302` or `sqlmain`).
2. Open the file: `project__38/sql/run_all_pipeline.sql` (or open the modular scripts `01_...` through `16_...` in order).
3. Click the **Execute (Lightning Bolt)** icon.
4. All tables, analytical staging datasets, export views, and validation tests will execute sequentially.

### Running via MySQL Command Line / Terminal
Navigate to the SQL directory and execute:
```bash
cd "C:\Users\duvvu\Downloads\project__38\sql"
mysql -u root -p recommendation_engine < run_all_pipeline.sql
```

---

## 6. Model-Specific Exports & Consumption
The pipeline generates three specialized export views (`Module 15`):
1. **`view_export_collaborative_filtering`**:
   - Fields: `user_id`, `product_id`, `interaction_score`, `total_interactions`, `purchase_count`, `view_count`, `recency_days_at_cutoff`.
   - Used for ALS matrix factorization and neural collaborative filtering.
2. **`view_export_popularity_baseline`**:
   - Fields: `product_id`, `product_name`, `category`, `analytical_period`, `popularity_score`, `category_popularity_rank`, `freshness_tier`, `interaction_sufficiency`.
   - Used for cold-start fallbacks and top trending widgets.
3. **`view_export_content_based`**:
   - Fields: `product_id`, `product_name`, `category`, `price`, `brand`, `warranty`, `material`, `color`, `size`.
   - Used for TF-IDF and item-item similarity vectors.

---

## 7. Testing & Quality Assurance Summary
All 8 automated test suites in `16_testing_and_validation.sql` passed:
- `TEST-01`: Table Creation & Population -> **PASS**
- `TEST-02`: Telemetry Ingestion Deduplication -> **PASS**
- `TEST-03`: Implicit Feedback Bounds -> **PASS**
- `TEST-04`: Historical Feature Temporal Leakage Assertion -> **PASS**
- `TEST-05`: Point-in-Time Availability Enforcement -> **PASS**
- `TEST-06`: Prior Retained Purchase Candidate Exclusion -> **PASS**
- `TEST-07`: Negative Sampling Contamination Audit -> **PASS**
- `TEST-08`: Evaluation Candidate Set Structural Integrity -> **PASS**
