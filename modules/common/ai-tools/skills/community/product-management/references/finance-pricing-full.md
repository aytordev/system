# Finance-Based Pricing Advisor — Full Framework

## Purpose

Evaluate the financial impact of pricing changes using ARPU/ARPA analysis,
conversion impact, churn risk, NRR effects, and CAC payback implications. Use
this to make data-driven go/no-go decisions on proposed pricing changes with
supporting math and risk assessment.

This is a financial impact evaluation for pricing decisions you are already
considering. It is NOT comprehensive pricing strategy design, value-based pricing,
willingness-to-pay research, competitive positioning, or packaging architecture.
It assumes you have a specific pricing change in mind and need to evaluate its
financial viability.

## When to Use

- You have a specific pricing change to evaluate (e.g., "Should we raise prices 20%?")
- You need to quantify revenue, churn, and conversion trade-offs
- You are deciding between pricing change options (test A vs. B)
- You need to present pricing change impact to leadership or the board

Do NOT use when designing pricing strategy from scratch (use value-based pricing
frameworks), when you have not validated willingness-to-pay (do customer research
first), when you lack baseline metrics (ARPU, churn, conversion rates), or when
the change is too small to matter (<5% price change, <10% of customers affected).

## The Pricing Impact Framework

Every pricing change is evaluated across five dimensions:

### 1. Revenue Impact

How does this change ARPU/ARPA? Calculate: direct revenue lift from price
increase, revenue loss from reduced conversion or increased churn, and the net
revenue impact.

### 2. Conversion Impact

How does this affect trial-to-paid or sales conversion? Higher prices may reduce
conversion rate; better packaging may improve it. Test assumptions.

### 3. Churn Risk

Will existing customers leave due to the price change? Consider grandfathering
strategy, churn risk by segment (SMB vs. enterprise), and how sensitive customers
are to price changes.

### 4. Expansion Impact

Does this create or block expansion opportunities? A new premium tier creates an
upsell path. Usage-based pricing enables expansion as customers grow. Add-ons
enable cross-sell.

### 5. CAC Payback Impact

Does the pricing change affect unit economics? Higher ARPU means faster payback.
Lower conversion means higher effective CAC. Calculate the net effect on LTV:CAC.

## Pricing Change Types

**Direct monetization:** Price increase (for all or new customers only), new
premium tier, paid add-on, usage-based pricing.

**Discount strategies:** Annual prepay discount (improve cash flow), volume
discounts (larger deals), promotional pricing (temporary reduction).

**Packaging changes:** Feature bundling into tiers, unbundling into add-ons,
pricing metric change (seats to usage or vice versa).

## Interactive Evaluation Process

### Step 0 — Gather Context

Collect: current ARPU or ARPA, current pricing tiers, monthly churn rate,
trial-to-paid conversion rate, total customers or MRR/ARR, CAC, NRR. Estimates
are acceptable.

### Step 1 — Identify Pricing Change Type

Determine which type: price increase, new premium tier, paid add-on, usage-based
pricing, discount strategy, or packaging change. Each type triggers different
evaluation questions.

### Step 2 — Assess Expected Impact

Quantify: current ARPU vs. expected new ARPU (lift percentage), current vs.
expected conversion rate, current vs. expected churn after change, whether this
creates expansion opportunities, and expected NRR change.

### Step 3 — Evaluate Current State

Collect baseline: MRR/ARR, customer count, ARPU/ARPA, monthly churn rate, NRR,
CAC, LTV, current and target growth rates, and whether you are priced below, at,
or above market.

### Step 4 — Deliver Recommendation

Synthesize revenue impact, conversion impact, churn impact, net revenue impact,
CAC payback impact, and risk assessment into one of four recommendations.

## Recommendation Patterns

### Pattern 1: Implement Broadly

When net revenue impact is clearly positive (>10% ARPU lift, <5% churn risk),
minimal conversion impact, strong value justification.

Output includes: revenue impact calculation (current MRR, ARPU lift, expected MRR
increase), churn risk assessment, conversion impact, CAC payback impact,
implementation steps (grandfather existing, communicate value, monitor for 30-60
days), expected timeline at months 1, 3, 6, and 12, and success criteria.

### Pattern 2: Test First (A/B Test)

When impact is uncertain (wide confidence interval), moderate churn or conversion
risk, and the customer base is large enough to test with a subset.

Output includes: test design with control and test cohorts, duration (60-90 days
for statistical significance), metrics to track (conversion, ARPU, 30-day
retention, 90-day churn, NRR), decision criteria for rollout vs. kill, and risk
assessment.

### Pattern 3: Modify Approach

When the original proposal has significant risk but a better alternative exists.

Output includes: analysis of the problem with the original proposal, 2-3
alternative options (e.g., smaller increase, grandfather existing, segment-based
pricing), a specific recommendation with reasoning, and implementation steps.

### Pattern 4: Do Not Change Pricing

When net revenue impact is negative or marginal, high churn risk without
offsetting gains, or competitive/strategic reasons to hold.

Output includes: analysis showing risks outweigh benefits, what would need to
change for the pricing change to work, alternative strategies (improve retention,
expand within base, reduce CAC), and when to revisit pricing.

## Sensitivity Analysis Template

Model three scenarios for any pricing change:

**Optimistic case:** Higher ARPU lift, lower churn than expected.
**Base case:** Best estimate of ARPU lift and churn impact.
**Pessimistic case:** Lower ARPU lift, higher churn than expected.
**Breakeven analysis:** What churn rate makes the change revenue-neutral?

## Examples

### Price Increase (Good Case)

20% increase for new customers only. ARPU $100 to $120. 1,000 customers, 50 new
per month, 3% churn. Existing grandfathered. Conversion impact minimal (<5%
drop). Net revenue impact: +$12K/year with low risk. Recommendation: Implement.

### Price Increase (Risky)

30% increase for all customers. ARPU $50 to $65. 5,000 customers, 5% churn
(already high). Expected churn increase to 8%. ARPU lift +$75K MRR, churn loss
-$9.75K MRR/month (accelerating). Recommendation: Do not change. Fix retention
first.

### New Premium Tier

$500/month tier above current $200 top tier. Expected 10% upgrade (50
customers). Upsell revenue +$15K MRR. Low cannibalization risk, NRR improves
105% to 110%. Recommendation: Implement. Creates expansion path.

## Common Pitfalls

**Ignoring churn impact.** Modeling revenue lift without modeling churn-driven
losses. Always calculate net impact including churn scenarios.

**Not grandfathering existing customers.** Raising prices for everyone at once
causes a churn spike. Protect existing customers and raise for new only.

**Testing without statistical power.** Testing on 10 customers produces noise,
not signal. Need 100+ per cohort for 60-90 days.

**Pricing without value justification.** "We need more revenue" is not a reason
customers accept. Tie price increases to value improvements.

**Ignoring CAC payback impact.** Higher ARPU with a 30% conversion drop may make
payback worse, not better. Calculate the full unit economics effect.

**Annual discounts that destroy LTV.** Offering 30% off for annual prepay
improves cash but locks in low prices. Limit annual discounts to 10-15%.

**Copycat pricing.** Your customers, value proposition, and cost structure differ
from competitors. Use competitors as data points, not decisions.

**Premature optimization.** Spending months A/B testing 5% price differences while
missing 50% growth opportunities elsewhere. Start with big structural changes.

**Forgetting expansion revenue.** Maximizing ARPU at acquisition can prevent
landing customers. Consider land-and-expand with lower entry price and higher
expansion revenue.

**No communication plan.** Surprising customers with price increases causes churn
and reputation damage. Communicate 30-60 days in advance emphasizing value.

## Related Skills

- `saas-revenue-growth-metrics` — ARPU, ARPA, churn, NRR metrics used in pricing analysis
- `saas-economics-efficiency-metrics` — CAC payback impact of pricing changes
- `finance-metrics-quickref` — Quick lookup for pricing-related formulas
- `feature-investment-advisor` — Evaluates whether to build features that enable pricing changes
- `business-health-diagnostic` — Broader business context for pricing decisions
