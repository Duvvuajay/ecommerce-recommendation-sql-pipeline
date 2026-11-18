# Project 38: SQL Query Optimization & Performance Report
## Query Plans, Indexing Strategy, and Execution Efficiency

### 1. Performance Engineering Strategy
In production e-commerce pipelines with millions of clickstream events, unindexed analytical queries cause full-table scans, memory exhaustion, and slow execution. The Project 38 pipeline implements targeted performance optimizations:
1. **Targeted B-Tree Indexes**: Placed strategically on high-cardinality join keys and filter columns.
2. **Materialized Staging Tables**: Replaces repetitive multi-table subqueries with indexed intermediate staging tables (`clean_user_events`, `interaction_events`, `user_item_interactions`).
3. **Partitioned Window Operations**: Single-pass window aggregations (`ROW_NUMBER()`, `DENSE_RANK()`) utilizing pre-sorted indexes.

---

### 2. Index Optimization & Justification

| Table | Index Name | Indexed Columns | Justification & Query Acceleration |
|:---|:---|:---|:---|
| `user_events` | `idx_events_source_ingestion` | `(source_event_id, ingestion_timestamp)` | Eliminates sorting during `ROW_NUMBER() OVER (PARTITION BY source_event_id)` deduplication. |
| `user_events` | `idx_events_user_prod_time` | `(user_id, product_id, event_timestamp)` | Accelerates user history extraction and point-in-time temporal range filters. |
| `product_availability` | `idx_avail_prod_effective` | `(product_id, effective_from, effective_to, availability_status)` | Transforms expensive range-based temporal joins into high-speed index range scans. |
| `products` | `idx_products_cat_status` | `(category, product_status)` | Speeds up catalog candidate filtering and category-level popularity partitioning. |
| `orders` | `idx_orders_user_date_status` | `(user_id, order_date, order_status)` | Quickly identifies valid historical purchases and prior purchase exclusions. |

---

### 3. EXPLAIN Query Plan Review (Key Analytical Operations)

#### Operation 1: Point-in-Time Availability Temporal Join (`Module 11`)
- **Query Type**: Temporal interval lookup on `product_availability`.
- **Optimization**: Joined on `(product_id, effective_from, effective_to)` using composite index.
- **Execution Cost**: Replaces Cartesian product with index range scan (`type = range`), scanning only active inventory intervals.

#### Operation 2: Category Popularity Ranking (`Module 08`)
- **Query Type**: `DENSE_RANK() OVER (PARTITION BY category, analytical_period ORDER BY popularity_score DESC)`.
- **Optimization**: Products are clustered by category using `idx_products_cat_status`. Window function executes in a single pass without temporary files on disk.

#### Operation 3: Deterministic Negative Sampling (`Module 12`)
- **Query Type**: Cryptographic hash partitioning and filtering.
- **Optimization**: Anti-joins on `user_item_interactions` and `test_ground_truth_relevant` utilize primary key lookups (`type = eq_ref`), providing $O(1)$ exclusion checks.
