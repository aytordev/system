---
title: Typography Hierarchy
impact: MEDIUM
impactDescription: Size alone is not hierarchy
tags: principles, typography, fonts, hierarchy
---

## Typography Hierarchy

**Impact: MEDIUM (Size alone is not hierarchy)**

Build distinct levels distinguishable at a glance. Headlines need weight and tight tracking for presence. Body needs comfortable weight for readability. Labels need medium weight that works at smaller sizes. Data needs monospace with `tabular-nums` for alignment. Don't rely on size alone — combine size, weight, and letter-spacing. If you squint and can't tell headline from body, the hierarchy is too weak. Numbers, IDs, codes, timestamps belong in monospace.

**Incorrect (size-only hierarchy):**

```css
/* Only size differentiates levels */
.headline { font-size: 24px; font-weight: 400; }
.body { font-size: 16px; font-weight: 400; }
.label { font-size: 14px; font-weight: 400; }
.data { font-size: 14px; font-weight: 400; font-family: inherit; }
```

**Correct (multi-dimensional hierarchy):**

```css
.headline {
  font-size: 24px;
  font-weight: 600;
  letter-spacing: -0.025em; /* tight for presence */
}
.body {
  font-size: 15px;
  font-weight: 400;
  line-height: 1.6;
}
.label {
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.01em;
}
.data {
  font-family: 'Geist Mono', monospace;
  font-size: 13px;
  font-variant-numeric: tabular-nums; /* aligned columns */
}
```
