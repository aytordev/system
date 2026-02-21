---
title: SaaS Revenue Health Metrics
impact: MEDIUM
impactDescription: Reporting ARR growth without retention metrics misleads investors and leadership
tags: financial-analysis, mrr, arr, churn, nrr, expansion-revenue, cohort-analysis
---

## SaaS Revenue Health Metrics

**Impact: MEDIUM (Reporting ARR growth without retention metrics misleads investors and leadership)**

Calculate and interpret the full revenue health stack: MRR/ARR growth rate, gross and net churn, Net Revenue Retention, expansion revenue, contraction analysis, and cohort retention curves. Use this for monthly business reviews, investor updates, and when diagnosing revenue deceleration. Do not report ARR growth alone — a company growing ARR 40% YoY with NRR of 85% is a leaky bucket that will stall; one growing 20% with NRR of 125% is compounding. Always decompose MRR movements into new, expansion, contraction, and churn buckets.

**Incorrect (headline metric without retention breakdown):**

```markdown
## Revenue Update — Q3

ARR: $6.2M (up 41% YoY). Great quarter.
New logos: 48. Average deal: $129K ACV.

Outlook: On track to hit $8M ARR by year-end.
```

**Correct (full MRR bridge with retention and cohort signal):**

```markdown
## Revenue Health — Q3 MRR Bridge

**Beginning MRR:** $483,000

| Movement | Amount | Notes |
|---|---|---|
| New Business | +$52,000 | 48 logos, avg $1,083 MRR |
| Expansion | +$18,400 | Seat additions + plan upgrades |
| Contraction | -$9,200 | Downgrades, seat reductions |
| Churn | -$31,600 | 29 logos lost |
| **Ending MRR** | **$512,600** | +6.1% MoM |

**Gross MRR Churn:** $31,600 / $483,000 = 6.5%/mo — RED (annualized 78%; target <5%/yr)
**Net MRR Churn:** ($31,600 + $9,200 − $18,400) / $483,000 = 4.6%/mo — RED

**NRR (trailing 12 months):** 88% — below 100% floor. Business shrinks without new logos.

**Expansion Rate:** $18,400 / $483,000 = 3.8% — healthy expansion motion; cannot offset gross churn

**Cohort Analysis Signal:** Jan cohort (12 months old) at 61% logo retention, 74% revenue retention.
Expansion partially masking logo churn. Cohorts are NOT improving — Jan vs. Jul cohorts within 2pp.

**Root Cause Hypothesis:** Churn concentrated in <$500 MRR accounts (68% of churned logos).
SMB segment requires self-serve success motion — current high-touch CS model is uneconomic there.

**Priority:** Segment churn analysis by ACV, industry, and onboarding path before Q4 planning.
```

Reference: [Full framework](../references/saas-revenue-full.md)
