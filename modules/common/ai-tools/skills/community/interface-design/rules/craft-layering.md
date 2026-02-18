---
title: Subtle Layering
impact: HIGH
impactDescription: Backbone of professional interfaces
tags: craft, surfaces, borders, elevation
---

## Subtle Layering

**Impact: HIGH (Backbone of professional interfaces)**

Surfaces stack: dropdown above card above page. Build a numbered elevation system — each jump only a few percentage points of lightness. In dark mode, higher = slightly lighter. You should barely notice the system working. Borders use low opacity rgba that blends with the background — defining edges without demanding attention. Sidebars: same background as canvas, subtle border separation (not different color). Dropdowns: one level above parent surface. Inputs: slightly darker (inset — they receive content). The squint test: blur your eyes, perceive hierarchy without harshness.

**Incorrect (dramatic surface jumps and harsh borders):**

```css
/* Dramatic jumps between surfaces */
--surface-base: #0a0a0a;
--surface-card: #1f1f1f; /* 13% jump — too dramatic */
--surface-dropdown: #333333; /* another huge jump */
/* Harsh solid borders */
border: 1px solid #555555;
/* Sidebar as separate world */
.sidebar { background: #1a1a2e; } /* different hue */
.content { background: #0a0a0a; }
```

**Correct (whisper-quiet surface shifts):**

```css
/* Subtle elevation: barely different, still distinguishable */
--surface-base: #0a0a0a;
--surface-100: #111111; /* ~3% lighter */
--surface-200: #161616; /* ~5% lighter */
--surface-300: #1c1c1c; /* ~7% lighter */
/* Low opacity borders that blend */
--border-default: rgba(255, 255, 255, 0.06);
--border-subtle: rgba(255, 255, 255, 0.04);
--border-strong: rgba(255, 255, 255, 0.10);
/* Sidebar: same background, border separation */
.sidebar { background: var(--surface-base); border-right: 1px solid var(--border-default); }
.content { background: var(--surface-base); }
```
