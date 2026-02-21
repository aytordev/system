---
title: PRD Development
impact: HIGH
impactDescription: Incomplete PRDs cause scope creep, misaligned engineering effort, and rework
tags: prd, requirements, product spec, documentation, alignment
---

## PRD Development

**Impact: HIGH (Incomplete PRDs cause scope creep, misaligned engineering effort, and rework)**

A PRD is developed over 2-4 days and must include: executive summary, problem statement, target users, strategic context, solution overview, success metrics, and user stories. Use a PRD when a feature is large enough to require cross-functional alignment before design or engineering begins. Do not use a PRD for small bug fixes or trivial enhancements — a well-written user story suffices. The problem statement must come before the solution section; reversing this order signals a solution looking for a justification.

**Incorrect (solution-first, no target user or success metric):**

```markdown
# PRD: Dashboard Redesign

## Overview
We will redesign the dashboard with a new sidebar navigation,
updated color scheme, and drag-and-drop widget support.

## Features
- Sidebar nav
- Dark mode
- Drag-and-drop widgets
```

**Correct (problem-first, structured with target user and measurable success):**

```markdown
# PRD: Dashboard Redesign

## Executive Summary
Power users spend 40% of their session time navigating between
reports. This PRD proposes a redesigned dashboard to reduce
navigation time and increase daily active usage.

## Problem Statement
Users with 5+ saved reports cannot find or switch between them
efficiently. Support tickets cite "can't find my reports" as
the #2 complaint (180/month).

## Target Users
Operations analysts at mid-market companies (50–500 employees)
who run 3+ reports per day.

## Success Metrics
- Reduce avg. navigation clicks per session from 8.2 → 4.0
- Increase DAU/MAU ratio from 0.31 → 0.45 within 60 days post-launch

## Solution Overview
Persistent sidebar with pinned reports, keyboard shortcuts,
and recently-viewed history.
```

Reference: [Full framework](../references/prd-development-full.md)
