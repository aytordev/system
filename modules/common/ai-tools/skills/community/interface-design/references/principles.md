# Core Craft Principles

These apply regardless of design direction. This is the quality floor.

---

## Surface & Token Architecture

Professional interfaces don't pick colors randomly — they build systems. Understanding this architecture is the difference between "looks okay" and "feels like a real product."

### The Primitive Foundation

Every color in your interface should trace back to a small set of primitives:

- **Foreground** — text colors (primary, secondary, muted)
- **Background** — surface colors (base, elevated, overlay)
- **Border** — edge colors (default, subtle, strong)
- **Brand** — your primary accent
- **Semantic** — functional colors (destructive, warning, success)

Don't invent new colors. Map everything to these primitives.

### Surface Elevation Hierarchy

Surfaces stack. A dropdown sits above a card which sits above the page. Build a numbered system:

```
Level 0: Base background (the app canvas)
Level 1: Cards, panels (same visual plane as base)
Level 2: Dropdowns, popovers (floating above)
Level 3: Nested dropdowns, stacked overlays
Level 4: Highest elevation (rare)
```

In dark mode, higher elevation = slightly lighter. In light mode, higher elevation = slightly lighter or uses shadow.

### The Subtlety Principle

Study Vercel, Supabase, Linear — their surfaces are **barely different** but still distinguishable. Their borders are **light but not invisible**.

**For surfaces:** The difference between elevation levels should be subtle — a few percentage points of lightness. In dark mode, surface-100 might be 7% lighter than base, surface-200 might be 9%, surface-300 might be 12%.

**For borders:** Use low opacity (0.05-0.12 alpha for dark mode, slightly higher for light). The border should disappear when you're not looking for it, but be findable when you need to understand the structure.

**The test:** Squint at your interface. You should still perceive the hierarchy — what's above what, where regions begin and end. But no single border or surface should jump out. If borders are the first thing you notice, they're too strong. If you can't find where one region ends and another begins, they're too subtle.

### Text Hierarchy via Tokens

Build four levels:

- **Primary** — default text, highest contrast
- **Secondary** — supporting text, slightly muted
- **Tertiary** — metadata, timestamps, less important
- **Muted** — disabled, placeholder, lowest contrast

### Border Progression

Build a scale:

- **Default** — standard borders
- **Subtle/Muted** — softer separation
- **Strong** — emphasis, hover states
- **Stronger** — maximum emphasis, focus rings

### Dedicated Control Tokens

Form controls need dedicated tokens:

- **Control background** — often different from surface backgrounds
- **Control border** — needs to feel interactive
- **Control focus** — clear focus indication

---

## Spacing System

Pick a base unit and use multiples throughout. Build a scale for different contexts:
- Micro spacing (icon gaps, tight element pairs)
- Component spacing (within buttons, inputs, cards)
- Section spacing (between related groups)
- Major separation (between distinct sections)

## Symmetrical Padding

TLBR must match unless content naturally creates visual balance.

```css
/* Good */
padding: 16px;
padding: 12px 16px; /* Only when horizontal needs more room */

/* Bad */
padding: 24px 16px 12px 16px;
```

## Border Radius Consistency

Sharper corners feel technical, rounder corners feel friendly. Pick a scale:
- Small: inputs and buttons
- Medium: cards
- Large: modals or containers

## Depth & Elevation Strategy

Choose ONE and commit:

**Borders-only (flat)** — Clean, technical, dense.

```css
--border: rgba(0, 0, 0, 0.08);
border: 0.5px solid var(--border);
```

**Subtle single shadows** — Soft lift.

```css
--shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
```

**Layered shadows** — Rich, premium.

```css
--shadow-layered:
  0 0 0 0.5px rgba(0, 0, 0, 0.05),
  0 1px 2px rgba(0, 0, 0, 0.04),
  0 2px 4px rgba(0, 0, 0, 0.03),
  0 4px 8px rgba(0, 0, 0, 0.02);
```

## Typography Hierarchy

Combine size, weight, and letter-spacing:

- **Headlines** — heavier weight, tighter letter-spacing
- **Body** — comfortable weight for readability
- **Labels/UI** — medium weight, works at smaller sizes
- **Data** — monospace, `tabular-nums` for alignment

## Iconography

Icons clarify, not decorate. One icon set throughout. Standalone icons get subtle background containers.

## Animation

Fast micro-interactions (~150ms), smooth deceleration easing. No spring/bounce in professional interfaces.

## Navigation Context

Screens need grounding. Include navigation, location indicators, user context. Sidebar: same background as content, border separation.

## Dark Mode

Borders over shadows. Slightly desaturate semantic colors. Same hierarchy, inverted values.
