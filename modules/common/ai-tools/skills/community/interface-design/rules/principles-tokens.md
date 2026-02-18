---
title: Token Architecture
impact: MEDIUM
impactDescription: Every color must trace to primitives
tags: principles, tokens, css-variables, hierarchy
---

## Token Architecture

**Impact: MEDIUM (Every color must trace to primitives)**

Every color traces back to primitives: foreground (text hierarchy — primary, secondary, tertiary, muted), background (surface elevation), border (default, subtle, strong, stronger), brand, and semantic (destructive, warning, success). No random hex values. Text hierarchy needs four levels used consistently. Border progression matches intensity to importance. Form controls get dedicated tokens (control background, control border, focus state) separate from layout surfaces.

**Incorrect (flat text hierarchy and random values):**

```css
/* Only two text levels — hierarchy too flat */
--text: #1e293b;
--text-gray: #94a3b8;
/* Random hex values not connected to system */
.card { background: #f1f5f9; }
.input { background: #fff; border: 1px solid #cbd5e1; }
.badge { color: #2563eb; } /* Where did this come from? */
```

**Correct (systematic token architecture):**

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
