---
title: Component Checkpoint
impact: MEDIUM
impactDescription: Forces every technical choice back to intent
tags: workflow, checkpoint, intent, mandatory
---

## Component Checkpoint

**Impact: MEDIUM (Forces every technical choice back to intent)**

Every time you write UI code — even small additions — state the intent AND technical approach. This checkpoint is mandatory. It forces you to connect every technical choice back to intent. If you can't explain WHY for each choice, you're defaulting. Stop and think. After every task, offer to save patterns to `.interface-design/system.md` for cross-session consistency.

**Incorrect (jumping straight to code):**

```markdown
<!-- No checkpoint, just building -->
Here's a sidebar component with navigation items...
```

**Correct (mandatory checkpoint before code):**

```markdown
Intent: bakery owner at 6am, needs to see overnight orders before rush
Palette: flour (#faf8f5), rye (#3d2c1e), copper (#b87333) — workshop colors
Depth: borders-only — dense tool, shadows add weight without info value
Surfaces: warm parchment base, 3% shifts per level — matches notebook feel
Typography: Instrument Sans — handmade warmth, not sterile precision
Spacing: 4px base — tight enough for order lists, comfortable for scanning
```
