---
name: quality-and-output
impact: CRITICAL
impactDescription: INVEST bar, validation checklist, red flags, output format
---

# Quality Bar, Validation, and Output Format

**Impact: CRITICAL**

## Child Story Quality Bar

Use INVEST as a quality check, not a template:

| Letter | Check |
|--------|-------|
| I | Independent enough to build, test, release, reorder, or drop without waiting for every sibling |
| N | Negotiable in scope and quality level; not a fixed solution order |
| V | Valuable to a real user, external system, business stakeholder, operator, or learning goal |
| E | Estimable because the behavior, unknowns, and deferrals are visible |
| S | Small enough to finish in the target planning horizon |
| T | Testable through observable examples |

Also apply the feedback triad: a good slice **works**, **delivers value**,
and **can generate user feedback**. If it only makes internal progress, it is
probably a task. If it works but produces no possible feedback or learning,
ask whether a thinner or different slice would be more useful.

## Validation Checklist

Before returning a split, check every child story:

- Does it name a real actor or external system?
- Does it have a trigger and observable outcome?
- Does it run through the real production path needed for that behavior?
- Could it be tested without waiting for every sibling story?
- Could it generate feedback, learning, or a visible decision if shipped,
  demoed, or exercised?
- If no later story happens, did this still deliver value or learning?
- Are dependencies explicit and small enough to manage?
- Are deferred paths, data, rules, and qualities visible?
- Is it safe to ship, or is the release constraint explicit?
- Does it avoid prescribing unnecessary implementation details?
- Is the eventual full capability still visible, so useful follow-up slices
  are not forgotten?

## Red Flags

- Child stories split by process activity: design, code, test, document,
  deploy.
- "As a database/API/frontend/service..."
- "Build the backend" and "build the frontend" as separate stories.
- "Collect data" or "build integration" without a user-visible or
  feedback-generating outcome.
- Every child must finish before any child can be tested.
- A spike for every story.
- Acceptance criteria that say "works" or "fast" without observable detail.
- Slices so tiny they only specify a solution detail.
- All business rules forced into the first slice without discussion.

## Output Format

Return a compact artifact that feeds directly into implementation planning:

```markdown
## Parent
[Reframed parent capability]

## Recommended First Slice
[One sentence story]

Why this first: [value, risk, learning, or bargain]

## Split Candidates
| Slice | Value | Includes | Defers | Acceptance Examples | Release Constraint |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

## Parking Lot
[Explicit follow-ups, questions, or intentionally unsplit tasks]

## Warnings
[Component splits, unsafe deferrals, unclear ownership, or missing examples]

## Next Step
[Hand the selected first slice to the project's implementation-planning
instructions, run a further hardening pass on the split when a gap-review
companion is installed, or ask one decision question. Do not prescribe TDD,
mutation timing, feature flags, or pre-PR gates here.]
```

Where a specification companion is installed, unresolved decision trees go to
its one-question protocol; where a find-gaps companion is installed, use it
to tighten the split's missing states, acceptance criteria, and edge cases
after this artifact exists.
