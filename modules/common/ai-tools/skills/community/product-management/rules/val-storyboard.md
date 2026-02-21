---
title: 6-Frame User Journey Storyboard
impact: HIGH
impactDescription: Text-only specs miss the emotional arc of the user experience, leading to technically correct but experientially hollow features
tags: validation, storyboard, user-journey, narrative, ux, storytelling
---

## 6-Frame User Journey Storyboard

**Impact: HIGH (Text-only specs miss the emotional arc of the user experience, leading to technically correct but experientially hollow features)**

A 6-frame storyboard narrates the user journey through a product experience in six sequential frames: Setup (who the user is and their world), Trigger (the moment the problem becomes urgent), Action (how the user finds or engages with the solution), Resolution (the moment the solution works), Outcome (the measurable or felt change in the user's life), and Insight (what the team learned or what must be true for the story to hold). Use storyboards to align cross-functional teams on the human experience before design begins, and to evaluate whether a proposed solution actually addresses the trigger that matters. Do not use storyboards as a substitute for user research — the story should be grounded in real interview data, not invented personas.

**Incorrect (product-centric, no emotional arc, no trigger moment):**

```markdown
Story: User opens app → sees dashboard → clicks "Create project" → project is created.
```

**Correct (6-frame narrative, grounded in user context and emotion):**

```markdown
## Storyboard: "The Monday Morning Panic" — Project Onboarding

**Frame 1 — Setup:**
Priya is a team lead at a 40-person SaaS company. She manages 3 active projects
across 6 people. She uses spreadsheets, Slack, and two other tools. Her team
misses context constantly.

**Frame 2 — Trigger:**
Monday 9:05am. A stakeholder pings: "What's the status on the migration?"
Priya has no single source of truth. She spends 20 minutes reconstructing the
answer from 4 different threads. She is embarrassed and frustrated.

**Frame 3 — Action:**
A colleague shares a link: "We moved everything into [Product]. Here's the
workspace." Priya clicks, sees her projects already partially populated
(the PM had imported them from Jira). She spends 8 minutes reviewing.

**Frame 4 — Resolution:**
At 9:35am, the stakeholder pings again. Priya pastes a direct link to the
live status board. No reconstruction needed. The stakeholder says "perfect."

**Frame 5 — Outcome:**
Priya blocks 30 minutes Friday afternoon to keep the board updated.
She tells two other team leads to try it. Monday meetings are now 15 minutes shorter.

**Frame 6 — Insight:**
The trigger is not "lack of a project tool" — it is "stakeholder pressure without
a defensible answer." The product must make Priya look competent to her stakeholders,
not just organized to herself. This reframes the onboarding copy and the share flow.

What must be true: Import from existing tools (Jira, spreadsheets) must work in
< 10 minutes or Priya will not reach Frame 3.
```

Reference: [Full framework](../references/storyboard-full.md)
