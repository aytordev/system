# Feature Investment Analysis — Full Framework

## Purpose

Evaluate whether to build a feature based on financial impact analysis. This is
a financial lens for feature decisions — not a generic prioritization framework.
It complements other methods (RICE, value vs. effort, user research) by
quantifying revenue connection, cost structure, ROI, and strategic value to
produce actionable build/don't build recommendations with supporting math.

Key principle: Every feature is an investment. Evaluate it like one — with
expected return, cost basis, payback period, and risk assessment.

## When to Use

- Prioritizing features with quantifiable revenue or retention impact
- Evaluating expensive features (more than 1 engineer-month of work)
- Making build/buy/partner decisions
- Defending feature prioritization to stakeholders or leadership
- Choosing between direct monetization (add-on) vs. indirect (retention)

## When NOT to Use

- Feature is table stakes (must-have for competitive parity — just build it)
- Impact is purely qualitative (brand, UX delight with no measurable effect)
- Problem has not been validated (do discovery first)
- Feature is less than 1 week of work (not worth the analysis overhead)

---

## The Feature Investment Framework

Four dimensions, assessed in sequence:

### 1. Revenue Connection

How does this feature impact revenue?

| Type | Description | Calculation |
|------|-------------|-------------|
| Direct monetization | New tier, add-on, usage charge | Customer Base x Adoption Rate x Price |
| Retention improvement | Reduces churn | Churn Prevented x ARPU x Avg Lifetime |
| Conversion improvement | Trial-to-paid lift | Trial Users x Conversion Lift x ARPU |
| Expansion enabler | Upsell/cross-sell path | Customer Base x Expansion Rate x ARPU Increase |
| No direct impact | Table stakes, platform work | Skip to strategic value |

### 2. Cost Structure

What does it cost to build and run?

| Cost Type | Nature | Example |
|-----------|--------|---------|
| Development cost | One-time | Team size x duration x loaded cost |
| COGS impact | Ongoing monthly | Hosting, infrastructure, processing |
| OpEx impact | Ongoing monthly | Support, maintenance, monitoring |

**Key metric:** Contribution margin impact = (Revenue - COGS) / Revenue

Flag if COGS exceeds 20% of projected revenue — the feature significantly
dilutes margins.

### 3. ROI Calculation

Is the return worth the investment?

| Revenue Type | ROI Formula | Good | Marginal | Poor |
|--------------|-------------|------|----------|------|
| Direct monetization | Annual Revenue x Margin / Dev Cost | >3:1 | 1.5–3:1 | <1.5:1 |
| Retention feature | LTV Impact Across Base / Dev Cost | >10:1 | 3–10:1 | <3:1 |

**Payback period** = Dev Cost / Monthly Net Revenue. Must be shorter than
average customer lifetime.

### 4. Strategic Value

Non-financial value that might override pure ROI:

- **Competitive moat** — prevents churn to a competitor
- **Platform enabler** — unlocks future features or integrations
- **Market positioning** — needed for enterprise deals or market credibility
- **Risk reduction** — compliance, security, regulatory requirements

---

## Process: 5 Steps

### Step 0 — Gather Context

Collect before starting:
- Feature description (1–2 sentences) and target segment
- Current MRR/ARR, ARPU, monthly churn rate, gross margin %
- Development cost estimate (team size x time)
- Ongoing COGS or OpEx implications

### Step 1 — Identify Revenue Connection

Determine which type of revenue impact applies, then calculate:

**Direct monetization:**
```
Potential Monthly Revenue = Customer Base x Adoption Rate x Price
```
Use conservative (10%), base (20%), and optimistic (30%) adoption scenarios.

**Retention improvement:**
```
Customers Churned Annually = Base x Annual Churn Rate
Churn Addressed = Churned x % Citing This Gap
Churn Prevented = Addressed x Expected Reduction (50% conservative)
LTV Impact = Churn Prevented x ARPU x Margin x Avg Lifetime (months)
```

**Conversion improvement:**
```
Additional MRR = Trial Users x Conversion Lift x ARPU
```

**Expansion enabler:**
```
Expansion MRR = Customer Base x Expansion Rate x ARPU Increase
```

### Step 2 — Assess Cost Structure

Calculate total investment and ongoing costs:
- One-time: development cost
- Ongoing: monthly COGS + OpEx
- Contribution margin impact on the new revenue

### Step 3 — Evaluate Constraints and Timing

Consider which applies:
- **Competitive threat** — urgency increases strategic value
- **Limited capacity** — compare ROI against other backlog items
- **Dependencies** — flag sequencing risk
- **No constraints** — proceed to recommendation

### Step 4 — Deliver Recommendation

Synthesize into one of four outcomes (see below).

---

## Recommendation Patterns

### Pattern 1: Build Now (Strong Financial Case)

**Conditions:** ROI >3:1 (direct) or >10:1 (retention), positive contribution
margin, payback < average customer lifetime.

**Output includes:**
- Revenue impact (conservative and optimistic)
- Total cost (dev + ongoing)
- Net margin impact
- Year 1 ROI and payback period
- Next steps: validate assumptions, build MVP, monitor key metric

### Pattern 2: Build for Strategic Reasons (Weak Financial Case)

**Conditions:** ROI <2:1 or marginal financial impact, but high strategic value
(competitive moat, platform enabler, compliance).

**Output includes:**
- Financial reality (revenue, cost, ROI below threshold)
- Strategic justification with specifics
- Monitoring plan: adoption targets, churn impact targets
- Risk acknowledgment: opportunity cost of not building higher-ROI features

### Pattern 3: Don't Build (Poor ROI)

**Conditions:** ROI <1:1, margin-diluting, no compelling strategic value.

**Output includes:**
- Why the numbers do not support it
- Alternative approaches: reduce scope (50% cost?), change monetization, deprioritize
- What would need to change to make it viable (adoption rate X, dev cost Y)

### Pattern 4: Build Later (Need More Data)

**Conditions:** High uncertainty in assumptions, unvalidated hypotheses, medium
strategic value.

**Output includes:**
- Current uncertainty (adoption rate, churn impact, pricing all unvalidated)
- Validation steps: demand survey (50+ customers), prototype test, churn interviews
- Decision criteria: if X% say they would pay $Y, build; otherwise deprioritize
- Timeline: 2–4 weeks of validation before re-evaluation

---

## Sensitivity Analysis Template

Test how recommendation changes under different assumptions:

```markdown
| Scenario | Adoption | Revenue/mo | ROI | Payback | Decision |
|----------|----------|------------|-----|---------|----------|
| Conservative | 10% | $X | X:1 | Xmo | [build/wait/kill] |
| Base | 20% | $X | X:1 | Xmo | [build/wait/kill] |
| Optimistic | 30% | $X | X:1 | Xmo | [build/wait/kill] |
```

If the decision changes between conservative and base, you need more data
before committing.

---

## Examples

### Example 1: Direct Monetization — Time Tracking Add-On

**Context:** 1,000 customers, $500 ARPU, 80% gross margin. Feature: time
tracking add-on at $10/user/month. Dev cost: $100K.

**Calculation:**
- 10,000 users (10/account avg) x 20% adoption = 2,000 users
- Revenue: $20K/month = $240K/year
- Margin: $240K x 80% = $192K gross profit/year
- ROI: $192K / $100K = 1.92:1 year 1; 3.8:1 year 2
- Payback: $100K / $20K = 5 months

**Decision:** Build now. Fast payback (5 months), strong margin, conservative
adoption estimate.

### Example 2: Retention Feature — Data Export

**Context:** $2M MRR, 500 customers, $4K ARPA, 5% monthly churn. 30% of
churned customers cited data export as a reason. Dev cost: $150K.

**Calculation:**
- Annual churn: ~230 customers
- Churned due to export gap: 230 x 30% = 69 customers
- If feature reduces this by 50%: 35 customers saved/year
- MRR saved: 35 x $4K = $140K/year
- LTV impact: $140K x 24 months = $3.36M
- ROI: $3.36M / $150K = 22.4:1

**Decision:** Build immediately. Even at 25% reduction (not 50%), ROI is 11:1.

### Example 3: Weak Evidence — Dark Mode

**Context:** $500K MRR, 2,000 customers, $250 ARPA, 3% monthly churn. 50 users
requested dark mode. No churn data linking this feature.

**Calculation:**
- 50 requests = 2.5% of base
- Optimistic: prevents 5 churns/year = $15K/year
- LTV impact: $360K (very optimistic)
- ROI: $360K / $80K = 4.5:1 (based on weak assumptions)

**Decision:** Build later. Survey churned customers first. If dark mode is a
top-3 churn reason, build. Otherwise, deprioritize.

---

## Common Pitfalls

1. **Confusing revenue with profit** — $1M revenue at 20% margin is $200K
   profit, not $1M. Always use contribution margin.

2. **Ignoring payback period** — ROI of 5:1 means nothing if payback is 36
   months and customers churn at 24. Payback must be shorter than customer
   lifetime.

3. **Overestimating adoption** — Real adoption for add-ons is 10–20%, not 100%.
   Use conservative estimates and validate with willingness-to-pay research.

4. **Building without validation** — "We think this will reduce churn" is a
   hypothesis, not evidence. Interview churned customers first.

5. **Ignoring opportunity cost** — A feature with 2:1 ROI is bad if other
   features in the backlog have 10:1 ROI. Compare across options.

6. **Strategic value as excuse** — If you cannot name the specific strategic
   reason (competitive moat, platform enabler, compliance), it is not strategic.

7. **Margin dilution blindness** — A feature that adds $500K revenue but $400K
   COGS drops gross margin from 80% to 60%. Calculate margin impact.

8. **Celebrating vanity metrics** — "Increases engagement" is a leading
   indicator, not a business outcome. Tie features to revenue or retention.

9. **Forgetting time value of money** — $1 in 5 years is worth about $0.65
   today. For payback >24 months, use NPV with an appropriate discount rate.

10. **Building for loud minorities** — 50 requests out of 10,000 customers is
    0.5%. Weight requests by revenue impact or segment alignment.

---

## Related Frameworks

- **RICE / ICE / Kano** — Prioritization frameworks this analysis complements
- **SaaS Revenue Growth Metrics** — Revenue, ARPU, churn, NRR used in
  calculations
- **SaaS Economics / Efficiency Metrics** — ROI, payback, contribution margin
  formulas
- **Acquisition Channel Advisor** — Same ROI framework applied to channels
- **Opportunity Solution Tree (Teresa Torres)** — Map opportunities before
  calculating ROI
- **Jobs-to-be-Done** — Understand customer problems before financial analysis
