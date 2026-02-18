---
title: Depth and Elevation Strategy
impact: MEDIUM
impactDescription: Choose one approach and commit
tags: principles, depth, shadows, borders, elevation
---

## Depth and Elevation Strategy

**Impact: MEDIUM (Choose one approach and commit)**

Choose ONE depth approach and commit. **Borders-only:** clean, technical, dense — for utility tools (Linear, Raycast). **Subtle shadows:** soft lift — for approachable products. **Layered shadows:** premium, dimensional — for cards needing presence (Stripe). **Surface color shifts:** background tints establish hierarchy without shadows. Don't mix approaches. Border radius: sharper feels technical, rounder feels friendly. Build a scale (small for inputs, medium for cards, large for modals) and use it consistently.

**Incorrect (mixed depth approaches):**

```css
/* Some cards have shadows, some have borders, some have both */
.card-1 { border: 1px solid #e2e8f0; }
.card-2 { box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
.card-3 { border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
/* Inconsistent radius */
.button { border-radius: 4px; }
.card { border-radius: 12px; }
.input { border-radius: 8px; }
.modal { border-radius: 4px; }
```

**Correct (borders-only strategy, consistent radius):**

```css
/* Committed: borders-only for this dense developer tool */
--border: rgba(0, 0, 0, 0.08);
--border-subtle: rgba(0, 0, 0, 0.05);
.card { border: 0.5px solid var(--border); }
.dropdown { border: 0.5px solid var(--border); }
.modal { border: 0.5px solid var(--border); }
/* Consistent radius scale: sharp (technical) */
--radius-sm: 4px;  /* inputs, buttons */
--radius-md: 6px;  /* cards */
--radius-lg: 8px;  /* modals */
```
