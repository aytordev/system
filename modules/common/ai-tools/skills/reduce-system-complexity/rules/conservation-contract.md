---
title: Classify Behavior and Keep the Conservation Ledger
impact: CRITICAL
impactDescription: Decides what may be conserved, changed, or deleted
tags: reduction, behavior, ledger
---

## Classify Behavior and Keep the Conservation Ledger

**Impact: CRITICAL**

Characterisation tests reveal what the code does; they do not decide what it
ought to do. Classify observed behavior before promising to conserve it.

### Behavior classification

| Class | Treatment |
|---|---|
| Documented or accepted contract | Preserve unless the user authorizes a behavior change |
| Relied-upon observable behavior | Treat as compatibility-sensitive, even when undocumented |
| Intended and currently supported or observed behavior with credible evidence | Preserve and strengthen its oracle where needed; aspirational intent is a behavior change and returns to contract resolution plus test-first development |
| Known bug or disputed behavior | Surface for a product/domain decision; do not silently preserve or fix it |
| Unreachable, obsolete, or speculative internals | Candidate for deletion only after reachability and consumer evidence |

Inventory outputs, effects, errors, ordering, persistence, integrations,
authorization, security, privacy, reliability, resource budgets, compatibility,
concurrency, retries, migrations, and recovery behavior. Record each in the
behavior-and-guarantee ledger with its evidence and gaps.

### Evidence discipline

- Diagnosis records missing oracles without editing. When implementation and
  test-harness work are separately authorized, characterize current behavior
  before changing anything it depends on.
- Record the eventual mutation scope, but defer the automated mutation harness
  until the reduction slice is otherwise ready for review.
- At that end-of-phase review-readiness gate, mutation evidence is not
  meaningful for every proven-unreachable path, configuration-only change,
  generated boundary, or operational mechanism. Mark it `N/A` with
  reachability, configuration, contract, integration, or operational evidence
  instead. Never invent structural mutants or fake a failing test to satisfy
  the workflow.
- Implementation remains diagnosis while any material behavior the proposed
  slice can affect has an unresolved evidence gap.

### Fixed contracts and exclusions

State the excluded behavior and boundaries, the irreversible effects and
published contracts that constrain the work, and what "less mechanism" means
for this scope. Do not inherit the current decomposition as the target, but do
not ignore undocumented constraints discovered in it.
