---
title: Reduce Through Authorized Slices
impact: HIGH
impactDescription: Transitions and terminal slices stay honest and recoverable
tags: reduction, slices, migration
---

## Reduce Through Authorized Slices

**Impact: HIGH**

Only continue to implementation when authorized. Every artifact is classified
before editing.

### Slice classification

- **Reduction transition** — an independently verifiable program increment that
  preserves the conserved contract but may temporarily leave or add mechanism.
  It references the plan/ledger and terminal slice, records
  owner/removal/bounded-lifetime metadata for any bridge (`N/A` when none), and
  keeps `mechanism gate: pending — no net-reduction claim`.
- **Terminal reduction** — the slice that removes the superseded mechanism and
  expired bridges. It references the program/ledger and discharges prior
  transition obligations, or records `N/A — authorized single terminal slice`.
  It may claim net reduction only after both gates pass.

A transition can be a safe mergeable increment while the **program** remains
unfinished. Do not describe it as a completed reduction or let it lose the
reducer ledger merely because its own mechanism gate is pending.

### The safe-slice procedure

1. Record the pre-slice state and run affected behavior, type, build,
   integration, and operational checks.
2. Identify database, queue, deployment, message, authorization, concurrency,
   and other irreversible effects before editing.
3. Make the smallest coherent change that advances the complete reduction.
4. Preserve behavior-facing tests. Retire implementation-shaped tests only
   after equivalent behavioral coverage is in place; the end-of-phase mutation
   or alternate-evidence gate verifies the accumulated suite before review.
5. Run focused checks immediately, then the broader relevant suite and
   provider/contract checks where mocks cannot establish fidelity. Keep
   provider checks read-only or sandboxed unless explicit authority covers the
   exact live effects; never perform live migrations, failover, rollback,
   publication, or external writes by implication.
6. Remove superseded code, dependencies, flags, state, configuration, tests of
   discarded internals, and temporary bridges whose removal condition is met.
7. Re-read the full path, including callers, operations, failure, and recovery.

A behavior-preserving reduction begins from passing behavior oracles plus
proportionate reachability, configuration, contract, integration, and
operational evidence. It is a refactoring-path change, not a reason to
fabricate a failing test that asserts branch, layer, state, or dependency
counts. If the desired outcome changes observable behavior or fixes a disputed
bug, stop this workflow, resolve the intended contract, and use test-first
development for the behavior change.

### Bridges and transitions

Expand/contract migrations may temporarily add a bridge, flag, dual write, or
compatibility shim; give each one an owner, removal condition, and bounded
lifetime. Record `N/A` when a transition introduces no temporary bridge. Do not
claim reduction until the terminal state removes the superseded mechanism. If
multiple delivery slices are needed, plan them after the complete reduction and
gates are defined.

### Failure and recovery

If evidence fails or a new affected behavior appears, stop. Recover only edits
and effects owned by this slice, without destroying unrelated work. Never use
modified behavior as the pre-change baseline.
