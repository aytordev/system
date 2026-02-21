---
title: Business Health Diagnosis
impact: MEDIUM
impactDescription: Treating symptoms instead of root causes delays recovery and wastes capital
tags: financial-analysis, saas-metrics, business-health, diagnostics, revenue
---

## Business Health Diagnosis

**Impact: MEDIUM (Treating symptoms instead of root causes delays recovery and wastes capital)**

Diagnose SaaS business health by systematically reading revenue growth, net retention, unit economics, and cash efficiency as a unified picture — not as isolated metrics. Use this when a business is underperforming, preparing for a funding round, or before a strategic pivot. Do not use a single metric (e.g., revenue growth alone) to declare health; a fast-growing business with NRR below 100% and CAC payback above 24 months is burning toward failure. Red flags must be cross-referenced to distinguish structural problems from cyclical noise.

**Incorrect (single-metric verdict):**

```markdown
## Q3 Health Check

Revenue grew 35% YoY. Business is healthy.

Recommendation: Accelerate hiring and marketing spend.
```

**Correct (multi-dimensional diagnosis with red flags):**

```markdown
## Q3 Health Diagnosis

**Revenue Growth:** 35% YoY — strong, but decelerating from 52% in Q2. Watch for S-curve plateau.

**Retention:** Gross churn 18% annualized, NRR 94% — RED FLAG. Expansion cannot offset losses.
Churn source: SMB segment (>60% of churned logos). Root cause: time-to-value >90 days.

**Unit Economics:** CAC payback 28 months, LTV:CAC 2.1x — below 3x floor. Sales efficiency declining.
Magic number: 0.6 (threshold is 0.75). Every dollar of S&M is underperforming.

**Cash Efficiency:** Burn multiple 2.4x — burning $2.40 to generate $1 of ARR. Unsustainable at scale.

**Priority Actions:**
1. Fix SMB onboarding to reduce time-to-value below 30 days (churn lever)
2. Pause bottom-funnel spend until magic number exceeds 0.75 (efficiency lever)
3. Model runway at current burn — extend to 18+ months before next growth push
```

Reference: [Full framework](../references/business-health-full.md)
