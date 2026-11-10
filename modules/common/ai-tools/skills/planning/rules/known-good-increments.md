---
name: known-good-increments
impact: CRITICAL
impactDescription: Known-good state and horizontal-work exceptions
---

# Known-Good Increments and Horizontal Exceptions

**Impact: CRITICAL**

## What Makes a Known-Good Slice

Each slice must:

- Leave all tests passing.
- Be independently deployable.
- Have clear done criteria.
- Fit in a single pull request by default, or have an approved delivery-map
  exception (see `rules/delivery-and-review.md`).
- Be describable in one sentence.
- Deliver or directly unblock observable behavior, or safely advance an
  explicitly selected reduction program toward its terminal gates.

A slice is the unit of planning and known-good value. Within each
behavior-changing review boundary, fast red-green-refactor increments may
produce multiple commits; the end-of-phase evidence gate runs once when that
boundary is otherwise review-ready, not after each increment.

## Horizontal Work Exceptions

Avoid plans that do all database, API, UI, or infrastructure work up front.
Horizontal work may be its own slice only when **all** applicable conditions
are true:

- It names the next vertical slice it unlocks, or belongs to an explicitly
  selected reduction program with a terminal mechanism-removal outcome.
- It leaves the codebase deployable.
- It has observable verification (test, command output, migration dry-run, or
  runtime check).
- It is smaller than doing it inside the vertical slice.
- It does not introduce unused abstractions or speculative flexibility.

Valid horizontal exceptions include dependency upgrades, migrations, test
harness setup, infrastructure wiring, mechanical refactors, safety fixes, and
a selected reduction program whose **terminal state** conserves behavior while
retiring one complete mechanism. Keep them rare and explicit.

## Reduction Programs

An intermediate reduction transition may temporarily add a bridge only when it
is independently verifiable and the same plan names the terminal slice.

Record for every bridge: an accountable owner, an objective removal condition,
and a bounded lifetime — or `N/A` when no bridge exists.

A **reduction transition** never claims net reduction: its mechanism gate
stays truthfully "pending — no net-reduction claim" until the terminal slice
removes the old mechanism and expired bridges. A **terminal reduction** passes
both the behavior gate and a like-for-like mechanism gate, and removes the
superseded machinery and expired bridges.

A plan that starts producing database-only, API-only, UI-only, or "do all
plumbing first" slices without meeting these conditions is a defect: pause and
re-slice vertically.
