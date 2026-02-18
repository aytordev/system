---
title: Infinite Expression
impact: HIGH
impactDescription: Same pattern has infinite valid implementations
tags: craft, variety, anti-template
---

## Infinite Expression

**Impact: HIGH (Same pattern has infinite valid implementations)**

Every pattern has infinite expressions. A metric display could be a hero number, inline stat, sparkline, gauge, progress bar, comparison delta, or trend badge. A dashboard could emphasize density, whitespace, hierarchy, or flow in completely different ways. Before building, ask: what's the ONE thing users do most here? What products solve similar problems brilliantly? Why would this feel designed for its purpose, not templated? Never produce identical output. Same sidebar width, same card grid, same metric boxes with icon-left-number-big-label-small every time signals AI-generated immediately.

**Incorrect (template metric card):**

```html
<!-- Every metric looks the same: icon + big number + label -->
<div class="card">
  <div class="icon">📊</div>
  <div class="value">1,234</div>
  <div class="label">Total Orders</div>
</div>
<!-- Repeated 4x with different icons -->
```

**Correct (metric expression matches the data's story):**

```html
<!-- Revenue: hero number with trend — this is THE number they came to see -->
<div class="revenue-hero">
  <span class="amount">$12,450</span>
  <span class="trend up">+12.3%</span>
</div>
<!-- Fulfillment: progress ring — shows completion, not just a count -->
<div class="fulfillment-ring">
  <svg><!-- 73% ring --></svg>
  <span>38 of 52</span>
</div>
<!-- Wait time: sparkline — the trend matters more than the number -->
<div class="wait-sparkline">
  <canvas><!-- 24h trend --></canvas>
  <span class="current">4.2 min</span>
</div>
```
