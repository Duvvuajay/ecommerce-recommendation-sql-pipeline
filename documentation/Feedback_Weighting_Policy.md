# Behavioral Feedback Weighting Policy
## Quantitative Scoring Specification for Implicit Feedback Modeling

### 1. Theoretical Motivation
In standard e-commerce environments, explicit ratings (e.g., 1-5 star reviews) are extremely sparse (< 2% of total transactions). Recommendation algorithms therefore rely on **implicit feedback** extracted from telemetry events and transactional histories.

Unlike explicit ratings, implicit feedback is:
1. **Inherently positive-skewed**: Most captured actions indicate interest, while absence of action does not necessarily indicate negative preference.
2. **Multi-tiered**: A view carries less commitment than a shopping cart addition, which in turn carries less commitment than an actual financial checkout.
3. **Subject to post-purchase revision**: Merchandise returns signal defective delivery, mismatch, or customer regret, requiring downward adjustments.

---

### 2. Standard Event Weight Configuration

| Behavioral Event Type | Data Source | Sentiment Class | Weight Value ($w_e$) | Justification & Business Context |
|:---|:---|:---:|:---:|:---|
| **`impression`** | `clean_user_events` | Neutral | `0.0` | Item was displayed in a grid/banner. Indicates awareness/opportunity, but no active engagement. |
| **`view`** | `clean_user_events` | Positive (Low) | `1.0` | User navigated to Product Details Page (PDP); low effort, exploratory interest. |
| **`click`** | `clean_user_events` | Positive (Mild) | `2.0` | User actively clicked a recommended card or search entry; clear engagement signal. |
| **`add_to_cart`** | `clean_user_events` | Positive (High) | `3.0` | User added product to active bag; high conversion propensity. |
| **`wishlist`** | `clean_user_events` | Positive (High) | `3.0` | User bookmarked product for future acquisition; explicit affinity. |
| **`purchase`** | `orders` + `order_items` | Positive (Highest) | `5.0` | Completed financial transaction with status `confirmed`, `shipped`, or `delivered`. |
| **`return`** | `returns` | Negative | `-3.0` | Merchandise returned by user; partially offsets previous purchase credit. |

---

### 3. Implicit Feedback Score Formulation
For a specific user $u$ and product $p$ over an analytical lookback window $[T_{\text{start}}, T_{\text{cutoff}}]$:

$$\text{Interaction Score}(u, p) = \sum_{e \in E_{u,p}} w_e \times \text{Count}(e)$$

Where $E_{u,p}$ represents the multiset of deduplicated events between user $u$ and item $p$ within the designated temporal bounds.

#### Bounded / Normalized Variant (Optional Transformation)
To prevent extreme outliers (e.g. users repeatedly clicking the same item hundreds of times) from skewing matrix factorization, a logarithmic dampening or saturation ceiling can be applied:

$$\text{Implicit Preference}(u, p) = 1 + \alpha \cdot \ln(1 + \max(0, \text{Interaction Score}(u, p)))$$

Where $\alpha$ is a scaling hyperparameter (typically $10.0 \le \alpha \le 40.0$).
