# Finance Metrics Quick Reference — Full Framework

## Purpose

Quick reference for any SaaS finance metric without deep teaching. Use this when
you need a fast formula lookup, benchmark check, or decision framework reminder.
This is a cheat sheet optimized for speed — scan, find, apply. For detailed
explanations, calculations, and examples, see the related deep-dive skills.

## When to Use

- You need a quick formula or benchmark during a meeting
- You are preparing for a board meeting or investor call
- You are evaluating a decision and need to check which metrics matter
- You want to identify red flags quickly
- You need the standard formula for a specific metric

Do NOT use when you need detailed calculation guidance (use `saas-revenue-growth-metrics`
or `saas-economics-efficiency-metrics`), are learning these metrics for the first
time (start with the deep-dive skills), or need worked examples and pitfall
analysis.

## Metric Categories

Metrics are organized into four families:

1. **Revenue and Growth** — Top-line money (revenue, ARPU, ARPA, MRR/ARR, churn, NRR, expansion)
2. **Unit Economics** — Customer-level profitability (CAC, LTV, payback, margins)
3. **Capital Efficiency** — Cash management (burn rate, runway, OpEx, net income)
4. **Efficiency Ratios** — Growth vs. profitability balance (Rule of 40, Magic Number)

## Complete Metrics Reference Table

| Metric | Formula | Good Benchmark | Red Flag |
|--------|---------|----------------|----------|
| Revenue | Total sales before expenses | Growth >20% YoY (varies by stage) | Revenue growing slower than costs |
| ARPU | Total Revenue / Total Users | Track trend | ARPU declining cohort-over-cohort |
| ARPA | MRR / Active Accounts | SMB $100-$1K; Mid $1K-$10K; Ent $10K+ | High ARPA + low ARPU (undermonetized seats) |
| ACV | Annual Recurring Revenue per Contract | SMB $5K-$25K; Mid $25K-$100K; Ent $100K+ | ACV declining |
| MRR/ARR | MRR x 12 = ARR | Track components | New MRR declining while churn stable |
| Churn Rate | Lost / Starting Customers | Monthly <2% great, <5% ok | Churn increasing cohort-over-cohort |
| NRR | (Start + Expansion - Churn - Contraction) / Start x 100 | >120% excellent; 100-120% good | NRR <100% (base contracting) |
| Expansion Rev | Upsells + Cross-sells + Usage Growth | 20-30% of total revenue | Expansion <10% of MRR |
| Quick Ratio | (New + Expansion MRR) / (Churned + Contraction) | >4 excellent; 2-4 healthy | Quick Ratio <2 (leaky bucket) |
| Gross Margin | (Revenue - COGS) / Revenue x 100 | SaaS 70-85% | Gross margin <60% |
| CAC | Total S&M Spend / New Customers | Varies by model | CAC increasing while LTV flat |
| LTV | ARPU x Gross Margin % / Churn Rate | Must be 3x+ CAC | LTV declining cohort-over-cohort |
| LTV:CAC | LTV / CAC | 3:1 healthy; >5:1 underinvesting | LTV:CAC <1.5:1 |
| Payback Period | CAC / (Monthly ARPU x Gross Margin %) | <12mo great; 12-18 ok | Payback >24 months (cash trap) |
| Contribution Margin | (Revenue - All Variable Costs) / Revenue x 100 | 60-80% good | Contribution margin <40% |
| Burn Rate | Monthly Cash Spent - Revenue | Net burn manageable for stage | Net burn accelerating |
| Runway | Cash Balance / Monthly Net Burn | 12+ months good; <6 crisis | Runway <6 months |
| OpEx | S&M + R&D + G&A | Should grow slower than revenue | OpEx growing faster than revenue |
| Net Income | Revenue - All Expenses | Early negative ok; mature 10-20%+ | Losses accelerating without growth |
| Rule of 40 | Revenue Growth % + Profit Margin % | >40 healthy; 25-40 ok | Rule of 40 <25 |
| Magic Number | (Q Rev - Prev Q Rev) x 4 / Prev Q S&M | >0.75 efficient; 0.5-0.75 ok | Magic Number <0.5 |
| Revenue Concentration | Top N Customers / Total Revenue | Top customer <10%; Top 10 <40% | Top customer >25% |

## Quick Decision Frameworks

### Should We Build This Feature?

Ask: revenue impact (direct or indirect)? Margin impact (COGS)? ROI (revenue
impact / dev cost)?

Build if ROI >3x in year one (direct monetization), or LTV impact >10x dev cost
(retention), or strategic value overrides short-term ROI.

Do not build if contribution margin turns negative even with optimistic adoption,
or payback period exceeds average customer lifetime.

Metrics to check: Revenue, Gross Margin, LTV, Contribution Margin.

### Should We Scale This Acquisition Channel?

Ask: unit economics (CAC, LTV, LTV:CAC)? Cash efficiency (payback)? Customer
quality (cohort retention, NRR by channel)? Scalability (Magic Number, volume)?

Scale if LTV:CAC >3:1 AND payback <18 months AND customer quality meets other
channels AND Magic Number >0.75.

Do not scale if LTV:CAC <1.5:1 with no clear path to improvement.

Metrics to check: CAC, LTV, LTV:CAC, Payback, NRR, Magic Number.

### Should We Change Pricing?

Ask: ARPU/ARPA impact? Conversion impact? Churn impact? NRR impact?

Implement if net revenue impact is positive after churn risk, and you can test
with a segment before broad rollout.

Do not change if there is high churn risk without offsetting expansion, or you
cannot test the hypothesis before committing.

Metrics to check: ARPU, ARPA, Churn Rate, NRR, CAC Payback.

### Is the Business Healthy?

Check by stage: Early stage wants growth >50% YoY, LTV:CAC >3:1, gross margin
>70%, runway >12 months. Growth stage wants growth >40%, NRR >100%, Rule of 40
>40, Magic Number >0.75. Scale stage wants growth >25%, NRR >110%, Rule of 40
>40, profit margin >10%.

## Red Flags by Category

### Revenue and Growth

| Red Flag | Action |
|----------|--------|
| Churn increasing cohort-over-cohort | Stop scaling; fix retention first |
| NRR <100% | Fix expansion or reduce churn before scaling |
| Revenue churn > logo churn | Investigate why high-value customers leave |
| Quick Ratio <2 | Fix retention before scaling acquisition |
| Expansion <10% of MRR | Build expansion paths |
| Revenue concentration >50% in top 10 | Diversify customer base |

### Unit Economics

| Red Flag | Action |
|----------|--------|
| LTV:CAC <1.5:1 | Reduce CAC or increase LTV before scaling |
| Payback >24 months | Negotiate annual upfront or reduce CAC |
| Gross margin <60% | Increase prices or reduce COGS |
| CAC increasing while LTV flat | Optimize conversion or reduce sales cycle |
| Contribution margin <40% | Cut variable costs or increase prices |

### Capital Efficiency

| Red Flag | Action |
|----------|--------|
| Runway <6 months | Raise capital or cut burn immediately |
| Net burn accelerating without revenue growth | Cut costs or increase revenue urgency |
| OpEx growing faster than revenue | Freeze hiring; optimize spend |
| Rule of 40 <25 | Improve growth or cut to profitability |
| Magic Number <0.5 | Fix GTM efficiency before scaling spend |

## Metric Selection Guide

**Prioritizing features:** Revenue, ARPU, Expansion Revenue, Gross Margin,
Contribution Margin, LTV impact.

**Evaluating channels:** CAC, CAC by Channel, LTV, NRR by Channel, Payback
Period, Magic Number.

**Pricing decisions:** ARPU, ARPA, ACV, Churn Rate, NRR, Expansion Revenue,
CAC Payback.

**Business health:** Revenue Growth, NRR, LTV:CAC, Rule of 40, Magic Number,
Gross Margin, Burn Rate, Runway.

**Board/investor reporting:** ARR, Revenue Growth %, NRR, LTV:CAC, Rule of 40,
Magic Number, Burn Rate, Runway. Early stage emphasize growth + unit economics.
Growth stage emphasize Rule of 40 + Magic Number. Scale stage emphasize
profitability + efficiency.

## Common Pitfalls

- Using blended company averages instead of cohort or channel-level metrics
- Scaling acquisition when Quick Ratio is weak and retention is deteriorating
- Treating high LTV:CAC as sufficient without checking payback and runway
- Raising prices based on ARPU lift alone without modeling churn and contraction
- Comparing benchmarks across mismatched company stages or business models
- Tracking many metrics without a clear decision question driving the analysis

## Related Skills

- `saas-revenue-growth-metrics` — Detailed guidance on 13 revenue, retention, and growth metrics
- `saas-economics-efficiency-metrics` — Detailed guidance on 17 unit economics and efficiency metrics
- `feature-investment-advisor` — Uses these metrics to evaluate feature ROI
- `acquisition-channel-advisor` — Uses these metrics to evaluate channel viability
- `finance-based-pricing-advisor` — Uses these metrics to evaluate pricing changes
- `business-health-diagnostic` — Uses these metrics to diagnose overall business health
