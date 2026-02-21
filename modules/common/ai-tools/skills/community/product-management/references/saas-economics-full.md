# SaaS Economics and Efficiency Metrics — Full Framework

## Purpose

Determine whether a SaaS business model is fundamentally viable and
capital-efficient. Use this to calculate unit economics, assess profitability,
manage cash runway, and decide when to scale versus optimize. Essential for
fundraising, board reporting, and making investment trade-offs.

This is not a finance reporting tool. It is a framework for PMs to understand
whether the business can sustain growth, when to prioritize efficiency over
growth, and which investments have positive returns.

## When to Use

- Evaluating whether to scale acquisition spending (LTV:CAC, payback, magic number)
- Deciding feature investments by margin impact or contribution to LTV
- Planning runway and fundraising timing (burn rate, runway, Rule of 40)
- Comparing customer segments or acquisition channels on unit economics
- Board or investor reporting (Rule of 40, magic number, LTV:CAC)
- Choosing between growth and profitability investment

## When NOT to Use

- Making decisions without revenue context (pair with SaaS revenue metrics)
- Comparing across wildly different business models without normalization
- Early product discovery before revenue exists (focus on PMF, not unit economics)
- Short-term tactical decisions (use engagement metrics, not LTV)

## Metric Families

### Unit Economics — Customer-Level Profitability

| Metric              | Formula                                           | Good Benchmark            |
|---------------------|---------------------------------------------------|---------------------------|
| Gross Margin        | (Revenue - COGS) / Revenue x 100                  | 70-85% for SaaS           |
| CAC                 | Total S&M Spend / New Customers                   | Varies by model            |
| LTV (simple)        | ARPU x Avg Customer Lifetime                      | Must be 3x+ CAC           |
| LTV (better)        | ARPU x Gross Margin % / Churn Rate                | Accounts for margin        |
| LTV:CAC Ratio       | LTV / CAC                                          | 3:1 healthy; >5:1 underinvesting |
| Payback Period      | CAC / (Monthly ARPU x Gross Margin %)              | <12 mo great; >24 mo concerning |
| Contribution Margin | (Revenue - All Variable Costs) / Revenue x 100    | 60-80% for SaaS           |

**COGS includes:** Hosting, infrastructure, payment processing, customer
onboarding costs. **Variable costs** add support, processing fees, variable
customer success on top of COGS.

### Capital Efficiency — Cash Management

| Metric       | Formula                                    | Good Benchmark              |
|--------------|--------------------------------------------|-----------------------------|
| Gross Burn   | Total Monthly Cash Spent                   | Context-dependent           |
| Net Burn     | Monthly Cash Spent - Monthly Revenue       | Decreasing over time        |
| Runway       | Cash Balance / Monthly Net Burn            | >12 mo healthy; <6 mo crisis |
| OpEx         | S&M + R&D + G&A                            | Should grow slower than revenue |
| Net Income   | Revenue - COGS - OpEx                      | Early SaaS often negative   |

**Fundraising rule:** Start raising at 6-9 months runway, not 3 months.

### Efficiency Ratios — Growth vs. Profitability

| Metric             | Formula                                                        | Good Benchmark              |
|--------------------|----------------------------------------------------------------|-----------------------------|
| Rule of 40         | Revenue Growth Rate % + Profit Margin %                        | >40 healthy; <25 concerning |
| Magic Number       | (Current Qtr Rev - Prev Qtr Rev) x 4 / Prev Qtr S&M Spend    | >0.75 scale; <0.5 fix first |
| Operating Leverage | Revenue growth rate vs. OpEx growth rate over time             | Revenue growing faster      |

## Worked Examples

### Example 1: Healthy Unit Economics

- CAC: $8,000 | LTV: $40,000 | LTV:CAC: 5:1 | Payback: 10 months
- Gross Margin: 82% | Net Burn: $300K/mo | Runway: 18 months
- Rule of 40: 55 (40% growth + 15% margin) | Magic Number: 0.9

**Action:** Scale acquisition aggressively. Economics support growth.

### Example 2: Cash Trap (Good Ratio, Bad Payback)

- CAC: $80,000 | LTV: $400,000 | LTV:CAC: 5:1 (looks great)
- Payback: 36 months (terrible) | Runway: 9 months

The 5:1 ratio masks a cash crisis. It takes 3 years to recover CAC but only
9 months of cash remain.

**Actions:** Negotiate upfront annual payments, raise capital to extend runway,
reduce CAC by shortening sales cycles, or target smaller deals with faster payback.

### Example 3: Negative Operating Leverage

| Quarter | Revenue  | Rev Growth | OpEx    | OpEx Growth |
|---------|----------|------------|---------|-------------|
| Q1      | $1.0M    | —          | $800K   | —           |
| Q2      | $1.3M    | 30%        | $1.2M   | 50%         |
| Q3      | $1.6M    | 23%        | $1.8M   | 50%         |

OpEx grows faster than revenue. Losses accelerate from $800K to $1.8M in two
quarters.

**Actions:** Freeze headcount, cut inefficient S&M, focus on unit economics
before scaling. OpEx growth must be below revenue growth.

## Key Formulas — Quick Reference

```
Gross Margin       = (Revenue - COGS) / Revenue x 100
CAC                = Total S&M Spend / New Customers
LTV                = ARPU x Gross Margin % / Monthly Churn Rate
LTV:CAC            = LTV / CAC
Payback (months)   = CAC / (Monthly ARPU x Gross Margin %)
Contribution Margin = (Revenue - All Variable Costs) / Revenue x 100
Net Burn           = Monthly Cash Spent - Monthly Revenue
Runway (months)    = Cash Balance / Monthly Net Burn
Rule of 40         = Revenue Growth % + Profit Margin %
Magic Number       = (Qn Rev - Qn-1 Rev) x 4 / Qn-1 S&M Spend
```

## Segment Analysis Template

Unit economics vary dramatically by segment. Always break down, never rely on
blended averages:

| Segment    | CAC     | LTV      | LTV:CAC | Payback   | Gross Margin |
|------------|---------|----------|---------|-----------|--------------|
| SMB        | $500    | $2,000   | 4:1     | 8 months  | 75%          |
| Mid-Market | $5,000  | $25,000  | 5:1     | 12 months | 80%          |
| Enterprise | $50,000 | $300,000 | 6:1     | 24 months | 85%          |

## Common Failure Modes

| Failure Mode                           | Why It Hurts                                      | Fix                                                |
|----------------------------------------|---------------------------------------------------|----------------------------------------------------|
| Celebrating LTV:CAC without payback    | 6:1 with 48-month payback is a cash trap          | Always pair LTV:CAC with payback period            |
| Ignoring gross margin in LTV           | Revenue-based LTV overstates by 20-30%            | Use ARPU x Margin % / Churn, not ARPU x Lifetime  |
| Scaling S&M with magic number <0.5     | Pouring gas on a broken engine                    | Fix GTM efficiency before increasing spend         |
| Simplistic LTV formulas for big decisions | Ignores expansion, discount rates, cohort variance | Use advanced models for material investment decisions |
| Forgetting time value of money         | $10K in 5 years is ~$7.8K today at 5% discount    | Apply NPV for LTV periods >24 months              |
| Comparing CAC across different paybacks | $5K CAC/24mo payback is worse than $8K CAC/8mo   | Compare CAC + payback together                     |
| Rule of 40 ignoring absolute burn      | Score of 50 means nothing with 3 months runway    | Pair Rule of 40 with burn rate and runway          |
| Blended segment economics              | "Average $2K CAC" hides $500 SMB + $20K Enterprise | Calculate unit economics per segment               |
| Confusing gross and contribution margin | 80% gross margin is 67% after variable costs      | Track both; use contribution margin for unit econ  |
| Ignoring working capital timing        | Annual upfront != monthly collection for runway    | Account for cash timing in runway calculations     |

## Quality Checklist

- [ ] LTV:CAC ratio AND payback period both calculated (never one without the other)
- [ ] LTV uses gross-margin-adjusted formula, not simple revenue x lifetime
- [ ] Unit economics calculated per segment, not just blended average
- [ ] Burn rate and runway pair with Rule of 40 score
- [ ] Magic number checked before scaling S&M spend
- [ ] COGS and variable costs clearly defined and separated
- [ ] OpEx growth rate compared to revenue growth rate (operating leverage)
- [ ] Cash timing (annual vs. monthly billing) factored into runway

## Relationship to Other Frameworks

- **SaaS Revenue Growth Metrics** — revenue and retention metrics that feed
  into LTV calculations
- **Finance Metrics Quick Reference** — fast lookup for all metrics
- **Feature Investment Analysis** — uses margin and contribution calculations
  for feature ROI
- **Acquisition Channel Evaluation** — uses CAC, LTV, payback for channel decisions
- **Business Health Diagnostic** — uses efficiency metrics for health checks
