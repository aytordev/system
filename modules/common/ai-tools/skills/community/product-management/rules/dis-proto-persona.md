---
title: Proto Persona
impact: CRITICAL
impactDescription: Building without any persona model guarantees designing for no one
tags: discovery, persona, hypothesis, proto-persona, user-research
---

## Proto Persona

**Impact: CRITICAL (Building without any persona model guarantees designing for no one)**

A Proto Persona is a hypothesis-driven persona created before conducting full research — capturing name, demographics, behaviors, goals, and frustrations based on team assumptions — so those assumptions can be made explicit and tested. Use it at project kickoff to align the team on who they believe they are building for, then update it with real data as discovery progresses. Do not treat it as a validated persona or use it as a substitute for primary research; the explicit purpose is to surface assumption gaps, not to replace user interviews. Label it clearly as a hypothesis artifact everywhere it appears.

**Incorrect (undocumented assumptions, no hypothesis framing):**

```markdown
## Target User

Our target user is a busy professional in their 30s who needs to save time.
They are tech-savvy and frustrated with their current tools.
They want something simple and fast.

We will build for them.
```

**Correct (explicit hypothesis artifact with testable dimensions):**

```markdown
## Proto Persona [HYPOTHESIS — not yet validated]

**Name:** Marcus, 34 | Operations Manager, 50-person SaaS company

**Demographics:** 8 years in ops roles. Non-technical but data-literate.
Manages a team of 6. Reports to COO.

**Behaviors (assumed):**
- Lives in spreadsheets and Slack; no dedicated ops tooling
- Spends ~4 hrs/week manually compiling status reports for leadership
- Evaluates new tools alone before proposing to team

**Goals:**
- Surface operational bottlenecks before the COO asks about them
- Reduce time on reporting without losing visibility or accuracy

**Frustrations:**
- Current tools require engineering support to configure
- Data is scattered across 5+ systems with no single source of truth

**Key Assumptions to Test:**
1. Marcus is the buyer AND the primary user (not separate roles)
2. Reporting time (4 hrs/week) is the pain — not the underlying data access
3. He evaluates tools solo before involving others

**Research Questions for Validation:**
- How does he currently compile reports? What's the actual workflow?
- Who else is involved in the tool evaluation/buying decision?
- What has he tried before and why did it fail?
```

Reference: [Full framework](../references/proto-persona-full.md)
