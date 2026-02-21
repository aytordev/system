---
title: Lean UX Canvas
impact: HIGH
impactDescription: Building without a shared hypothesis locks teams into delivering output instead of learning
tags: validation, lean-ux, hypothesis, canvas, experimentation, jeff-gothelf
---

## Lean UX Canvas

**Impact: HIGH (Building without a shared hypothesis locks teams into delivering output instead of learning)**

The Lean UX Canvas v2 (Jeff Gothelf) structures a sprint or initiative around eight fields in two passes: first define the Business Problem, Users, User Outcomes, and Business Outcomes; then generate Solutions, Hypotheses, Minimum Viable Experiments, and Learning Metrics. Complete the left half before the right — generating solutions before naming the desired outcome produces solutions that solve the wrong thing. Use this at the start of any feature initiative or sprint cycle. Do not use it as a backlog grooming tool; it is a shared alignment artifact, not a task list.

**Incorrect (solutions-first, outcomes missing):**

```markdown
## Q3 Initiative: Notifications

Solutions:
- Add email digest
- Add in-app badge counter
- Add push notifications

Next step: Hand off to engineering.
```

**Correct (eight-field canvas, outcomes drive solutions):**

```markdown
## Lean UX Canvas: Notification Overload

**1. Business Problem:** Users are missing critical updates, causing escalations and churn.
**2. Users:** Power users managing 5+ projects simultaneously.
**3. User Outcomes:** Feel in control; act on the right information at the right time.
**4. Business Outcomes:** Reduce missed-update support tickets by 40%; improve 30-day retention by 5%.

**5. Solutions:** Smart digest (daily summary), priority filters, snooze controls.
**6. Hypotheses:**
  - We believe that a priority-filtered digest for power users
    will reduce missed-update tickets as measured by support volume.
**7. MVP Experiment:** Release digest to 10% of power users for 2 weeks; measure ticket rate vs. control.
**8. Learning Metric:** Support tickets per active user; target ≥ 30% reduction in cohort.
```

Reference: [Full framework](../references/lean-ux-canvas-full.md)
