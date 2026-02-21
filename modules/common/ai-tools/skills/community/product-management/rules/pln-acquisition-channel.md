---
title: Acquisition Channel Evaluation
impact: MEDIUM
impactDescription: Investing in channels without unit economics data burns budget on unscalable growth
tags: planning, acquisition, cac, unit-economics, growth, channels
---

## Acquisition Channel Evaluation

**Impact: MEDIUM (Investing in channels without unit economics data burns budget on unscalable growth)**

Evaluate each active or candidate acquisition channel using three unit economics metrics: Customer Acquisition Cost (CAC), conversion rate at each funnel stage, and CAC payback period. Assign a scale/test/kill verdict to each channel based on whether the payback period is within your cash runway and whether CAC is below LTV/3. Use this when planning a growth quarter, allocating marketing budget, or auditing why growth has stalled. Do not apply this to brand or community channels where attribution is inherently indirect — those require separate qualitative evaluation.

**Incorrect (channel list with no economics, no verdict):**

```markdown
## Q3 Growth Channels

- Google Ads — performing well, keep running
- LinkedIn Ads — expensive but good leads
- Content SEO — slow but building
- Referral program — launched last quarter
- Cold outbound — SDR team is working it

Action: increase budget across the board
```

**Correct (channel-by-channel unit economics with scale/test/kill verdict):**

```markdown
## Q3 Acquisition Channel Evaluation

| Channel       | CAC    | Conv. Rate | Payback Period | Verdict |
|---------------|--------|------------|----------------|---------|
| Google Ads    | $420   | 3.2%       | 7 months       | SCALE   |
| LinkedIn Ads  | $1,800 | 1.1%       | 30 months      | KILL    |
| Content SEO   | $210   | 2.8%       | 4 months       | SCALE   |
| Referral      | $95    | 8.4%       | 2 months       | SCALE   |
| Cold outbound | $640   | 0.9%       | 11 months      | TEST    |

Verdicts:
- SCALE: CAC payback < 12 months and conv. rate above category benchmark
- TEST: Payback 12–18 months; run 60-day capped experiment before committing
- KILL: Payback > 18 months or conv. rate below breakeven threshold

Q3 budget reallocation: shift 60% of LinkedIn spend to Referral and SEO.
```

Reference: [Full framework](../references/acquisition-channel-evaluation-full.md)
