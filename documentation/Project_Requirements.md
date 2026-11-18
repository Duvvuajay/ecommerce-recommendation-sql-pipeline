# Project 38: E-Commerce Recommendation Engine Dataset Using Behavioral and Transactional SQL
## Detailed Requirement Specification & Architecture Document

### 1. Executive Summary & Objective
Modern e-commerce recommendation systems require high-fidelity, leakage-free behavioral and transactional datasets to train machine learning models (Collaborative Filtering, Content-Based Filtering, and Hybrid Popularity Baselines). 

This project establishes a production-grade relational database and SQL-based analytical transformation pipeline within MySQL 8.0 / MySQL Workbench. The system transforms raw user interaction streams and transactional records into reproducible, point-in-time, time-aware training and evaluation matrices while strictly preventing temporal data leakage.

---

### 2. Core Business Entities & Relational Architecture
1. **Users (`users`)**:
   - Represents the registered customer base.
   - Key attributes: `user_id`, `user_name`, `email`, `registration_date`, `city`, `user_status`.
2. **Products (`products`)**:
   - The merchandise catalog across multiple retail categories.
   - Key attributes: `product_id`, `product_name`, `category`, `price`, `created_at`, `product_status`.
3. **Product Properties (`product_properties`)**:
   - Metadata key-value pairs supporting content-based recommendation (brand, material, warranty, specifications).
   - Key attributes: `property_id`, `product_id`, `property_name`, `property_value`.
4. **Product Availability (`product_availability`)**:
   - Slowly Changing Dimension (SCD Type 2) tracking historical stock and availability intervals (`effective_from` to `effective_to`).
   - Essential for time-travel candidate set filtering to avoid recommending out-of-stock items at prediction time.
5. **Raw User Events (`user_events`)**:
   - Ingestion log capturing behavioral telemetry (`impression`, `view`, `click`, `add_to_cart`, `wishlist`).
   - Includes `source_event_id` and `ingestion_timestamp` to model real-world event deduplication.
6. **Orders & Order Items (`orders`, `order_items`)**:
   - Transactional truth recording commercial orders, item quantities, prices, and fulfillment status (`confirmed`, `shipped`, `delivered`, `cancelled`).
7. **Returns (`returns`)**:
   - Post-purchase reverse logistics records linked to `order_items`, representing negative purchase feedback.

---

### 3. Detailed Functional Tasks (Mapping to 15 Core Deliverables)
1. **Entity Modeling**: Relational DDL with complete primary keys, foreign keys, cascading constraints, and check constraints.
2. **Behavioral Classification**: Weighted scoring policy classifying events as positive, negative, or neutral.
3. **Event Deduplication**: Partitioned window functions removing redundant ingestions while preserving authentic repeated customer actions.
4. **User-Item Interaction Summaries**: Aggregations across configurable analytical lookback windows.
5. **Product Popularity & Freshness**: Category-partitioned ranking and recency scoring over rolling periods (monthly/weekly).
6. **Cold-Start Identification**: Configurable thresholds separating low-history items from well-represented products.
7. **Behavioral State Separation**: Distinct classification for purchased-retained, purchased-returned, carted-unpurchased, and viewed-only items.
8. **Point-in-Time Historical Snapshots**: Reproducible cutoffs (`@train_cutoff`) freezing historical features.
9. **Eligible Candidate Generation**: Candidate pool filtering by catalog active status and stock availability.
10. **Availability Constraint Enforcement**: Temporal joins against SCD Type 2 availability records to eliminate items out of stock at cutoff.
11. **Chronological Splitting**: Time-aware train/test separation replacing arbitrary random splits.
12. **Data Leakage Prevention & Audit**: SQL assertion queries proving that zero future purchases or events bleed into historical features.
13. **Negative Sampling Pipeline**: Deterministic sampling of uninteracted, available items matching documented sampling ratios.
14. **Evaluation Dataset Generation**: Ground-truth benchmark tables formatted with held-out positives and candidate pools ready for Precision@K, Recall@K, and NDCG@K.
15. **Target Model Exports**: Independent extraction pipelines for Collaborative Filtering (implicit rating matrix), Popularity Baselines, and Content-Based catalogs.
