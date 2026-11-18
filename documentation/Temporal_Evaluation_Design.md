# Temporal Evaluation Design & Data Leakage Prevention
## Rigorous Time-Aware Split Architecture for Recommender Systems

### 1. Why Random Train/Test Splits Fail in Recommendation Systems
A standard random train-test split randomly partitions interactions across the entire dataset. In sequential user behavior, this introduces catastrophic **Temporal Data Leakage**:
1. **Future Interactions in Training**: A model trained on a future purchase from May 20th will artificially predict a related click or view that occurred on May 5th.
2. **Catalog & Inventory Drift**: Recommending an item that only launched in June to a user in March, or recommending an item that was completely out of stock at prediction time.
3. **Overstated Offline Metrics**: Offline evaluations will report deceptively high NDCG/Hit Rate scores that completely collapse when deployed in real-time online production.

---

### 2. Time-Aware Split Architecture
The temporal evaluation protocol defines three synchronized temporal horizons:

```
Timeline:
--------------------|----------------------------|----------------------------> Time
    Window Start           Training Cutoff              Evaluation Cutoff
 (T_window_start)          (T_train_cutoff)              (T_eval_cutoff)

|<--- Lookback Period ---->|                            |
|       (e.g., 30 Days)    |                            |
|                          |<----- Hold-Out Test Period ------->|
|                          |           (e.g., 7 Days)           |
|                          |                                    |
[     TRAINING DATA        ]              [       TEST EVALUATION       ]
• Feature Engineering                      • Ground-Truth Positives
• Historical Popularity                    • Metric Calculation (HitRate@K)
• Point-in-Time Availability               • Leakage Validation
```

---

### 3. Verification Assertions Against Data Leakage
The SQL pipeline implements formal validation checks:
1. **Interaction Leakage Test**: Asserts that `COUNT(*) = 0` for any record in `user_item_interactions` where `last_interaction > @train_cutoff`.
2. **Transactional Feature Leakage Test**: Asserts that `COUNT(*) = 0` for any purchase count derived from `orders` with `order_date > @train_cutoff`.
3. **Availability Leakage Test**: Asserts that no candidate item has its availability determined by records effective strictly after `@train_cutoff`.
4. **Test Independence Test**: Asserts that `COUNT(*) = 0` where a test positive item (`is_relevant = 1`) is simultaneously sampled as a negative candidate for the same user.
