---
title: Feature Investment Analysis
impact: MEDIUM
impactDescription: Build decisions without ROI framing lead to feature factories and wasted engineering cycles
tags: planning, investment, roi, build-vs-buy, feature, prioritization
---

## Feature Investment Analysis

**Impact: MEDIUM (Build decisions without ROI framing lead to feature factories and wasted engineering cycles)**

Evaluate each feature investment on two axes: expected ROI (revenue impact, cost savings, or churn reduction quantified in dollars over 12 months) and strategic value (does it advance the positioning differentiator, expand into a new segment, or close a competitive gap). Size the investment in engineering-weeks and compute the simple ROI ratio before committing. Use this when deciding whether to build something in the next quarter. Do not use it for bugs or tech debt — those have different cost structures and belong in a separate capacity budget.

**Incorrect (vague benefit claim, no investment sizing):**

```markdown
## Feature: Advanced Reporting

Why build it:
- Customers have been asking for this
- Competitors have it
- Will help with retention

Decision: Yes, let's build it.
Timeline: Q3
```

**Correct (quantified ROI, strategic value, and explicit build/don't-build verdict):**

```markdown
## Feature Investment: Advanced Reporting

### Investment
- Engineering effort: 6 weeks (2 engineers)
- Design effort: 2 weeks
- Total cost (fully-loaded): ~$48,000

### Expected Return (12-month horizon)
- Retention impact: closes reported reason for 18% of churned accounts
  → 12 accounts/yr × $8,400 ACV = $100,800 retained ARR
- Expansion: enables upsell to Analytics tier for 30 existing accounts
  → 30 × $1,200 incremental MRR × 12 = $43,200
- Total 12-month return: ~$144,000

### ROI Ratio: 3.0x (return / investment cost)

### Strategic Value
- Directly supports "data-first operations" positioning differentiator
- Closes primary feature gap vs. Competitor A (cited in 9 loss notes Q1)

### Verdict: BUILD
Threshold for build: ROI > 2x AND supports current positioning.
Both conditions met. Schedule for Q3, cap at 8 weeks total.
```

Reference: [Full framework](../references/feature-investment-analysis-full.md)
