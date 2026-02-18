---
title: Components and Controls
impact: MEDIUM
impactDescription: Cards, controls, icons, and navigation need design attention
tags: principles, cards, controls, icons, navigation
---

## Components and Controls

**Impact: MEDIUM (Cards, controls, icons, and navigation need design attention)**

Card layouts: a metric card doesn't have to look like a plan card. Design each card's internal structure for its content, but keep surface treatment consistent (same border, shadow, radius, padding). Controls: never use native `<select>` or `<input type="date">` — they render OS-native elements that cannot be styled. Build custom components. Icons clarify, not decorate — if removing an icon loses no meaning, remove it. Choose one icon set. Navigation provides context: screens need grounding, not floating in space. Sidebar: same background as content, border separation.

**Incorrect (native controls and decorative icons):**

```html
<!-- Native select can't be styled -->
<select>
  <option>Option 1</option>
  <option>Option 2</option>
</select>
<!-- Native date picker -->
<input type="date" />
<!-- Decorative icons that add no meaning -->
<span>🔵</span> Settings
<span>🔵</span> Profile
<span>🔵</span> Notifications
```

**Correct (custom controls and meaningful icons):**

```html
<!-- Custom select: trigger + positioned dropdown -->
<button class="select-trigger" aria-haspopup="listbox">
  <span>Option 1</span>
  <svg class="chevron"><!-- chevron-down --></svg>
</button>
<div class="select-dropdown" role="listbox"><!-- options --></div>
<!-- Custom date picker: input + calendar popover -->
<button class="date-trigger">
  <span>Feb 18, 2026</span>
  <svg><!-- calendar icon --></svg>
</button>
<!-- Icons that clarify meaning -->
<svg><!-- gear --></svg> Settings
<svg><!-- user --></svg> Profile
<svg><!-- bell --></svg> Notifications
```
