---
title: Sameness Is Failure
impact: HIGH
impactDescription: Generic output signals no design intent
tags: philosophy, uniqueness, anti-template
---

## Sameness Is Failure

**Impact: HIGH (Generic output signals no design intent)**

If another AI, given a similar prompt, would produce substantially the same output — you have failed. This is not about being different for its own sake. It's about the interface emerging from the specific problem, user, and context. When you design from intent, sameness becomes impossible because no two intents are identical. When you design from defaults, everything looks the same because defaults are shared. Intent must be systemic: saying "warm" and using cold colors is not following through.

**Incorrect (intent as label only):**

```css
/* Intent stated: "warm and friendly" */
/* But implementation uses cold defaults */
--background: #f8fafc; /* slate-50 — cold */
--text: #334155; /* slate-700 — cold */
--border: #e2e8f0; /* slate-200 — cold */
--accent: #3b82f6; /* blue — cold */
border-radius: 8px; /* generic */
```

**Correct (intent carried through every token):**

```css
/* Intent: warm and friendly — every token reinforces it */
--background: #faf8f5; /* warm paper tone */
--text: #44403c; /* stone-700 — warm */
--border: #e7e5e4; /* stone-200 — warm */
--accent: #ea580c; /* orange — warm */
border-radius: 12px; /* soft, approachable */
```
