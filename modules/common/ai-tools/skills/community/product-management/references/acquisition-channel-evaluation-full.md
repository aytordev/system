# Acquisition Channel Evaluation — Full Framework

## Purpose

Evaluate whether to scale, test, or kill an acquisition channel based on unit
economics (CAC, LTV, payback), customer quality (retention, NRR), and
scalability (magic number, volume potential). This is a financial lens for
channel evaluation — not a channel strategy framework. Use it to make
data-driven go-to-market decisions and optimize channel mix for sustainable
growth.

Key principle: Never scale a channel with poor unit economics. Fix it first or
kill it. Pouring money into an inefficient channel accelerates failure.

## When to Use

- Evaluating whether to scale a channel (content, paid, events, partnerships)
- Deciding how to allocate marketing budget across channels
- Assessing whether to kill an underperforming channel
- Comparing channels to optimize ROI
- Planning annual marketing budget allocation

## When NOT to Use

- Channel is brand-new (less than 3 months, fewer than 100 customers) — not
  enough data
- Testing channel fit (this is for evaluation, not experimentation)
- Strategic channels where presence is required regardless of CAC (e.g.,
  enterprise field sales)
- You lack channel-level data (need CAC, retention tracked by source)

---

## The Evaluation Framework

Four dimensions, assessed in sequence:

### 1. Unit Economics

What does it cost to acquire, and what is the return?

| Metric | Formula | Threshold |
|--------|---------|-----------|
| CAC | Monthly Spend / Customers Acquired per Month | Compare to blended CAC |
| LTV | ARPU x Gross Margin x Avg Customer Lifetime (months) | Compare to blended LTV |
| LTV:CAC | LTV / CAC | Target >3:1 |
| Payback Period | CAC / (Monthly ARPU x Gross Margin %) | Target <12 months |

### 2. Customer Quality

Do customers from this channel stick around and expand?

- **Cohort retention rate** by channel (vs. blended)
- **Churn rate** by channel (vs. blended)
- **NRR (Net Revenue Retention)** by channel — expansion vs. contraction
- **ICP fit** — does the channel attract ideal customer profiles?

### 3. Scalability

Can this channel sustain growth at the volume needed?

| Metric | Formula | Good | Marginal | Poor |
|--------|---------|------|----------|------|
| Magic Number | (New MRR from channel x 4) / Channel S&M Spend | >0.75 | 0.5–0.75 | <0.5 |
| Addressable Volume | TAM of channel | Can scale 10x+ | Can scale 2–5x | Near saturation |
| CAC Trend | Month-over-month CAC direction | Decreasing | Stable | Increasing |

### 4. Strategic Fit

Does the channel align with go-to-market strategy?

- Customer segment match (SMB vs. enterprise)
- Sales motion compatibility (PLG vs. sales-led)
- Brand positioning alignment

---

## Decision Matrix

| LTV:CAC | Payback | Customer Quality | Scalability | Decision |
|---------|---------|------------------|-------------|----------|
| >3:1 | <12 months | Good retention | High volume | **Scale aggressively** |
| 2–3:1 | 12–18 months | Average retention | Medium volume | **Test and optimize** |
| <2:1 | >18 months | Poor retention | Low volume | **Kill or fix** |

---

## Process: 5 Steps

### Step 0 — Gather Context

Collect before starting evaluation:
- Channel name and monthly spend
- Duration of channel use (months)
- Customers acquired per month from this channel
- Channel CAC (or data to calculate it)
- Blended CAC and LTV across all channels
- Current MRR/ARR and target growth rate

### Step 1 — Evaluate Unit Economics

Calculate channel CAC, LTV:CAC ratio, and payback period. Compare to blended
metrics.

Scoring:
- LTV:CAC >3:1 and payback <12 months = strong
- LTV:CAC 2–3:1 or payback 12–18 months = marginal
- LTV:CAC <2:1 or payback >18 months = poor

### Step 2 — Assess Customer Quality

Compare channel-specific retention, churn, NRR, and ICP fit to blended averages.

Scoring:
- Lower churn + higher NRR + ICP match = high quality
- Similar to blended + mostly good fit = medium quality
- Higher churn + lower NRR + off ICP = low quality

### Step 3 — Evaluate Scalability

Calculate magic number, assess addressable volume, and determine CAC trend.

Scoring:
- Magic number >0.75 + large volume + stable/decreasing CAC = highly scalable
- Magic number 0.5–0.75 + medium volume + stable CAC = moderately scalable
- Magic number <0.5 + small volume + increasing CAC = not scalable

### Step 4 — Deliver Recommendation

Synthesize all dimensions into one of four outcomes (see below).

---

## Recommendation Patterns

### Pattern 1: Scale Aggressively

**Conditions:** LTV:CAC >3:1, payback <12 months, good customer quality, magic
number >0.75, large addressable volume.

**Action:**
1. Increase budget by 50–100% next month
2. Monitor CAC, magic number, and customer quality weekly
3. Scale until CAC increases >20% or magic number drops <0.75

### Pattern 2: Test and Optimize

**Conditions:** LTV:CAC 2–3:1, payback 12–18 months, average customer quality,
magic number 0.5–0.75.

**Diagnosis — identify the root cause:**
- High CAC: improve conversion rate, reduce cost-per-click, shorten sales cycle
- Low LTV: improve onboarding, target higher-value segments, add expansion plays
- Poor targeting: narrow audience, improve messaging, add qualification steps

**Timeline:** 4–8 weeks of optimization. If targets are met (LTV:CAC >3:1,
payback <12 months), scale. If not, consider killing.

### Pattern 3: Kill or Pause

**Conditions:** LTV:CAC <1.5:1, no clear path to improvement.

**Action:** Stop spending. Reallocate budget to top-performing channels.

**Exception:** If spend is <10% of total S&M, pause instead of killing — not
worth the optimization effort.

### Pattern 4: Invest to Learn (Strategic Channel)

**Conditions:** Poor unit economics but strategic importance (enterprise channel,
brand building, long-term positioning).

**Action:**
1. Cap spend — do not scale until economics improve
2. Track leading indicators (pipeline influence, brand awareness, referral rate)
3. Re-evaluate quarterly
4. Set a 6–12 month deadline; if no improvement, kill or reduce drastically

---

## Channel Comparison Template

When evaluating multiple channels side by side:

```markdown
| Channel | CAC | LTV | LTV:CAC | Payback | Magic # | Quality | Decision |
|---------|-----|-----|---------|---------|---------|---------|----------|
| [name]  | $   | $   | x:1     | Xmo     | X.X     | H/M/L   | Scale/Test/Kill |
```

Budget allocation rule: Rank channels by LTV:CAC and magic number. Scale the
top performers first; optimize marginal channels; kill the rest.

---

## Examples

**Scale — Content Marketing:**
CAC $200, LTV $3,000, LTV:CAC 15:1, payback 3 months, magic number 1.8, high
quality. Action: increase content spend 2–3x.

**Optimize — Paid Search:**
CAC $800, LTV $2,000, LTV:CAC 2.5:1, payback 14 months, magic number 0.6,
lower quality (high churn in first 90 days). Action: improve landing page,
target higher-intent keywords, fix onboarding before scaling.

**Kill — Trade Shows:**
CAC $20,000, LTV $30,000, LTV:CAC 1.5:1, payback 30 months, magic number 0.2,
low quality (off-ICP, tire-kickers). Action: kill, reallocate budget.

---

## Common Pitfalls

1. **Scaling broken channels** — Throwing money at a channel with LTV:CAC <2:1
   accelerates cash burn. Fix economics first.

2. **Ignoring customer quality** — Low CAC means nothing if customers churn in
   30 days. Track cohort retention by channel.

3. **Celebrating vanity metrics** — Signups, impressions, and clicks do not pay
   bills. Calculate CAC on paid customers only.

4. **Averaging across channels** — Blended CAC hides that one channel costs 10x
   the others. Track metrics per channel.

5. **Optimizing CAC alone** — Reducing CAC by targeting low-intent users lowers
   LTV too. Optimize for LTV:CAC ratio.

6. **Ignoring payback period** — LTV:CAC of 6:1 with 48-month payback is a cash
   trap. Pair ratio with payback.

7. **Killing channels too early** — Give channels 3–6 months and 100+ customers
   before evaluating. Track trends, not snapshots.

8. **Over-relying on one channel** — No single channel should exceed 50% of new
   customer acquisition. Algorithm changes or competitor moves can collapse it.

9. **Forgetting incrementality** — Retargeting campaigns may claim credit for
   conversions that would have happened organically. Test with holdout groups.

10. **Strategic channels without limits** — "Strategic" is not a blank check.
    Cap spend and set a deadline for improvement.

---

## Related Frameworks

- **SaaS Economics / Efficiency Metrics** — CAC, LTV, payback, magic number
  formulas
- **SaaS Revenue Growth Metrics** — NRR, churn, cohort analysis by channel
- **Feature Investment Advisor** — Similar ROI framework applied to feature
  decisions
- **Brian Balfour (Reforge)** — Channel-product fit
- **David Skok** — SaaS Metrics for channels
