# Epic Hypothesis — Full Framework

## Purpose

Frame epics as testable hypotheses using an if/then structure that makes assumptions
explicit, defines lightweight experiments ("tiny acts of discovery"), and establishes
measurable success criteria before committing to a full build. This treats epics as
bets to be validated, not features to be shipped unconditionally.

## When to Use

- Early-stage feature exploration before committing to the roadmap.
- Validating product-market fit for new capabilities.
- Prioritizing backlog (validated hypotheses earn higher priority).
- Managing stakeholder expectations (frame work as experiments, not promises).
- Any time there is meaningful uncertainty about whether the proposed work will
  achieve the desired outcome.

## When NOT to Use

- The feature is already well-validated through prior research or data.
- The work is a trivial change where the overhead of hypothesis framing is wasteful.
- Experiments are genuinely not feasible and you must commit before testing (rare).

## The If/Then Hypothesis Structure

Inspired by Tim Herbig's Lean UX hypothesis format:

```
If we [action or solution on behalf of target persona]
for  [target persona]
Then we will [attain or achieve a desirable outcome or job-to-be-done]
```

### Quality Rules

| Element       | Good                                                                 | Bad                                           |
|---------------|----------------------------------------------------------------------|-----------------------------------------------|
| "If we"       | Specific action: "add one-click Slack notifications on task assign"  | Vague: "improve the product"                  |
| "For"         | Clear persona: "remote PMs juggling 3+ distributed teams"           | Generic: "users"                              |
| "Then we will"| Measurable outcome: "reduce task response time from 4h to 1h"       | Feature restatement: "users will have alerts" |

## Tiny Acts of Discovery Experiments

Before building the full epic, define lightweight experiments to test the hypothesis:

```
We will test our assumption by:
- [Experiment 1: low-cost, fast test]
- [Experiment 2: another low-cost, fast test]
```

### Experiment Types

| Type                | Description                                                       | Speed    |
|---------------------|-------------------------------------------------------------------|----------|
| Prototype + testing | Clickable Figma prototype tested with 5-10 users                 | Days     |
| Concierge test      | Manually perform the feature for a few users, measure value      | Days     |
| Landing page test   | Describe the feature, measure sign-ups or interest               | Days     |
| Wizard of Oz        | Present as automated, do it manually behind the scenes           | Weeks    |
| A/B test            | Test a lightweight version against control                        | Weeks    |

### Experiment Quality Checks

- **Fast:** Days or weeks, not months.
- **Cheap:** Avoid full engineering builds. Use prototypes, manual processes, or
  existing tools.
- **Falsifiable:** Design experiments that could prove you wrong.

## Validation Measures

```
We know our hypothesis is valid if within [timeframe]
we observe:
- [Quantitative measurable outcome]
- [Qualitative measurable outcome]
```

### Quality Rules

- Timeframe is realistic: 2-4 week validation cycles, not 6 months.
- Quantitative measures are specific: "20% increase in activation rate," not "more users."
- Qualitative measures are observable: "8 of 10 users say they would pay," not "users like it."

## Full Template

```markdown
## Epic Hypothesis: [Name]

### If/Then Hypothesis

**If we** [action or solution on behalf of the target persona]
**for** [target persona]
**Then we will** [desirable outcome or job-to-be-done]

### Tiny Acts of Discovery Experiments

**We will test our assumption by:**
- [Experiment 1]
- [Experiment 2]
- [Add more as necessary]

### Validation Measures

**We know our hypothesis is valid if within** [timeframe]
**we observe:**
- [Quantitative measurable outcome]
- [Qualitative measurable outcome]
- [Add more as necessary]
```

## Decision Point After Experiments

| Result        | Action                                                              |
|---------------|---------------------------------------------------------------------|
| Validated     | Proceed to user stories and add to roadmap                          |
| Invalidated   | Kill the epic or pivot to a different hypothesis                    |
| Inconclusive  | Run additional experiments or tighten validation measures            |

## Worked Example — Good Hypothesis

```markdown
## Epic Hypothesis: Google Calendar Integration for Trial Users

### If/Then Hypothesis

**If we** provide one-click Google Calendar integration during onboarding
**for** trial users who manage multiple meetings and tasks daily
**Then we will** increase activation rate from 40% to 50%

### Tiny Acts of Discovery Experiments

**We will test our assumption by:**
1. Creating a clickable Figma prototype and testing with 10 trial users
2. Adding a "Connect Google Calendar" CTA to onboarding (non-functional)
   and measuring click-through rate
3. Manually syncing Google Calendar for 5 trial users and surveying them
   after 1 week on perceived value

### Validation Measures

**We know our hypothesis is valid if within 4 weeks we observe:**
- Click-through rate on the CTA is >60% (quantitative)
- 8 of 10 prototype testers say they would use this feature regularly (qualitative)
- Manually synced users report saving 10+ minutes per day (qualitative)
```

## Worked Example — Invalidated Hypothesis (Good Process)

```markdown
## Epic Hypothesis: Slack Integration for Notifications

### If/Then Hypothesis

**If we** send Slack notifications when tasks are assigned
**for** remote project managers
**Then we will** reduce task response time from 4 hours to 1 hour

### Tiny Acts of Discovery Experiments

**We will test our assumption by:**
1. Manually sending Slack notifications to 10 PMs for 2 weeks
2. Measuring response time before and after
3. Surveying users on perceived value

### Validation Measures

**We know our hypothesis is valid if within 2 weeks we observe:**
- Average response time drops from 4 hours to 1 hour (quantitative)
- 8 of 10 users say Slack notifications helped them respond faster (qualitative)

### Results

- Average response time: 3.5 hours (minimal improvement)
- User feedback: "I already get too many Slack notifications. I ignore most."
- Decision: Hypothesis INVALIDATED. Pivot to in-app notifications or email digests.
```

The team killed the epic before wasting engineering time. This is a success.

## Anti-Example — Bad Hypothesis

```markdown
**If we** improve the dashboard
**for** users
**Then we will** make the product better
```

Failures: "improve the dashboard" is not specific. "Users" is not a persona. "Make the
product better" is not measurable. No experiments defined. No validation criteria.

Fix: "If we add real-time task status updates to the dashboard for project managers
managing 10+ team members, then we will reduce time spent checking task progress from
20 min/day to 5 min/day."

## Common Pitfalls

| Pitfall                          | Symptom                                             | Fix                                                                |
|----------------------------------|-----------------------------------------------------|--------------------------------------------------------------------|
| Hypothesis is a feature          | "Then we will have a dashboard"                     | Focus on user outcome, not feature existence                       |
| Skipping experiments             | "We will test by building the full feature"         | Design lightweight experiments taking days, not months              |
| Vague validation measures        | "Users are happy"                                   | Specific falsifiable metrics with numbers                          |
| Unrealistic timeframes           | "Within 6 months revenue increases"                 | 2-4 week cycles; use leading indicators if lagging ones are slow   |
| Treating epics as commitments    | "We told the CEO so we must ship it"                | Frame as hypotheses before making commitments                      |
| Output over outcome              | "Ship feature X by Q2"                              | Did it achieve the outcome? Measure the outcome, not the delivery  |

## Process Flow

1. **Gather context:** Problem understanding, target persona, jobs-to-be-done,
   current alternatives.
2. **Draft the if/then hypothesis** with specific action, clear persona, and
   measurable outcome.
3. **Design tiny acts of discovery** — lightweight, cheap, fast experiments.
4. **Define validation measures** — quantitative and qualitative, within a 2-4 week
   timeframe.
5. **Run experiments and evaluate** — validate, invalidate, or run more experiments.
6. **Convert to user stories** if validated; kill or pivot if invalidated.

## References

- Tim Herbig, *Lean UX Hypothesis Statement*
- Jeff Gothelf and Josh Seiden, *Lean UX* (2013)
- Alberto Savoia, *Pretotype It* (2011)
- Eric Ries, *The Lean Startup* (2011)
- Source skill: `deanpeters/Product-Manager-Skills` — `skills/epic-hypothesis/SKILL.md`
