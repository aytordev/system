---
title: Proof of Learning (PoL) Probe
impact: HIGH
impactDescription: Building a full feature to test an assumption wastes weeks when a probe takes days
tags: validation, proof-of-learning, probe, concierge, wizard-of-oz, fake-door, experimentation
---

## Proof of Learning (PoL) Probe

**Impact: HIGH (Building a full feature to test an assumption wastes weeks when a probe takes days)**

A Proof of Learning probe is a lightweight experiment that tests one critical assumption before committing engineering capacity. Structure each probe with five fields: Hypothesis (the falsifiable belief being tested), Probe Type (concierge, Wizard of Oz, landing page, fake door, or data analysis), Success Criteria (the numeric threshold that confirms or invalidates the hypothesis), Timeline (days, not weeks), and Learning (what the team will do differently based on the result). Use PoL probes when you have a high-risk assumption and low confidence. Do not use them to validate decisions already made — a probe run after the feature ships is a post-mortem, not an experiment.

**Incorrect (full build to learn, no hypothesis, no criteria):**

```markdown
Plan: Build the team collaboration feature.
Timeline: 6-week sprint.
Goal: See if users like it.
```

**Correct (probe-first, falsifiable hypothesis, explicit success bar):**

```markdown
## PoL Probe: Team Collaboration Demand

**Hypothesis:** Mid-market users (5–50 seats) will invite at least one teammate
within 7 days of activation if a prominent "Invite your team" CTA exists.

**Probe Type:** Fake door
- Add "Invite your team" button to dashboard (no backend built).
- Clicking → modal: "Team features coming soon. Want early access?"
- Record click-through rate and early-access sign-ups.

**Success Criteria:** ≥ 20% of eligible users click within 7 days.
**Timeline:** 5 days to instrument, 2-week measurement window.

**If confirmed (≥ 20%):** Prioritize collaboration feature in next planning cycle.
**If invalidated (< 20%):** Defer feature; explore whether the barrier is awareness
or actual need via 5 follow-up interviews.

**Learning owner:** [PM name] presents findings at next team retrospective.
```

Reference: [Full framework](../references/pol-probe-full.md)
