---
name: implementation-cadence
impact: CRITICAL
impactDescription: Red-green-refactor cadence, evidence gates, and commit discipline
---

# Implementation Cadence and Commit Discipline

**Impact: CRITICAL**

## Per-Slice Cadence

Every behavior-changing slice or review boundary runs this cadence. It is a
self-contained contract: where a dedicated TDD, testing, or refactoring skill
is installed, load it as an optional companion; where it is not, these rules
govern alone.

```
FOR EACH BEHAVIOR-CHANGING SLICE OR PR BOUNDARY:
    ├─ CONFIRM: Present acceptance criteria; do not write code until approved.
    ├─ RED: Write the failing test FIRST, for the right reason, and run only
    │       the exact test needed to prove RED.
    ├─ GREEN: Write MINIMUM code to pass. No extra features, no premature
    │         optimization. Prefer a proven repository-owned watcher; use
    │         watch mode only under a canonical version/configuration proof;
    │         otherwise run the affected one-shot. Never hand-pick GREEN test
    │         files, never accept zero-test or --passWithNoTests results.
    ├─ REFACTOR: Assess improvements only if they add value; focused and
    │            affected tests stay green; do not rerun the full suite after
    │            every edit.
    ├─ REPEAT the cadence as needed.
    └─ STOP: Present the work and wait for commit approval.
```

Substitute flows:

- **Pure refactor**: confirm the preserved consumer contract → run the
  applicable passing baseline → restructure while staying green → verify the
  preserved surface → at review readiness, one end-of-phase evidence gate for
  the accumulated scope.
- **Reduction transition**: link the program ledger and terminal slice →
  confirm the conserved contract → passing baseline → independently
  verifiable transition → behavior gate passes → bridge metadata recorded
  (`N/A` when none) → mechanism gate stays "pending — no net-reduction claim".
- **Terminal reduction**: link the program ledger → passing baseline → remove
  superseded machinery and expired bridges → discharge transition obligations
  → both gates pass.

**No untested behavior changes. No "I'll add tests later."** Do not defer
tests or evidence up a stack: tests land in the PR that first owns the
behavior, and the top boundary proves every included slice's cumulative
acceptance criteria.

## End-of-Phase Evidence Gate

When the current review boundary is otherwise ready for its PR, run mutation
evidence once for the focused scope where meaningful; address valuable
survivors and re-run focused/diff checks within the same gate. Otherwise
record an explicit `N/A` and name the proportionate alternate evidence
(reachability, configuration, contract, integration, or operational). Never
invent structural mutants or fabricate a failing mechanism-count test.

## Pre-PR Quality Gate

Before each PR boundary:

1. Implementation complete — refactor/reduction assessment and ordinary
   verification are complete.
2. Evidence gate complete — mutation run for the accumulated scope or the
   reviewed `N/A` record with alternate evidence.
3. Typecheck and lint pass.
4. Complete tests — stop watchers and run the repository-defined complete
   non-watch test gate; in a monorepo include every configured project and
   required integration/end-to-end suite, not only the affected subset.
5. Evidence freshness — apply the target repository's mutation-evidence rule
   after later fixes. Where the repository has no stricter invalidation
   policy, use the default model: keep project verification current after any
   resulting fixes, then present the review summary.

## Commit Discipline

**Never commit without user approval.**

After completing an implementation increment:

1. Verify applicable tests pass and/or the approved preservation evidence
   still holds.
2. Verify static analysis passes.
3. Present class-specific evidence: red/green for behavior change; preserved
   contract for a pure refactor; behavior gate plus pending mechanism gate for
   a transition; both passing gates plus retired machinery for a terminal
   reduction.
4. Do not demand a mutation report for every commit — the evidence gate runs
   once at review readiness.
5. **STOP and ask**: "Ready to commit [description]. Approve?"

Proceed only after explicit approval. Plans are not immutable, but plan
changes are always explicit: explain what changed and why, propose updated
slices, and wait for approval before proceeding.
