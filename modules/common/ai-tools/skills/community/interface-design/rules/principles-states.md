---
title: States and Animation
impact: MEDIUM
impactDescription: Missing states make interfaces feel broken
tags: principles, states, hover, focus, animation, dark-mode
---

## States and Animation

**Impact: MEDIUM (Missing states make interfaces feel broken)**

Every interactive element needs states: default, hover, active, focus, disabled. Data needs states too: loading, empty, error. Missing states feel broken. Animation: fast micro-interactions (~150ms), smooth easing. Larger transitions (modals, panels) can be slightly longer (~200-250ms). Use deceleration easing. Avoid spring/bounce in professional interfaces. Dark mode: shadows are less visible — lean on borders. Semantic colors often need slight desaturation. The hierarchy system still applies, just with inverted values.

**Incorrect (missing states):**

```css
/* Button with no interactive states */
.button {
  background: var(--accent);
  color: white;
  /* No hover, no focus, no active, no disabled */
}
/* Data table with no empty/loading state */
.table { /* just the table, nothing for zero-data */ }
```

**Correct (complete state coverage):**

```css
.button {
  background: var(--accent);
  color: white;
  transition: background 150ms ease-out;
}
.button:hover { background: var(--accent-hover); }
.button:active { background: var(--accent-active); }
.button:focus-visible { outline: 2px solid var(--focus-ring); outline-offset: 2px; }
.button:disabled { opacity: 0.5; cursor: not-allowed; }
/* Data states */
.table-loading { /* skeleton rows */ }
.table-empty { /* illustration + message + action */ }
.table-error { /* error message + retry button */ }
```
