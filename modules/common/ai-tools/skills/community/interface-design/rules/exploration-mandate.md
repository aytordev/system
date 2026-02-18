---
title: The Mandate
impact: HIGH
impactDescription: Catch generic output before the user has to
tags: exploration, validation, self-review
---

## The Mandate

**Impact: HIGH (Catch generic output before the user has to)**

Before showing the user, look at what you made. Ask: "If they said this lacks craft, what would they mean?" Fix it first. Run four checks. **The swap test:** swap the typeface for your usual one — would anyone notice? **The squint test:** blur your eyes — can you still perceive hierarchy without harshness? **The signature test:** point to five specific elements where your signature appears — not "the overall feel." **The token test:** read your CSS variables out loud — do they sound like they belong to this product's world? If any check fails, iterate before showing.

**Incorrect (shipping first draft):**

```css
/* Default tokens that could be any project */
--color-primary: #3b82f6;
--color-secondary: #64748b;
--surface: #ffffff;
--text: #1e293b;
/* Generic layout */
.dashboard { display: grid; grid-template-columns: 256px 1fr; }
```

**Correct (passed all four checks):**

```css
/* Tokens that belong to a bakery management tool */
--crust: #c2956a;
--flour: #faf8f5;
--rye: #3d2c1e;
--copper: #b87333;
--parchment: #f5f0eb;
/* Layout driven by the domain: timeline-first, not grid-first */
.kitchen { display: grid; grid-template-columns: 280px 1fr; }
.batch-timeline { /* signature element: fermentation curve */ }
```
