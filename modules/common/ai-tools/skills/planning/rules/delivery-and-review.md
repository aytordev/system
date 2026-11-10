---
name: delivery-and-review
impact: HIGH
impactDescription: Slice/story/PR units and pull-request topology
---

# Delivery and Review Boundaries

**Impact: HIGH**

## Keep Three Units Distinct

| Unit | Meaning | Default relationship |
|---|---|---|
| Backlog story | Fixed product capability and acceptance scope produced by an upstream splitting conversation | A plan may advance one selected story |
| Implementation slice | Smallest vertical increment or explicit reduction transition/terminal state that can merge and release safely once declared prerequisites land | One pull request by default |
| PR boundary | Review package that owns a whole slice or, exceptionally, a dependent layer inside one slice | Exists independently or inside a deliberate stack |

## Prefer Small Reviewable PRs

Default to the smallest known-good vertical units, with one trunk-based pull
request per slice.

**Why this matters:** Small PRs are easier to review, easier to revert, and
easier to reason about. When something breaks, the cause is obvious. When a
PR sits in review, it does not block unrelated work. The goal is to stay as
close to trunk as possible at all times.

**A PR is too big when** the reviewer needs to hold multiple unrelated
concepts in their head to understand it, or when you would struggle to write a
clear 1–3 sentence summary of what it does.

## Independent PRs Beat Stacks

Keep slice PRs independent when they can merge in any order without blocking
or duplicating work, or when the next branch starts only after its predecessor
lands.

Use a **cross-slice stack** only when all of the following hold: upper slices
have hard dependency or deliberate flow lineage, they will be in flight before
lower slices merge, and review, lead-time, or correction-routing benefits earn
the cascade cost. A hard dependency is sufficient but not required; deliberate
flow lineage may justify a stack. Speculative backtracking alone does not.

Use an **intra-slice stack** only when one fixed slice still needs focused
dependent review layers. In a cross-slice stack each PR owns a complete slice
and the slice completes when its PR lands bottom-up; in an intra-slice stack
the dependent PR layers are focused review boundaries and the slice completes
when its top lands.

There will be exceptions. Use judgement: first define honest vertical slices,
then decide whether they stay independent, share a cross-slice stack, or one
slice needs intra-slice review layers. Never stack an entire plan by default;
slices that span multiple PRs without an explicit delivery decision are an
anti-pattern.
