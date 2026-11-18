# Project 38: Implementation & Engineering Report
## E-Commerce Recommendation Engine Dataset Preparation Using Behavioral & Transactional SQL

### 1. Project Background & Technical Scope
The goal of Project 38 is to construct trustworthy, leak-free behavioral interaction matrices and time-aware evaluation datasets for machine learning recommendation engines. 

Using MySQL 8.0, this pipeline establishes a complete 3NF normalized schema, populates it with realistic e-commerce interactions, performs partitioned window-function event deduplication, computes implicit preference weights, handles temporal Slowly Changing Dimensions (SCD Type 2) for stock availability, generates candidate recommendation pools, samples contrastive negatives deterministically, and prepares ready-to-train datasets for Collaborative Filtering, Popularity Baselines, and Content-Based Filtering.

---

### 2. Implementation Architecture & Data Flow

```mermaid
flowchart TD
    subgraph Data_Ingestion ["Data Ingestion & Normalization"]
        U[users]
        P[products]
        PP[product_properties]
        PA[product_availability]
        UE[user_events]
        O[orders]
        OI[order_items]
        R[returns]
    end

    subgraph Data_Cleansing ["Cleansing & Taxonomy"]
        UE -->|Window Deduplication| CUE[clean_user_events]
        CUE & O & OI & R -->|Weighted Union| IE[interaction_events]
    end

    subgraph Feature_Engineering ["Temporal Feature Engineering"]
        IE -->|30-Day Window| UII[user_item_interactions]
        IE & P -->|Category & Freshness| PPOL[product_popularity]
        IE & U -->|Engagement Tiers| UAP[user_activity_profiles]
        IE -->|Point-in-Time Cutoff| HIS[historical_interaction_snapshots]
    end

    subgraph Candidate_Generation ["Candidate Generation & Negative Sampling"]
        P & PA -->|Availability Check @ Cutoff| ELIG[Available Active Products]
        U & ELIG -->|Exclude Retained Purchases| RC[recommendation_candidates]
        RC -->|Deterministic MD5 Hash| NSC[negative_sampling_candidates]
    end

    subgraph Evaluation_Split ["Time-Aware Chronological Evaluation"]
        IE -->|t <= T_cutoff| TRAIN[train_interactions]
        IE -->|t > T_cutoff| TEST[test_interactions]
        TEST -->|Positives Only| GTR[test_ground_truth_relevant]
        GTR & NSC --> ERD[evaluation_ranking_dataset]
    end

    subgraph Downstream_Exports ["Model-Specific Export Views"]
        UII --> V_CF[view_export_collaborative_filtering]
        PPOL --> V_POP[view_export_popularity_baseline]
        P & PP --> V_CB[view_export_content_based]
    end
```

---

### 3. Key Technical Challenges & Solutions
1. **Preserving Genuine Repetitive Behavior vs. Technical Retries**:
   - *Problem*: Ingestion duplicates must be purged without erasing customer browsing patterns where a user views an item repeatedly over days.
   - *Solution*: Window function `ROW_NUMBER() OVER (PARTITION BY source_event_id ORDER BY ingestion_timestamp, event_id)` ensures technical retries are pruned while genuine distinct user sessions remain intact.
2. **Eliminating Temporal Data Leakage**:
   - *Problem*: Traditional random splits expose future interactions to historical features, rendering offline evaluation artificially high.
   - *Solution*: A strict point-in-time boundary (`@train_cutoff`) enforces that zero training features access post-cutoff interactions, and availability is determined strictly via SCD Type 2 date intervals (`effective_from <= @train_cutoff AND (effective_to IS NULL OR effective_to > @train_cutoff)`).
3. **Contrastive Evaluation without Evaluation Contamination**:
   - *Problem*: Negative sampling must not sample items the user actually interacted with or purchased in the future test evaluation period.
   - *Solution*: Multi-table anti-joins exclude both training interactions and held-out test ground truth items before applying deterministic hash ranking.
