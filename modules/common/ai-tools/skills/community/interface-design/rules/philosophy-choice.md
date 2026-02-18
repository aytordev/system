---
title: Every Choice Must Be A Choice
impact: CRITICAL
impactDescription: Unexplainable choices are defaults in disguise
tags: philosophy, intentionality, decisions
---

## Every Choice Must Be A Choice

**Impact: CRITICAL (Unexplainable choices are defaults in disguise)**

For every decision, you must be able to explain WHY — why this layout, this color temperature, this typeface, this spacing scale, this information hierarchy. If your answer is "it's common" or "it's clean" or "it works," you haven't chosen. You've defaulted. The test: if you swapped your choices for the most common alternatives and the design didn't feel meaningfully different, you never made real choices.

**Incorrect (defaulting without reasoning):**

```css
/* "Standard" dashboard layout */
.sidebar { width: 256px; }
.card { border-radius: 8px; padding: 16px; }
font-family: Inter, sans-serif;
color: #1f2937; /* gray-800 */
```

**Correct (every choice has a why):**

```css
/* Sidebar width: 280px because navigation is a peer to content in this tool */
.sidebar { width: 280px; }
/* Radius: 4px — sharp corners signal precision for this trading dashboard */
.card { border-radius: 4px; padding: 12px; }
/* Geist Mono: this is a developer tool, monospace reinforces technical context */
font-family: 'Geist Mono', monospace;
/* Near-black with slight blue: cold, focused, appropriate for data analysis */
color: #0f172a;
```
