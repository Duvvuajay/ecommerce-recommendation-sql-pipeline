-- ==============================================================================
-- MASTER PIPELINE RUNNER: Project 38 Recommendation Engine Dataset Preparation
-- Execute this master script directly in MySQL Workbench or via MySQL CLI.
-- ==============================================================================

SELECT 'STARTING PROJECT 38 DATA PREPARATION PIPELINE' AS pipeline_status;

-- Stage 1: Database Initialization
SOURCE 01_create_database.sql;

-- Stage 2: Schema Table Definitions
SOURCE 02_create_tables.sql;

-- Stage 3: Referential Constraints & Performance Indexes
SOURCE 03_constraints_and_indexes.sql;

-- Stage 4: High-Fidelity Data Population
SOURCE 04_insert_sample_data.sql;

-- Stage 5: Telemetry Event Deduplication
SOURCE 05_event_deduplication.sql;

-- Stage 6: Feedback Scoring & Interaction Taxonomy
SOURCE 06_feedback_scoring.sql;

-- Stage 7: User-Item Interaction Matrix & Behavioral Segmentation
SOURCE 07_user_item_interactions.sql;

-- Stage 8: Product Popularity, Freshness & Cold-Start Identification
SOURCE 08_product_popularity.sql;

-- Stage 9: User Activity Profiling
SOURCE 09_user_activity_profiles.sql;

-- Stage 10: Point-in-Time Historical Snapshots
SOURCE 10_historical_snapshots.sql;

-- Stage 11: Candidate Generation & Availability Constraints
SOURCE 11_candidate_generation.sql;

-- Stage 12: Deterministic Negative Sampling
SOURCE 12_negative_sampling.sql;

-- Stage 13: Time-Aware Chronological Train/Test Split
SOURCE 13_temporal_train_test_split.sql;

-- Stage 14: Recommendation Evaluation Benchmark Datasets
SOURCE 14_evaluation_datasets.sql;

-- Stage 15: Target Model Export Views (Collaborative, Popularity, Content)
SOURCE 15_model_exports.sql;

-- Stage 16: Automated Testing & Data Leakage Assertion Suite
SOURCE 16_testing_and_validation.sql;

SELECT 'PROJECT 38 PIPELINE EXECUTION COMPLETED SUCCESSFULLY' AS pipeline_status;
