---
title: Epic Hypothesis
impact: HIGH
impactDescription: Untested assumptions baked into epics waste sprint capacity on the wrong solution
tags: hypothesis, epics, lean, outcomes, experimentation
---

## Epic Hypothesis

**Impact: HIGH (Untested assumptions baked into epics waste sprint capacity on the wrong solution)**

Transform vague initiatives into testable hypotheses using the format: "We believe [action] for [audience] will achieve [outcome] as measured by [metric]." Use this before committing an epic to a roadmap to make the success condition explicit and falsifiable. Do not skip the metric — without it, teams cannot determine whether the work succeeded. This is not a solution spec; it is a learning frame that guides what to build and what to measure.

**Incorrect (solution-framed, no measurable outcome):**

```markdown
Epic: Build an onboarding flow

We will create a multi-step onboarding wizard for new users
that walks them through setting up their profile and preferences.
```

**Correct (hypothesis-framed with audience, action, outcome, and metric):**

```markdown
Epic: Improve new user onboarding

We believe that providing a guided 3-step setup flow
for new users who have not completed their profile
will increase 7-day activation rate
as measured by the percentage of sign-ups who complete
at least one core action within their first week.

Current baseline: 22% | Target: 35%
```

Reference: [Full framework](../references/epic-hypothesis-full.md)
