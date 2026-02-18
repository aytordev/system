---
title: Spacing System
impact: MEDIUM
impactDescription: Random values signal no system
tags: principles, spacing, grid, padding
---

## Spacing System

**Impact: MEDIUM (Random values signal no system)**

Pick a base unit (4px or 8px) and stick to multiples. Build a scale for different contexts: micro spacing (icon gaps), component spacing (within buttons/cards), section spacing (between groups), major separation (between sections). Every value must be explainable as a multiple of the base unit. Keep padding symmetrical — if top is 16px, sides should match unless content naturally requires asymmetry.

**Incorrect (random spacing values):**

```css
/* No system — random values everywhere */
.card { padding: 18px 14px 12px 14px; }
.button { padding: 7px 13px; margin-bottom: 15px; }
.section { gap: 22px; }
.icon-gap { margin-right: 5px; }
```

**Correct (systematic spacing on 4px grid):**

```css
/* Base: 4px, all values are multiples */
--space-1: 4px;   /* micro: icon gaps */
--space-2: 8px;   /* component: tight pairs */
--space-3: 12px;  /* component: button padding */
--space-4: 16px;  /* section: card padding */
--space-6: 24px;  /* section: group gaps */
--space-8: 32px;  /* major: section separation */

.card { padding: var(--space-4); } /* 16px all sides */
.button { padding: var(--space-2) var(--space-3); } /* 8px 12px */
.section { gap: var(--space-6); } /* 24px */
.icon-gap { margin-right: var(--space-1); } /* 4px */
```
