---
title: Pricing Change Financial Analysis
impact: MEDIUM
impactDescription: Unmodeled pricing changes destroy revenue through elasticity and cannibalization
tags: financial-analysis, pricing, revenue-impact, elasticity, competitive-positioning
---

## Pricing Change Financial Analysis

**Impact: MEDIUM (Unmodeled pricing changes destroy revenue through elasticity and cannibalization)**

Evaluate any pricing change by modeling revenue impact, price elasticity, competitive positioning shift, and cannibalization risk before implementation. Use this whenever changing list prices, introducing a new tier, bundling or unbundling features, or running a promotional discount. Do not skip the cannibalization analysis when adding a lower-priced tier — SMB plans routinely cannibalize mid-market deals when the price gap is too wide. Every pricing decision should be treated as a reversible experiment with measurable success criteria.

**Incorrect (intuition-driven, no model):**

```markdown
## Pricing Update Proposal

Our current Pro plan at $99/mo feels too expensive based on sales feedback.
Proposal: Drop Pro to $79/mo to increase conversion.

Expected outcome: More signups, higher revenue.
```

**Correct (impact model with elasticity and risk assessment):**

```markdown
## Pricing Change Analysis — Pro Plan: $99 → $79/mo

**Baseline:** 1,200 Pro subscribers × $99 = $118,800 MRR

**Scenario Modeling (price elasticity estimate: 1.4):**
| Scenario | New Subscribers | Churned | Net MRR | Delta |
|---|---|---|---|---|
| Bear (-10% volume gain) | +120 | 0 | $116,280 | -$2,520 (-2%) |
| Base (+18% volume gain) | +216 | 0 | $115,104 | -$3,696 (-3%) |
| Bull (+30% volume gain) | +360 | 0 | $113,880 | -$4,920 (-4%) |

**Finding:** At elasticity 1.4, a 20% price cut requires 28% volume gain just to break even on MRR.
Current conversion bottleneck is onboarding friction, not price — elasticity assumption is unvalidated.

**Cannibalization Risk:** Starter plan at $39/mo. If Pro drops to $79, price gap narrows to 2x.
Risk: ~15% of current Enterprise trials downgrade to Pro. Estimated impact: -$22K MRR.

**Competitive Position:** Pro at $99 is at market median. Cutting to $79 signals value uncertainty,
not competitiveness. Recommend testing friction removal before price reduction.

**Recommendation:** Do not reduce price. Run 60-day onboarding experiment first; re-evaluate if
conversion rate does not improve by ≥20%.

**Success Criteria (if experiment proceeds):** MRR neutral within 90 days, NRR improvement ≥2%.
```

Reference: [Full framework](../references/finance-pricing-full.md)
