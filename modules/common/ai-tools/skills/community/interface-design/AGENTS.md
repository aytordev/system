# Interface Design Guidelines

**Version 1.0.0**  
community  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when designing  
> interface elements. Humans may also find it useful, but guidance here  
> is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Interface design skill for dashboards, admin panels, SaaS apps, tools, and interactive products. Enforces craft through intent-driven design, domain exploration, and design system memory that persists across sessions.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy) — **CRITICAL**
   - 1.1 [Every Choice Must Be A Choice](#11-every-choice-must-be-a-choice)
   - 1.2 [Intent First](#12-intent-first)
   - 1.3 [Sameness Is Failure](#13-sameness-is-failure)
   - 1.4 [Where Defaults Hide](#14-where-defaults-hide)
2. [Domain Exploration](#2-domain-exploration) — **HIGH**
   - 2.1 [Product Domain Exploration](#21-product-domain-exploration)
   - 2.2 [The Mandate](#22-the-mandate)
3. [Craft Foundations](#3-craft-foundations) — **HIGH**
   - 3.1 [Color Lives Somewhere](#31-color-lives-somewhere)
   - 3.2 [Infinite Expression](#32-infinite-expression)
   - 3.3 [Subtle Layering](#33-subtle-layering)
4. [Design Principles](#4-design-principles) — **MEDIUM**
   - 4.1 [Common Mistakes to Avoid](#41-common-mistakes-to-avoid)
   - 4.2 [Components and Controls](#42-components-and-controls)
   - 4.3 [Depth and Elevation Strategy](#43-depth-and-elevation-strategy)
   - 4.4 [Spacing System](#44-spacing-system)
   - 4.5 [States and Animation](#45-states-and-animation)
   - 4.6 [Token Architecture](#46-token-architecture)
   - 4.7 [Typography Hierarchy](#47-typography-hierarchy)
5. [Workflow](#5-workflow) — **MEDIUM**
   - 5.1 [Communication and Memory](#51-communication-and-memory)
   - 5.2 [Component Checkpoint](#52-component-checkpoint)

---

## 1. Design Philosophy

**Impact: CRITICAL**

Core intent-driven design philosophy. Every choice must be deliberate — defaults are invisible failures that compound into generic output.

### 1.1 Every Choice Must Be A Choice

**Impact: CRITICAL (Unexplainable choices are defaults in disguise)**

For every decision, you must be able to explain WHY — why this layout, this color temperature, this typeface, this spacing scale, this information hierarchy. If your answer is "it's common" or "it's clean" or "it works," you haven't chosen. You've defaulted. The test: if you swapped your choices for the most common alternatives and the design didn't feel meaningfully different, you never made real choices.

**Incorrect: defaulting without reasoning**

```css
/* "Standard" dashboard layout */
.sidebar { width: 256px; }
.card { border-radius: 8px; padding: 16px; }
font-family: Inter, sans-serif;
color: #1f2937; /* gray-800 */
```

**Correct: every choice has a why**

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

### 1.2 Intent First

**Impact: CRITICAL (Design from specifics not assumptions)**

Before touching code, answer three questions — not in your head, out loud. **Who is this human?** Not "users" — the actual person, their context, their moment. **What must they accomplish?** Not "use the dashboard" — the verb. **What should this feel like?** Not "clean and modern" — words that mean something. If you cannot answer these with specifics, stop and ask the user. Do not guess. Do not default.

**Incorrect: vague intent**

```markdown
Intent: Users need a clean, modern dashboard
Feel: Professional and intuitive
```

**Correct: specific intent**

```markdown
Intent: A bakery owner at 6am, checking overnight online orders before
the morning rush. They need to see what to bake first.
Feel: Warm like a notebook — not a spreadsheet. Calm, not urgent.
```

### 1.3 Sameness Is Failure

**Impact: HIGH (Generic output signals no design intent)**

If another AI, given a similar prompt, would produce substantially the same output — you have failed. This is not about being different for its own sake. It's about the interface emerging from the specific problem, user, and context. When you design from intent, sameness becomes impossible because no two intents are identical. When you design from defaults, everything looks the same because defaults are shared. Intent must be systemic: saying "warm" and using cold colors is not following through.

**Incorrect: intent as label only**

```css
/* Intent stated: "warm and friendly" */
/* But implementation uses cold defaults */
--background: #f8fafc; /* slate-50 — cold */
--text: #334155; /* slate-700 — cold */
--border: #e2e8f0; /* slate-200 — cold */
--accent: #3b82f6; /* blue — cold */
border-radius: 8px; /* generic */
```

**Correct: intent carried through every token**

```css
/* Intent: warm and friendly — every token reinforces it */
--background: #faf8f5; /* warm paper tone */
--text: #44403c; /* stone-700 — warm */
--border: #e7e5e4; /* stone-200 — warm */
--accent: #ea580c; /* orange — warm */
border-radius: 12px; /* soft, approachable */
```

### 1.4 Where Defaults Hide

**Impact: CRITICAL (Defaults disguise themselves as infrastructure)**

Defaults don't announce themselves. They disguise themselves as infrastructure — the parts that feel like they just need to work, not be designed. Typography, navigation, data display, and token names are all design decisions, not structural ones. The moment you stop asking "why this?" is the moment defaults take over.

**Incorrect: treating infrastructure as non-design**

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

**Correct: every decision is design**

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

---

## 2. Domain Exploration

**Impact: HIGH**

Process for exploring a product's world before making visual decisions. Produces domain concepts, color worlds, signatures, and named defaults.

### 2.1 Product Domain Exploration

**Impact: HIGH (Catch defaults before they become design)**

Before proposing any direction, produce all four required outputs. **Domain:** Concepts, metaphors, vocabulary from this product's world — not features, territory. Minimum 5. **Color world:** What colors exist naturally in this domain? If this product were a physical space, what would you see? List 5+. **Signature:** One element that could only exist for THIS product. **Defaults:** 3 obvious choices you're rejecting — visual AND structural. Your proposal must reference all four. The test: remove the product name from your proposal — could someone identify what it's for?

**Incorrect: skipping exploration**

```markdown
Direction: Clean dashboard with blue accent, sidebar navigation,
card-based layout with metrics.
```

**Correct: full domain exploration**

```markdown
Domain: fermentation, batch timing, pH curves, starter cultures,
sourdough scoring, proofing cycles
Color world: flour-dusted surfaces (#faf8f5), dark rye (#3d2c1e),
golden crust (#c2956a), ceramic white (#f5f0eb), copper (#b87333)
Signature: batch timeline as a fermentation curve, not a progress bar
Rejecting: blue accent (→ copper), card grid (→ timeline-first),
generic metrics (→ dough readiness indicators)

Direction: A baker's notebook. Warm parchment surfaces, copper accents
that reference equipment, timeline-first layout following dough from
mixing through proofing to baking.
```

### 2.2 The Mandate

**Impact: HIGH (Catch generic output before the user has to)**

Before showing the user, look at what you made. Ask: "If they said this lacks craft, what would they mean?" Fix it first. Run four checks. **The swap test:** swap the typeface for your usual one — would anyone notice? **The squint test:** blur your eyes — can you still perceive hierarchy without harshness? **The signature test:** point to five specific elements where your signature appears — not "the overall feel." **The token test:** read your CSS variables out loud — do they sound like they belong to this product's world? If any check fails, iterate before showing.

**Incorrect: shipping first draft**

```css
/* Default tokens that could be any project */
--color-primary: #3b82f6;
--color-secondary: #64748b;
--surface: #ffffff;
--text: #1e293b;
/* Generic layout */
.dashboard { display: grid; grid-template-columns: 256px 1fr; }
```

**Correct: passed all four checks**

```css
/* Tokens that belong to a bakery management tool */
--crust: #c2956a;
--flour: #faf8f5;
--rye: #3d2c1e;
--copper: #b87333;
--parchment: #f5f0eb;
/* Layout driven by the domain: timeline-first, not grid-first */
.kitchen { display: grid; grid-template-columns: 280px 1fr; }
.batch-timeline { /* signature element: fermentation curve */ }
```

---

## 3. Craft Foundations

**Impact: HIGH**

Universal craft principles that apply regardless of direction: subtle layering, infinite expression, and domain-rooted color.

### 3.1 Color Lives Somewhere

**Impact: HIGH (Palettes should come from the product world)**

Every product exists in a world. That world has colors. Before reaching for a palette, spend time in the product's world — what would you see in the physical version of this space? Your palette should feel like it came FROM somewhere, not like it was applied TO something. Go beyond warm/cold: is this quiet or loud? Dense or spacious? Serious or playful? Gray builds structure. Color communicates — status, action, emphasis, identity. Unmotivated color is noise. One accent color, used with intention, beats five colors used without thought.

**Incorrect: applied palette with no connection to domain**

```css
/* Generic palette for a woodworking tool management app */
--primary: #3b82f6; /* blue — why blue? */
--secondary: #8b5cf6; /* purple — decoration */
--accent: #06b6d4; /* cyan — more decoration */
--success: #22c55e;
--warning: #f59e0b;
/* Multiple accent colors dilute focus */
```

**Correct: palette rooted in the product's world**

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

### 3.2 Infinite Expression

**Impact: HIGH (Same pattern has infinite valid implementations)**

Every pattern has infinite expressions. A metric display could be a hero number, inline stat, sparkline, gauge, progress bar, comparison delta, or trend badge. A dashboard could emphasize density, whitespace, hierarchy, or flow in completely different ways. Before building, ask: what's the ONE thing users do most here? What products solve similar problems brilliantly? Why would this feel designed for its purpose, not templated? Never produce identical output. Same sidebar width, same card grid, same metric boxes with icon-left-number-big-label-small every time signals AI-generated immediately.

**Incorrect: template metric card**

```html
<!-- Every metric looks the same: icon + big number + label -->
<div class="card">
  <div class="icon">📊</div>
  <div class="value">1,234</div>
  <div class="label">Total Orders</div>
</div>
<!-- Repeated 4x with different icons -->
```

**Correct: metric expression matches the data's story**

```html
<!-- Revenue: hero number with trend — this is THE number they came to see -->
<div class="revenue-hero">
  <span class="amount">$12,450</span>
  <span class="trend up">+12.3%</span>
</div>
<!-- Fulfillment: progress ring — shows completion, not just a count -->
<div class="fulfillment-ring">
  <svg><!-- 73% ring --></svg>
  <span>38 of 52</span>
</div>
<!-- Wait time: sparkline — the trend matters more than the number -->
<div class="wait-sparkline">
  <canvas><!-- 24h trend --></canvas>
  <span class="current">4.2 min</span>
</div>
```

### 3.3 Subtle Layering

**Impact: HIGH (Backbone of professional interfaces)**

Surfaces stack: dropdown above card above page. Build a numbered elevation system — each jump only a few percentage points of lightness. In dark mode, higher = slightly lighter. You should barely notice the system working. Borders use low opacity rgba that blends with the background — defining edges without demanding attention. Sidebars: same background as canvas, subtle border separation (not different color). Dropdowns: one level above parent surface. Inputs: slightly darker (inset — they receive content). The squint test: blur your eyes, perceive hierarchy without harshness.

**Incorrect: dramatic surface jumps and harsh borders**

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

**Correct: whisper-quiet surface shifts**

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

---

## 4. Design Principles

**Impact: MEDIUM**

Technical design system rules for tokens, spacing, typography, depth, controls, states, and common mistakes to avoid.

### 4.1 Common Mistakes to Avoid

**Impact: MEDIUM (Quick reference for frequent anti-patterns)**

Avoid these common design mistakes: harsh borders that dominate over content, dramatic surface jumps between elevation levels, inconsistent spacing (the clearest sign of no system), mixed depth strategies, missing interaction states, dramatic drop shadows, large radius on small elements, pure white cards on colored backgrounds, thick decorative borders, gradients and color used for decoration rather than meaning, multiple accent colors that dilute focus, and different hues for different surfaces when only lightness should shift.

**Incorrect: multiple anti-patterns**

```css
/* Harsh borders + dramatic shadows + decoration */
.card {
  border: 2px solid #94a3b8; /* too thick, too visible */
  box-shadow: 0 8px 24px rgba(0,0,0,0.25); /* dramatic */
  background: linear-gradient(135deg, #667eea, #764ba2); /* decorative gradient */
  border-radius: 24px; /* too large for a card */
}
/* Multiple accent colors */
--accent-1: #3b82f6;
--accent-2: #8b5cf6;
--accent-3: #06b6d4;
/* Pure white card on colored background */
.page { background: #f1f5f9; }
.card { background: #ffffff; } /* stark contrast */
```

**Correct: subtle, systematic approach**

```css
.card {
  border: 0.5px solid rgba(0, 0, 0, 0.08); /* barely there */
  /* No shadow — committed to borders-only */
  background: var(--surface-100); /* slight shift, not pure white */
  border-radius: 6px; /* proportional to element size */
}
/* One accent color, used with intention */
--accent: #b87333;
/* Surface that relates to background */
.page { background: var(--surface-base); }
.card { background: var(--surface-100); } /* 2-3% lighter, not stark */
```

### 4.2 Components and Controls

**Impact: MEDIUM (Cards, controls, icons, and navigation need design attention)**

Card layouts: a metric card doesn't have to look like a plan card. Design each card's internal structure for its content, but keep surface treatment consistent (same border, shadow, radius, padding). Controls: never use native `<select>` or `<input type="date">` — they render OS-native elements that cannot be styled. Build custom components. Icons clarify, not decorate — if removing an icon loses no meaning, remove it. Choose one icon set. Navigation provides context: screens need grounding, not floating in space. Sidebar: same background as content, border separation.

**Incorrect: native controls and decorative icons**

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

**Correct: custom controls and meaningful icons**

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

### 4.3 Depth and Elevation Strategy

**Impact: MEDIUM (Choose one approach and commit)**

Choose ONE depth approach and commit. **Borders-only:** clean, technical, dense — for utility tools (Linear, Raycast). **Subtle shadows:** soft lift — for approachable products. **Layered shadows:** premium, dimensional — for cards needing presence (Stripe). **Surface color shifts:** background tints establish hierarchy without shadows. Don't mix approaches. Border radius: sharper feels technical, rounder feels friendly. Build a scale (small for inputs, medium for cards, large for modals) and use it consistently.

**Incorrect: mixed depth approaches**

```css
/* Some cards have shadows, some have borders, some have both */
.card-1 { border: 1px solid #e2e8f0; }
.card-2 { box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
.card-3 { border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
/* Inconsistent radius */
.button { border-radius: 4px; }
.card { border-radius: 12px; }
.input { border-radius: 8px; }
.modal { border-radius: 4px; }
```

**Correct: borders-only strategy, consistent radius**

```css
/* Committed: borders-only for this dense developer tool */
--border: rgba(0, 0, 0, 0.08);
--border-subtle: rgba(0, 0, 0, 0.05);
.card { border: 0.5px solid var(--border); }
.dropdown { border: 0.5px solid var(--border); }
.modal { border: 0.5px solid var(--border); }
/* Consistent radius scale: sharp (technical) */
--radius-sm: 4px;  /* inputs, buttons */
--radius-md: 6px;  /* cards */
--radius-lg: 8px;  /* modals */
```

### 4.4 Spacing System

**Impact: MEDIUM (Random values signal no system)**

Pick a base unit (4px or 8px) and stick to multiples. Build a scale for different contexts: micro spacing (icon gaps), component spacing (within buttons/cards), section spacing (between groups), major separation (between sections). Every value must be explainable as a multiple of the base unit. Keep padding symmetrical — if top is 16px, sides should match unless content naturally requires asymmetry.

**Incorrect: random spacing values**

```css
/* No system — random values everywhere */
.card { padding: 18px 14px 12px 14px; }
.button { padding: 7px 13px; margin-bottom: 15px; }
.section { gap: 22px; }
.icon-gap { margin-right: 5px; }
```

**Correct: systematic spacing on 4px grid**

```css
/* Base: 4px, all values are multiples */
--space-1: 4px;   /* micro: icon gaps */
--space-2: 8px;   /* component: tight pairs */
--space-3: 12px;  /* component: button padding */
--space-4: 16px;  /* section: card padding */
--space-6: 24px;  /* section: group gaps */
--space-8: 32px;  /* major: section separation */

.card { padding: var(--space-4); } /* 16px all sides */
.button { padding: var(--space-2) var(--space-3); } /* 8px 12px */
.section { gap: var(--space-6); } /* 24px */
.icon-gap { margin-right: var(--space-1); } /* 4px */
```

### 4.5 States and Animation

**Impact: MEDIUM (Missing states make interfaces feel broken)**

Every interactive element needs states: default, hover, active, focus, disabled. Data needs states too: loading, empty, error. Missing states feel broken. Animation: fast micro-interactions (~150ms), smooth easing. Larger transitions (modals, panels) can be slightly longer (~200-250ms). Use deceleration easing. Avoid spring/bounce in professional interfaces. Dark mode: shadows are less visible — lean on borders. Semantic colors often need slight desaturation. The hierarchy system still applies, just with inverted values.

**Incorrect: missing states**

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

**Correct: complete state coverage**

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

### 4.6 Token Architecture

**Impact: MEDIUM (Every color must trace to primitives)**

Every color traces back to primitives: foreground (text hierarchy — primary, secondary, tertiary, muted), background (surface elevation), border (default, subtle, strong, stronger), brand, and semantic (destructive, warning, success). No random hex values. Text hierarchy needs four levels used consistently. Border progression matches intensity to importance. Form controls get dedicated tokens (control background, control border, focus state) separate from layout surfaces.

**Incorrect: flat text hierarchy and random values**

```css
/* Only two text levels — hierarchy too flat */
--text: #1e293b;
--text-gray: #94a3b8;
/* Random hex values not connected to system */
.card { background: #f1f5f9; }
.input { background: #fff; border: 1px solid #cbd5e1; }
.badge { color: #2563eb; } /* Where did this come from? */
```

**Correct: systematic token architecture**

```css
/* Four-level text hierarchy */
--text-primary: #0f172a;
--text-secondary: #475569;
--text-tertiary: #94a3b8;
--text-muted: #cbd5e1;
/* Border progression */
--border-default: rgba(0, 0, 0, 0.08);
--border-subtle: rgba(0, 0, 0, 0.05);
--border-strong: rgba(0, 0, 0, 0.12);
--border-focus: rgba(59, 130, 246, 0.5);
/* Dedicated control tokens */
--control-bg: #f8fafc;
--control-border: rgba(0, 0, 0, 0.10);
--control-focus-ring: 0 0 0 2px var(--border-focus);
```

### 4.7 Typography Hierarchy

**Impact: MEDIUM (Size alone is not hierarchy)**

Build distinct levels distinguishable at a glance. Headlines need weight and tight tracking for presence. Body needs comfortable weight for readability. Labels need medium weight that works at smaller sizes. Data needs monospace with `tabular-nums` for alignment. Don't rely on size alone — combine size, weight, and letter-spacing. If you squint and can't tell headline from body, the hierarchy is too weak. Numbers, IDs, codes, timestamps belong in monospace.

**Incorrect: size-only hierarchy**

```css
/* Only size differentiates levels */
.headline { font-size: 24px; font-weight: 400; }
.body { font-size: 16px; font-weight: 400; }
.label { font-size: 14px; font-weight: 400; }
.data { font-size: 14px; font-weight: 400; font-family: inherit; }
```

**Correct: multi-dimensional hierarchy**

```css
.headline {
  font-size: 24px;
  font-weight: 600;
  letter-spacing: -0.025em; /* tight for presence */
}
.body {
  font-size: 15px;
  font-weight: 400;
  line-height: 1.6;
}
.label {
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.01em;
}
.data {
  font-family: 'Geist Mono', monospace;
  font-size: 13px;
  font-variant-numeric: tabular-nums; /* aligned columns */
}
```

---

## 5. Workflow

**Impact: MEDIUM**

Communication patterns, component checkpoints, and design system memory management across sessions.

### 5.1 Communication and Memory

**Impact: MEDIUM (Be invisible and persistent)**

Be invisible — don't announce modes or narrate process. Never say "I'm in ESTABLISH MODE" or "Let me check system.md." Jump into work, state suggestions with reasoning. Lead with exploration and recommendation, then confirm direction. If a project has `.interface-design/system.md`, read and apply it — decisions are made. If not, explore domain, propose direction, confirm, build, evaluate, offer to save. Add patterns to system.md when a component is used 2+ times or has specific measurements worth remembering. Don't save one-off components or temporary experiments.

**Incorrect: narrating process**

```markdown
Let me check if there's a design system file...
I'm now entering ESTABLISH MODE to set up the design direction.
According to my analysis of the system.md file, I can see that...
```

**Correct: invisible, direct**

```markdown
Domain: fermentation, batch timing, proofing cycles, starter cultures, scoring
Color world: flour-dust (#faf8f5), dark rye (#3d2c1e), golden crust (#c2956a)
Signature: batch timeline as fermentation curve

Direction: Baker's notebook — warm parchment, copper accents, timeline-first.
Does that direction feel right?
```

### 5.2 Component Checkpoint

**Impact: MEDIUM (Forces every technical choice back to intent)**

Every time you write UI code — even small additions — state the intent AND technical approach. This checkpoint is mandatory. It forces you to connect every technical choice back to intent. If you can't explain WHY for each choice, you're defaulting. Stop and think. After every task, offer to save patterns to `.interface-design/system.md` for cross-session consistency.

**Incorrect: jumping straight to code**

```markdown
<!-- No checkpoint, just building -->
Here's a sidebar component with navigation items...
```

**Correct: mandatory checkpoint before code**

```markdown
Intent: bakery owner at 6am, needs to see overnight orders before rush
Palette: flour (#faf8f5), rye (#3d2c1e), copper (#b87333) — workshop colors
Depth: borders-only — dense tool, shadows add weight without info value
Surfaces: warm parchment base, 3% shifts per level — matches notebook feel
Typography: Instrument Sans — handmade warmth, not sterile precision
Spacing: 4px base — tight enough for order lists, comfortable for scanning
```

---

