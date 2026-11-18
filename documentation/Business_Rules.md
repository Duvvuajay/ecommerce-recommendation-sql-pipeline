# Business Rules & Analytical Transformation Logic

### 1. Ingestion Deduplication vs. Genuine User Actions
- **Issue**: Telemetry pipelines commonly introduce duplicated payloads due to network retries, browser reloads, or message queue replays.
- **Deduplication Rule**: If multiple records share the same `source_event_id`, only the first ingested record (`MIN(ingestion_timestamp)`, tie-broken by `MIN(event_id)`) is retained.
- **Genuine Repeated Actions**: A customer inspecting the same product five times on different occasions produces unique `source_event_id` identifiers and timestamps. These represent genuine repeat engagement and are **strictly preserved**.

---

### 2. Behavioral Feedback & Intent Hierarchy
Events represent differing levels of customer commitment and interest:
1. **Purchase (+5.0)**: Direct monetary exchange; highest indicator of positive relevance.
2. **Add to Cart (+3.0)**: Strong conversion intent.
3. **Wishlist (+3.0)**: Explicit long-term interest bookmark.
4. **Click (+2.0)**: Active exploration in category or search results.
5. **View (+1.0)**: Low-friction inspection of product details page.
6. **Impression (0.0)**: Passive visual exposure; treated as neutral exposure baseline.
7. **Return (-3.0)**: Post-purchase rejection; dampens positive interaction score to reflect dissatisfaction or improper fit.

---

### 3. Recommendation Cutoff & Temporal Horizon
- **Cutoff (`@train_cutoff`)**: Represents the exact prediction point-in-time (e.g., end of training window).
- **Rule of Leakage Prevention**:
  $$\text{Feature Calculation Window: } t \le T_{\text{cutoff}}$$
  $$\text{Evaluation Ground-Truth Window: } T_{\text{cutoff}} < t \le T_{\text{eval}}$$
  No future purchases, returns, or views occurring after $T_{\text{cutoff}}$ can be accessed by the feature engineering queries.

---

### 4. Candidate Item Eligibility & Exclusions
For any given target user $u$ at prediction time $T_{\text{cutoff}}$, a candidate item $p$ is eligible if and only if:
1. Item catalog status is `'active'`.
2. Historical availability at $T_{\text{cutoff}}$ satisfies:
   $$\text{stock\_quantity} > 0 \quad \text{AND} \quad \text{availability\_status} = \text{'available'}$$
3. Prior Purchase Exclusion Rule:
   - Items already purchased and retained by user $u$ prior to $T_{\text{cutoff}}$ are excluded from recommendations to promote discovery and avoid redundant suggestions.
   - Items merely viewed or carted are **retained** in the candidate set as viable conversion opportunities.
