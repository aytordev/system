---
name: example-map
impact: CRITICAL
impactDescription: Map grammar, challenge protocol, and shape diagnostic
---

# The Example Map

**Impact: CRITICAL**

The map is data, not prose. Build it as you go and keep it visible:

```
story:     <one line, in the words the human used>
rules:     # business policies / acceptance criteria
  - rule: <policy in domain language>
    examples:
      - <concrete: real values, real outcome — never a restatement of the rule>
    questions: # open assumptions attached to THIS rule (optional); parked items include owner and decision/review date
questions: # cross-cutting open assumptions; parked items include owner and decision/review date
acceptance criteria: # distilled from rules once examples stabilise
candidate terms:     # vocabulary the conversation coined or contested
```

## Challenge the Map Before Trusting It

For each rule, run the challenge protocol:

1. **Counter-example question** — "what would have to be true for this
   example to come out differently?"
2. **Zero–one–many** — probe the boundaries of every quantity the rule
   touches.
3. **Boundaries** — what happens at the edges the rule does not name?
4. **Failure behavior** — what happens when the rule is violated?

A rule with one example is a guess. A rule whose examples all agree is a
hypothesis. Concrete examples use real values and real outcomes — never a
restatement of the rule in example-shaped clothing.

## Read the Map's Shape as a Diagnostic

- **Question-dominated** → not ready to build. Keep talking, or park the open
  questions with owners and stop. Do not convert uncertainty into guessed
  acceptance criteria.
- **Rule-dominated** (more than ~6 rules) → too big. Hand the map to the
  splitting activity so it becomes child stories.
- **Balanced, with concrete examples per rule** → ready for accountable
  review and, later, implementation sequencing.

## Acceptance Criteria

Distill acceptance criteria from the rules only once the examples stabilise.
They remain hypotheses until the shipped slice confirms them; when reality
disagrees, the conversation reopens with the disagreement as a new question.

Every example written here is written back into the team's own story
artifact, in the words its owner used, so the map never forks from the
artifact it governs.
