---
title: SaaS Finance Metrics Reference
impact: MEDIUM
impactDescription: Misusing metrics in board decks or investment decisions signals PM immaturity
tags: financial-analysis, saas-metrics, formulas, benchmarks, kpis
---

## SaaS Finance Metrics Reference

**Impact: MEDIUM (Misusing metrics in board decks or investment decisions signals PM immaturity)**

A quick-reference for 32+ SaaS finance metrics with formulas, benchmark ranges, and interpretation notes. Use it when building financial models, preparing investor materials, diagnosing business performance, or reviewing a competitor's reported metrics. Do not present metrics without benchmarks — a 120% NRR is exceptional in SMB but table stakes in enterprise. Always state the cohort, time window, and ARR segment when reporting.

**Incorrect (metric without formula or benchmark context):**

```markdown
## Our Key Metrics

- MRR: $420K
- Churn: 5%
- LTV: $18K
- CAC: $6K
- Rule of 40: 38

Status: Good
```

**Correct (metric with formula, benchmark, and interpretation):**

```markdown
## Key SaaS Metrics — Q3 Snapshot

| Metric | Formula | Value | Benchmark | Signal |
|---|---|---|---|---|
| MRR | Sum of all recurring monthly revenue | $420K | — | Growing 8% MoM |
| ARR | MRR × 12 | $5.04M | — | — |
| Gross Churn | Churned MRR / Beginning MRR | 2.1%/mo (23% ann.) | <5% ann. SMB | RED: above threshold |
| Net Revenue Retention | (Beg. MRR + Expansion − Churn − Contraction) / Beg. MRR | 97% | >100% good, >120% elite | WARN: below 100% |
| CAC | Total S&M spend / New customers acquired | $6,200 | Varies by segment | Blended |
| CAC Payback | CAC / (ARPU × Gross Margin %) | 22 months | <12 best, <18 good | WARN |
| LTV | ARPU × Gross Margin % / Churn Rate | $18K | LTV:CAC >3x target | 2.9x — borderline |
| Rule of 40 | Revenue growth % + Profit margin % | 38 | ≥40 healthy | WARN |
| Magic Number | Net new ARR / S&M spend prior quarter | 0.71 | >0.75 efficient | WARN |
| Burn Multiple | Net burn / Net new ARR | 1.8x | <1x elite, <2x ok | Acceptable |

**Interpretation:** Churn is the dominant risk. All efficiency metrics are borderline because gross retention is dragging NRR below 100%. Fix retention before scaling spend.
```

Reference: [Full framework](../references/finance-metrics-full.md)
