---
title: Where Defaults Hide
impact: CRITICAL
impactDescription: Defaults disguise themselves as infrastructure
tags: philosophy, defaults, awareness
---

## Where Defaults Hide

**Impact: CRITICAL (Defaults disguise themselves as infrastructure)**

Defaults don't announce themselves. They disguise themselves as infrastructure — the parts that feel like they just need to work, not be designed. Typography, navigation, data display, and token names are all design decisions, not structural ones. The moment you stop asking "why this?" is the moment defaults take over.

**Incorrect (treating infrastructure as non-design):**

```css
/* Typography: just pick something readable */
font-family: system-ui, sans-serif;
/* Navigation: just build the sidebar */
.sidebar { width: 250px; background: #f5f5f5; }
/* Data: just show the number */
.metric { font-size: 24px; }
/* Tokens: generic names */
--gray-700: #374151;
--surface-2: #f9fafb;
```

**Correct (every decision is design):**

```css
/* Typography shapes how the product feels before anyone reads a word */
font-family: 'Instrument Sans', sans-serif; /* chosen for warmth */
/* Navigation IS the product — where you are, where you can go */
.sidebar { width: 280px; /* "navigation serves content" proportion */ }
/* A number on screen is not design — what does it mean to this person? */
.metric { /* progress ring, not just a number */ }
/* Token names should evoke the product's world */
--ink: #1a1a2e;
--parchment: #faf8f5;
```
