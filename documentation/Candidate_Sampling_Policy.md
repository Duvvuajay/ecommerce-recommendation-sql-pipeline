# Candidate Selection & Negative Sampling Policy
## Policy Specification for Candidate Pool Generation and Contrastive Evaluation

### 1. Conceptual Distinction: True Negatives vs. Sampled Negatives
- **Observed Negative Feedback**: Explicitly recorded negative signals such as product returns (`return_quantity > 0`) or cart abandonment/removals.
- **Unobserved Items / Sampled Negatives**: Products in the catalog with which a user has never interacted. An unobserved item is not proven to be disliked; rather, it is presumed to have lower relevance relative to observed positive interactions under the standard recommendation evaluation framework.

---

### 2. Candidate Item Eligibility Rules at Prediction Cutoff ($T_{\text{cutoff}}$)
When building candidate sets for user $u$, a candidate product $p$ must satisfy all of the following conditions:
1. **Catalog Active Status**: `products.product_status = 'active'`.
2. **Historical Stock Availability**: 
   $$\exists \text{ record in } \text{product\_availability } \text{where } \text{product\_id} = p \land \text{effective\_from} \le T_{\text{cutoff}} \land (\text{effective\_to} > T_{\text{cutoff}} \lor \text{effective\_to IS NULL}) \land \text{availability\_status} = \text{'available'} \land \text{stock\_quantity} > 0$$
3. **User Exclusion Rule**:
   - **Purchased Products**: Excluded if user $u$ purchased item $p$ prior to $T_{\text{cutoff}}$ and did not return it.
   - **Viewed / Carted Products**: Eligible for recommendation (these represent warm prospective purchases).

---

### 3. Negative Sampling Strategy
For time-aware ranking evaluation (e.g., Hit Rate@K, NDCG@K, Precision@K):
- **Sampling Ratio**: $N = 5$ or $10$ unobserved negative candidates for every held-out positive ground-truth item in the test period.
- **Exclusion Filters for Negatives**:
  1. Must **not** be an observed training interaction for that user.
  2. Must **not** be a held-out test ground-truth item for that user.
  3. Must have been available in stock at $T_{\text{cutoff}}$.
- **Deterministic Sampling Method**:
  To guarantee complete reproducibility across SQL runs, pseudo-random ranking is generated via cryptographic hashing of user, item, and an explicit seed:
  ```sql
  ROW_NUMBER() OVER (
      PARTITION BY user_id 
      ORDER BY MD5(CONCAT(user_id, ':', product_id, ':', 'RECOMMENDER_SEED_2026'))
  ) AS neg_rank
  ```
  Only items with `neg_rank <= @negative_samples_per_user` are sampled.
