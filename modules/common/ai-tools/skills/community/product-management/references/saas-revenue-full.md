# SaaS Revenue and Growth Metrics — Full Framework

## Purpose

Master revenue and retention metrics to understand SaaS business momentum,
evaluate product-market fit, and make data-driven decisions about growth
investments. Use this to calculate key metrics, interpret trends, identify
problems early, and communicate business health to stakeholders.

This is not a business intelligence tool. It is a framework for PMs to
understand which metrics matter, how to calculate them correctly, and what
actions to take based on the numbers.

## When to Use

- Evaluating overall business health and product-market fit
- Comparing performance across time periods or cohorts
- Prioritizing features with direct monetization paths (ARPU impact, expansion)
- Communicating with leadership, board, or investors
- Assessing retention problems (churn analysis, cohort degradation)
- Measuring pricing or packaging changes (ARPU/ARPA shifts)

## When NOT to Use

- Evaluating profitability (use SaaS economics and efficiency metrics)
- Assessing capital efficiency (use LTV:CAC and payback period)
- Making product investment decisions without cost context (revenue alone is not ROI)
- Comparing across wildly different business models without normalization

## Metric Families

### Revenue Metrics — Top-Line Performance

| Metric           | Formula                                                | Key Insight                                  |
|------------------|--------------------------------------------------------|----------------------------------------------|
| Revenue          | Sum of all customer payments in period                 | Growth rate matters more than absolute number |
| ARPU             | Total Revenue / Total Users                            | Per-seat monetization effectiveness          |
| ARPA             | MRR / Active Accounts                                  | Account-level deal size                      |
| ACV              | Annual Recurring Revenue per Contract (excl. one-time) | Cross-contract comparison                    |
| MRR              | Sum of all recurring monthly subscriptions             | Heartbeat of subscription business           |
| ARR              | MRR x 12                                               | Annual view for planning and valuation       |
| Net Revenue      | Gross Revenue - Discounts - Refunds - Credits          | True revenue after adjustments               |

**MRR Components** — always track the four parts:
- **New MRR:** from new customers
- **Expansion MRR:** from upsells, cross-sells, usage growth
- **Churned MRR:** from lost customers
- **Contraction MRR:** from downgrades

### Retention and Expansion — The Multiplier

| Metric             | Formula                                                              | Good Benchmark            |
|--------------------|----------------------------------------------------------------------|---------------------------|
| Logo Churn         | Customers Lost / Starting Customers x 100                            | <2% monthly great         |
| Revenue Churn      | MRR Lost / Starting MRR x 100                                       | Lower than logo churn     |
| NRR                | (Starting ARR + Expansion - Churn - Contraction) / Starting ARR x 100 | >120% excellent; >100% good |
| Expansion Revenue  | Upsells + Cross-sells + Usage Growth from existing customers          | 20-30% of total revenue   |
| Quick Ratio (SaaS) | (New MRR + Expansion MRR) / (Churned MRR + Contraction MRR)          | >4 excellent; <2 leaky bucket |

**Churn compounds.** 3% monthly churn is not 36% annual — it is 31%.
Formula: `Annual Churn = 1 - (1 - Monthly Churn)^12`

### Analysis Frameworks

**Revenue Mix Analysis:** Break down revenue by product, segment, or channel.
No single product should exceed 60% of total revenue. Concentration is risk.

**Cohort Analysis:** Group customers by join date and track retention over time.
Blended metrics hide whether the business is improving or degrading. If newer
cohorts perform worse than older ones, product-market fit is degrading — stop
scaling and fix the product.

## Key Formulas — Quick Reference

```
ARPU             = Total Revenue / Total Users
ARPA             = MRR / Active Accounts
Seats/Account    = ARPA / ARPU
MRR              = New + Expansion - Churned - Contraction
ARR              = MRR x 12
Logo Churn       = Lost Customers / Starting Customers
Revenue Churn    = Lost MRR / Starting MRR
NRR              = (Start ARR + Expansion - Churn - Contraction) / Start ARR
Quick Ratio      = (New MRR + Expansion MRR) / (Churned MRR + Contraction MRR)
Annual Churn     = 1 - (1 - Monthly Churn)^12
```

## Worked Examples

### Example 1: Healthy SaaS Metrics

- MRR: $2M (growing 10% MoM) | ARR: $24M
- ARPA: $1,200/month | ARPU: $120/month | Avg seats: 100/account
- Monthly logo churn: 2% | Revenue churn: 1.5% | NRR: 115%
- Quick Ratio: 5.0

**Analysis:** Strong growth, excellent retention, healthy expansion (NRR >100%),
sustainable gains (Quick Ratio 5.0). Revenue churn below logo churn means
smaller customers are leaving — a good signal.

**Action:** Scale acquisition. Unit economics are strong.

### Example 2: Warning Signs

- MRR: $500K (growing 15% MoM) | ARPA: $250 | ARPU: $50
- Monthly logo churn: 6% (up from 4% six months ago)
- Revenue churn: 7% | NRR: 85% | Quick Ratio: 1.2

Cohort retention at month 6: 75% (6mo ago) -> 65% (3mo ago) -> 58% (current)

**Analysis:** High churn (6% monthly = ~50% annual), revenue churn exceeds logo
churn (losing bigger customers), NRR contracting, cohort degradation, leaky
bucket (Quick Ratio 1.2).

**Action:** STOP scaling acquisition. Fix retention first. Investigate why newer
cohorts churn faster and why expansion revenue is only 1% of MRR.

### Example 3: Blended Metrics Hiding Problems

Blended: MRR $3M (20% MoM growth), churn 3%, NRR 110%. Looks healthy.

| Product | Revenue | % Total | Growth  | Churn | NRR  |
|---------|---------|---------|---------|-------|------|
| Legacy  | $2M     | 67%     | -5% MoM | 8%   | 75%  |
| New     | $1M     | 33%     | +80% MoM | 1%  | 150% |

Two-thirds of revenue is contracting. The blended average hides that the legacy
product (67% of revenue) is dying while the new product masks the decline.

**Action:** Accelerate migration from legacy to new product. Plan legacy sunset.

## Cohort Analysis Template

Track retention by cohort to detect degradation:

| Cohort   | Month 0 | Month 1 | Month 3 | Month 6 | Month 12 |
|----------|---------|---------|---------|---------|----------|
| Jan 2025 | 100%    | 95%     | 90%     | 85%     | 75%      |
| Apr 2025 | 100%    | 94%     | 87%     | 80%     | —        |
| Jul 2025 | 100%    | 92%     | 82%     | —       | —        |

If each row shows worse retention than the one above, product-market fit is
degrading. Fix before scaling.

## Common Failure Modes

| Failure Mode                         | Why It Hurts                                         | Fix                                                |
|--------------------------------------|------------------------------------------------------|----------------------------------------------------|
| Confusing revenue with profit        | $2M revenue at 20% margin is worse than $1M at 80%  | Always pair revenue with margin metrics            |
| ARPU growth from mix shift           | Losing small customers inflates ARPU artificially    | Analyze ARPU by cohort and segment                 |
| Ignoring cohort degradation          | Blended 3% churn hides 6% churn in new cohorts      | Always analyze retention by cohort                 |
| Logo vs. revenue churn confusion     | 2% logo churn can be 10% revenue churn               | Track both; if revenue > logo, losing big customers |
| Treating all churn equally           | 50 lost $10/mo accounts != 50 lost $10K/mo accounts | Segment churn by customer size and revenue impact  |
| Forgetting compounding churn         | 3% monthly != 36% annual (it's 31%)                 | Use correct formula: 1 - (1 - monthly)^12         |
| Celebrating gross while net contracts | Gross up 20% but discounts doubled = flat net        | Track gross AND net; investigate >20% discounts    |
| NRR >100% from low churn, not expansion | 105% NRR without real expansion is fragile          | Break NRR into components; aim for expansion-driven |
| Revenue concentration risk           | 50% of ARR from one customer = hostage roadmap       | Top customer <10%, top 10 <40% of revenue          |
| Averaging ARPU across segments       | $100 average hides $10 SMB and $1K enterprise        | Calculate per segment; optimize independently      |

## Quality Checklist

- [ ] Gross vs. net revenue clearly labeled in all reports
- [ ] Revenue growth rate compared against cost growth rate
- [ ] ARPU/ARPA analyzed by cohort, not just blended average
- [ ] Both logo churn and revenue churn tracked separately
- [ ] Cohort-over-cohort retention trends analyzed
- [ ] NRR decomposed into expansion, churn, and contraction components
- [ ] Quick ratio calculated to assess growth sustainability
- [ ] Revenue mix analyzed for concentration risk
- [ ] Monthly-to-annual churn conversion uses correct compounding formula

## Relationship to Other Frameworks

- **SaaS Economics and Efficiency Metrics** — unit economics (CAC, LTV, margins,
  burn rate) that pair with these revenue metrics
- **Finance Metrics Quick Reference** — fast lookup for all metrics
- **Feature Investment Analysis** — uses revenue metrics to evaluate feature ROI
- **Finance-Based Pricing** — uses ARPU/ARPA to evaluate pricing changes
- **Business Health Diagnostic** — uses revenue and retention for health checks
