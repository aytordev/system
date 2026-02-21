---
title: SaaS Unit Economics & Capital Efficiency
impact: MEDIUM
impactDescription: Poor unit economics masked by growth lead to collapse at scale
tags: financial-analysis, unit-economics, cac, ltv, gross-margin, burn-rate, rule-of-40
---

## SaaS Unit Economics & Capital Efficiency

**Impact: MEDIUM (Poor unit economics masked by growth lead to collapse at scale)**

Evaluate unit economics and capital efficiency using CAC payback, LTV:CAC ratio, gross margin, burn rate, Rule of 40, magic number, and net burn multiple as a coherent system. Use this when assessing whether a business can scale profitably, entering fundraising discussions, or deciding whether to accelerate or throttle growth investment. Do not evaluate unit economics in isolation from the growth rate — a 30-month CAC payback is disqualifying at 10% growth but defensible at 150% if NRR exceeds 130%.

**Incorrect (metrics reported without efficiency context):**

```markdown
## Unit Economics Summary

- CAC: $8,400
- LTV: $29,000
- LTV:CAC: 3.5x
- Gross margin: 71%

Verdict: Healthy unit economics. Recommend increasing sales headcount.
```

**Correct (system view with thresholds and capital efficiency diagnosis):**

```markdown
## Unit Economics & Capital Efficiency Audit

**CAC & Payback**
- Blended CAC: $8,400 (Sales-touch: $14,200 | Self-serve: $1,100)
- CAC Payback: 31 months (Sales-touch) — RED: threshold is <18 months
- CAC Payback: 8 months (Self-serve) — GREEN: excellent
- Implication: Sales-touch channel is capital-inefficient at current close rates

**LTV:CAC**
- LTV: $29,000 | LTV:CAC: 3.5x — borderline (target: >3x; elite: >5x)
- WARNING: LTV is sensitive to 23% gross churn. If churn rises 5pp, LTV drops to $21K → 2.5x

**Gross Margin**
- Current: 71% — approaching acceptable floor (70%). Investigate COGS drivers.
- Benchmark: Best-in-class SaaS 75–85%. Gap suggests hosting or CS cost bloat.

**Capital Efficiency**
- Burn Multiple: 2.2x — burning $2.20 per $1 of net new ARR (target <1.5x)
- Magic Number: 0.68 — below 0.75 efficiency threshold
- Rule of 40: Growth 28% + FCF margin -14% = 14 — FAR below 40 threshold

**Verdict:** Self-serve is the healthy core. Sales-touch is destroying capital efficiency.
Recommend: shift investment to self-serve PLG motion; redesign sales comp to target
≤18-month payback accounts only. Do not scale headcount until magic number exceeds 0.75.
```

Reference: [Full framework](../references/saas-economics-full.md)
