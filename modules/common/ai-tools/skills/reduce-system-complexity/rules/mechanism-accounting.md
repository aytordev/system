---
title: Account for Mechanism and Derive the Minimum
impact: CRITICAL
impactDescription: Same-scope before/after evidence instead of displaced complexity
tags: reduction, mechanism, gates
---

## Account for Mechanism and Derive the Minimum

**Impact: CRITICAL**

A smaller function, directory, or diff is not a reduction when callers,
operators, dependencies, or recovery paths inherit the removed burden.

### Baseline the whole mechanism

Trace each conserved behavior from trigger to outcome and recovery. Inventory
applicable mechanism dimensions with the same scope and counting method that
will be used afterward:

- **Control** — decisions, conditions, ordering, error, retry, fallback, and
  recovery paths. Cyclomatic complexity may be one local signal, not a
  cross-system total.
- **State and time** — states, transitions, mutable owners, caches, queues,
  tasks, callbacks, locks, synchronization points, and lifecycle phases.
- **Structure** — modules, representations, layers, hops, internal and external
  dependencies, cycles, adapters, and translations.
- **Variability and operations** — flags, modes, configuration, extension
  points, deployables, jobs, migrations, monitors, runbooks, and failure
  handling.

Include tests and operational machinery when they impose ongoing ownership
cost. Exclude generated artifacts unless their source, build, or runtime
mechanism changes. Mark irrelevant dimensions `N/A`. For mixed runtimes,
include runtime entries and conversions across consumers and implementations in
the before/after inventory, not only wrappers removed at the entry point.

Do not combine unlike counts into a synthetic score.

### Derive a minimum from constraints

Answer independently of the current shape:

1. Which outcomes and non-functional guarantees must exist?
2. Which domain decisions and external constraints are irreducible?
3. Which boundaries are fixed, and who must own state, time, failure, and
   recovery?
4. What is the shortest coherent path from trigger to observable outcome?

Sketch the minimum plausible mechanism and name the constraint that earns every
remaining part. Seek leverage in this order:

1. Delete proven-obsolete paths, options, flags, configuration, fallbacks, and
   speculative machinery.
2. Unify duplicated policy, representation, state, and ownership.
3. Shrink decision and state spaces.
4. Remove pass-through layers, translation chains, temporal hops, and
   coordination.
5. Replace custom machinery with an established primitive only when total
   lifecycle and operational cost fall; a consequential dependency or tool
   choice deserves its own evaluation of existing solutions.

Reject proposals that merely rename, split, wrap, relocate, or conceal
complexity. A deeper module may improve callers while retaining or increasing
internal mechanism; that is a valid module-design outcome but not, by itself, a
successful reduction.

### Select a complete reduction

Rank candidates qualitatively:

1. Prefer removal of one complete mechanism over partial hiding.
2. Prefer stronger preservation evidence and fewer fidelity gaps.
3. Use smaller blast radius and easier recovery as tie-breakers.

For the selected candidate, record: the exact mechanism and conserved behaviors;
objective before/target observations per applicable dimension; affected
callers, data, integrations, operations, and public contracts; missing oracles
and other proof obligations; rollout, observability, compatibility, data
migration, and recovery needs; the terminal state in which old machinery is
gone; and for a multi-slice program the plan/ledger identity, terminal slice,
and class of each slice.

### The two gates

**Behavior gate** — every affected ledger entry has passing preservation
evidence at the required fidelity; outcomes, effects, errors, ordering,
boundaries, and non-functional constraints remain within the agreed contract;
boundary cases implied by each removed decision, state, dependency, or fallback
have been exercised where reachable and meaningful, or explicit
reachability/configuration/contract/integration/operational evidence covers the
claim; remaining uncertainty and untested provider behavior are explicit.

**Mechanism gate** — recount the same dimensions over the same scope and
method; map every newly introduced part to the old mechanism it replaces or the
essential constraint it serves; inspect callers, adapters, operations,
deployment, and recovery for exported burden; confirm the superseded mechanism
and expired migration bridges are gone; confirm total lifecycle ownership fell.
A net-neutral or merely displaced terminal result fails; a transition-only
result keeps this gate pending and means the program, not necessarily the
mergeable slice, is unfinished.
