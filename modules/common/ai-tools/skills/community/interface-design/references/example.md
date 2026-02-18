# Craft in Action

This shows how the subtle layering principle translates to real decisions. Learn the thinking, not the code. Your values will differ — the approach won't.

---

## The Subtle Layering Mindset

Before looking at any example, internalize this: **you should barely notice the system working.**

When you look at Vercel's dashboard, you don't think "nice borders." You just understand the structure. The craft is invisible — that's how you know it's working.

---

## Example: Dashboard with Sidebar and Dropdown

### The Surface Decisions

Each elevation jump should be only a few percentage points of lightness. You can barely see the difference in isolation. But when surfaces stack, the hierarchy emerges. Whisper-quiet shifts that you feel rather than see.

**What NOT to do:** Don't make dramatic jumps between elevations. Don't use different hues for different levels. Keep the same hue, shift only lightness.

### The Border Decisions

Low opacity borders blend with their background. A low-opacity white border on a dark surface is barely there — it defines the edge without demanding attention. Solid hex borders look harsh in comparison.

**The test:** Look at your interface from arm's length. If borders are the first thing you notice, reduce opacity. If you can't find where regions end, increase slightly.

### The Sidebar Decision

Many dashboards make the sidebar a different color. This fragments the visual space. Better: Same background, subtle border separation. The sidebar is part of the app, not a separate region.

### The Dropdown Decision

The dropdown floats above the card it emerged from. If both share the same surface level, the dropdown blends into the card. One level above is just light enough to feel "above" without being dramatically different.

---

## Example: Form Controls

### Input Background Decision

Inputs are "inset" — they receive content. A slightly darker background signals "type here" without needing heavy borders.

### Focus State Decision

Focus needs to be visible, but not dramatic. A noticeable increase in border opacity is enough for a clear state change. Subtle-but-noticeable.

---

## Adapt to Context

Your product might need:
- Warmer hues (slight yellow/orange tint)
- Cooler hues (blue-gray base)
- Different lightness progression
- Light mode (principles invert — higher elevation = shadow, not lightness)

**The principle is constant:** barely different, still distinguishable.

---

## The Craft Check

1. Blur your eyes or step back
2. Can you still perceive hierarchy?
3. Is anything jumping out at you?
4. Can you tell where regions begin and end?

If hierarchy is visible and nothing is harsh — the subtle layering is working.
