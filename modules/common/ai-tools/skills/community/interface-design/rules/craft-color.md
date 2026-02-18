---
title: Color Lives Somewhere
impact: HIGH
impactDescription: Palettes should come from the product world
tags: craft, color, domain, palette
---

## Color Lives Somewhere

**Impact: HIGH (Palettes should come from the product world)**

Every product exists in a world. That world has colors. Before reaching for a palette, spend time in the product's world — what would you see in the physical version of this space? Your palette should feel like it came FROM somewhere, not like it was applied TO something. Go beyond warm/cold: is this quiet or loud? Dense or spacious? Serious or playful? Gray builds structure. Color communicates — status, action, emphasis, identity. Unmotivated color is noise. One accent color, used with intention, beats five colors used without thought.

**Incorrect (applied palette with no connection to domain):**

```css
/* Generic palette for a woodworking tool management app */
--primary: #3b82f6; /* blue — why blue? */
--secondary: #8b5cf6; /* purple — decoration */
--accent: #06b6d4; /* cyan — more decoration */
--success: #22c55e;
--warning: #f59e0b;
/* Multiple accent colors dilute focus */
```

**Correct (palette rooted in the product's world):**

```css
/* Woodworking tool management — colors from the workshop */
--oak: #8b6f47; /* primary — warm wood tone */
--sawdust: #f5f0e8; /* surfaces — workshop light */
--iron: #44403c; /* text — tool metal */
--workbench: #292524; /* dark surfaces — worn wood */
--varnish: #a16207; /* accent — one color, intentional */
/* Semantic colors still functional but warmer */
--ready: #65a30d; /* olive, not neon green */
--caution: #ca8a04; /* amber, not yellow */
```
