---
title: Common Mistakes to Avoid
impact: MEDIUM
impactDescription: Quick reference for frequent anti-patterns
tags: principles, anti-patterns, checklist
---

## Common Mistakes to Avoid

**Impact: MEDIUM (Quick reference for frequent anti-patterns)**

Avoid these common design mistakes: harsh borders that dominate over content, dramatic surface jumps between elevation levels, inconsistent spacing (the clearest sign of no system), mixed depth strategies, missing interaction states, dramatic drop shadows, large radius on small elements, pure white cards on colored backgrounds, thick decorative borders, gradients and color used for decoration rather than meaning, multiple accent colors that dilute focus, and different hues for different surfaces when only lightness should shift.

**Incorrect (multiple anti-patterns):**

```css
/* Harsh borders + dramatic shadows + decoration */
.card {
  border: 2px solid #94a3b8; /* too thick, too visible */
  box-shadow: 0 8px 24px rgba(0,0,0,0.25); /* dramatic */
  background: linear-gradient(135deg, #667eea, #764ba2); /* decorative gradient */
  border-radius: 24px; /* too large for a card */
}
/* Multiple accent colors */
--accent-1: #3b82f6;
--accent-2: #8b5cf6;
--accent-3: #06b6d4;
/* Pure white card on colored background */
.page { background: #f1f5f9; }
.card { background: #ffffff; } /* stark contrast */
```

**Correct (subtle, systematic approach):**

```css
.card {
  border: 0.5px solid rgba(0, 0, 0, 0.08); /* barely there */
  /* No shadow — committed to borders-only */
  background: var(--surface-100); /* slight shift, not pure white */
  border-radius: 6px; /* proportional to element size */
}
/* One accent color, used with intention */
--accent: #b87333;
/* Surface that relates to background */
.page { background: var(--surface-base); }
.card { background: var(--surface-100); } /* 2-3% lighter, not stark */
```
