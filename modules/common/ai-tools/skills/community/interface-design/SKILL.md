---
name: interface-design
description: "Interface design for dashboards, admin panels, SaaS apps, tools, and interactive products. NOT for marketing design (landing pages, campaigns) — use frontend-design for those."
license: MIT
metadata:
  author: dammyjay93
  version: "1.0.0"
---

# Interface Design

Build interface design with craft and consistency. Maintains design decisions across sessions via `.interface-design/system.md`.

**Use for:** Dashboards, admin panels, SaaS apps, tools, settings pages, data interfaces.

**Not for:** Landing pages, marketing sites, campaigns. Redirect those to `/frontend-design`.

## Rule Categories by Priority

| Priority | Category           | Impact   | Prefix        |
| -------- | ------------------ | -------- | ------------- |
| 1        | Design Philosophy  | CRITICAL | `philosophy`  |
| 2        | Domain Exploration | HIGH     | `exploration` |
| 3        | Craft Foundations  | HIGH     | `craft`       |
| 4        | Design Principles  | MEDIUM   | `principles`  |
| 5        | Workflow           | MEDIUM   | `workflow`    |

## Quick Reference

### 1. Design Philosophy (CRITICAL)

- `philosophy-defaults-hide` - Where Defaults Hide
- `philosophy-intent` - Intent First
- `philosophy-choice` - Every Choice Must Be A Choice
- `philosophy-sameness` - Sameness Is Failure

### 2. Domain Exploration (HIGH)

- `exploration-process` - Product Domain Exploration
- `exploration-mandate` - The Mandate

### 3. Craft Foundations (HIGH)

- `craft-layering` - Subtle Layering
- `craft-expression` - Infinite Expression
- `craft-color` - Color Lives Somewhere

### 4. Design Principles (MEDIUM)

- `principles-tokens` - Token Architecture
- `principles-spacing` - Spacing System
- `principles-depth` - Depth and Elevation Strategy
- `principles-typography` - Typography Hierarchy
- `principles-components` - Components and Controls
- `principles-states` - States and Animation
- `principles-avoid` - Common Mistakes to Avoid

### 5. Workflow (MEDIUM)

- `workflow-checkpoint` - Component Checkpoint
- `workflow-communication` - Communication and Memory

## Deep Dives

For detailed code examples and protocols:

- `references/principles.md` — Code examples, specific values, dark mode
- `references/critique.md` — Post-build craft critique protocol
- `references/example.md` — Craft in action with annotated decisions
- `references/validation.md` — Memory management, when to update system.md

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
