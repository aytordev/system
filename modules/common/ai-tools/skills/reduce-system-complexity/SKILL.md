---
name: reduce-system-complexity
description: "Trigger: the user explicitly wants fewer branches, states, dependencies, layers, flags, retries, jobs, adapters, or operational moving parts in a selected system or behavior path and needs evidence that complexity was removed rather than relocated. Supports read-only diagnosis and authorized reduction slices governed by a conservation ledger with separate behavior and mechanism gates. Not for routine cleanup, architecture-investment discovery, module-contract design, physical tree design, new behavior, functionality cuts, speculative rewrites, or Redux/functional reducer functions."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Reduce System Complexity

Conserve behavior. Minimize mechanism.

Use this skill only after a concrete behavior path or subsystem has been
selected and the intended result is **net removal of mechanism**. It owns the
conservation ledger, whole-path mechanism accounting, first-principles minimum,
and separate behavior and mechanism gates. Architecture-investment discovery
stays an audit task; ordinary bounded behavior-preserving cleanup stays
refactoring.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The user explicitly asks for fewer branches, states, dependencies, layers,
  flags, retries, jobs, adapters, or operational moving parts in a selected
  path or subsystem.
- The result must be evidenced as complexity removed, not relocated.

Do not use it for routine cleanup without a whole-path reduction claim, for
discovering which architecture investment to make, for designing one module's
contract or the physical tree, for new behavior, for functionality cuts, for
speculative rewrites, or for functional/Redux reducer functions and
state-management choices.

## Hard Rules

1. **Preserve the requested scope.** Do not widen one path into a repository rewrite.
2. **Diagnosis is read-only.** The report is the only default write;
   implementation needs explicit authority.
3. **Never destructively reset, checkout, or overwrite** user or teammate
   changes; repository instructions, decisions, glossaries, public contracts,
   and dirty worktrees constrain the work.
4. **Redact secrets, tokens, personal data, and production payloads** from
   fixtures, traces, snapshots, and reports.
5. **Scale the ledgers to risk.** A local flag removal does not need the
   ceremony of a distributed migration; a data, authorization, concurrency,
   compatibility, or external-effect change does.
6. **Finite tests are preservation evidence, never proof of universal
   equivalence.** State confidence and fidelity gaps.
7. **Default external-effect checks to read-only or a disposable sandbox**, never
   writing to a live external system without specific authority for that effect.
8. **Behavior and mechanism gates are evaluated separately**, and no
   net-reduction claim is allowed before the terminal state removes the
   superseded mechanism.

## Execution Steps

1. **FIX SCOPE, MODE, AND CONTRACT** — state entry points, outcomes, callers,
   data, integrations, and operational path; diagnosis or authorized
   implementation mode; what "less mechanism" means here; excluded behavior;
   irreversible effects. Classify observed behavior before promising to
   conserve it (`rules/conservation-contract.md`).
2. **BASELINE THE MECHANISM** — trace each conserved behavior from trigger to
   outcome and recovery; inventory control, state and time, structure, and
   variability/operations dimensions with the same scope and counting method
   used afterward, including tests and operational machinery that impose
   ownership cost. Never combine unlike counts into a synthetic score
   (`rules/mechanism-accounting.md`).
3. **DERIVE A MINIMUM FROM CONSTRAINTS** — answer independently of the current
   shape: required outcomes and guarantees, irreducible domain decisions, fixed
   boundaries, and the shortest coherent trigger-to-outcome path. Seek leverage
   by deleting obsolete machinery first, then unifying, shrinking, and removing
   hops; reject proposals that merely rename, split, wrap, relocate, or conceal
   complexity.
4. **SELECT A COMPLETE REDUCTION** — prefer removing one complete mechanism
   over partial hiding; record before/target observations, affected callers and
   contracts, proof obligations, rollout needs, and the terminal state. Prefer
   a small reversible slice; define a guarded forward-recovery path when
   reversal is impossible or unsafe (`rules/reduction-slices.md`).
5. **REDUCE THROUGH THE REFACTOR PATH** — only when authorized. Classify each
   slice as a reduction transition or terminal reduction; make the smallest
   coherent change that advances the complete reduction; keep provider checks
   read-only or sandboxed; remove superseded code, flags, state, configuration,
   and expired bridges. If evidence fails, stop and recover only this slice's
   own edits (`rules/reduction-slices.md`).
6. **APPLY THE GATES** — behavior gate: every affected ledger entry has passing
   preservation evidence at the required fidelity, with boundary cases
   exercised or covered by proportionate reachability, configuration,
   contract, integration, or operational evidence. Mechanism gate: recount the
   same dimensions over the same scope and method, map every new part to what
   it replaces, inspect callers and operations for exported burden, and confirm
   the superseded mechanism and expired bridges are gone.

## Output Contract

Write a fresh report per [`references/ledger-template.md`](references/ledger-template.md),
defaulting to a timestamped file in the OS temporary directory. Diagnosis
reports proposed reductions, target deltas, evidence gaps, risks, and the next
decision — claiming neither equivalence nor realized reduction. A transition
reports `behavior gate: pass` plus `mechanism gate: pending — no net-reduction
claim`. A terminal reduction claims realized reduction only when both gates
pass and the superseded machinery plus expired bridges are gone, disclosing
remaining fidelity gaps and essential complexity.

## Completion Check

- Was a concrete system or behavior path selected before this workflow began,
  and are documented, relied-upon, intended, disputed, and obsolete behaviors
  distinguished?
- Does every affected guarantee have proportionate preservation evidence or an
  explicit blocking gap?
- Does the baseline include callers and operational machinery, not only edited
  files?
- Is the minimum derived from real constraints rather than fashionable shape,
  and does the terminal state remove mechanism rather than move or hide it?
- Is every implementation artifact classified as a reduction transition or
  terminal reduction, with the program and terminal slice linked?
- Are temporary migration mechanisms owned, bounded, and scheduled for removal,
  or explicitly `N/A` when none exist?
- Were behavior and mechanism gates evaluated separately, and are claims
  calibrated to the evidence?

## References

- [`rules/conservation-contract.md`](rules/conservation-contract.md) — behavior classification, the ledger, evidence discipline.
- [`rules/mechanism-accounting.md`](rules/mechanism-accounting.md) — baseline dimensions, minimum derivation, gates.
- [`rules/reduction-slices.md`](rules/reduction-slices.md) — transitions, terminal slices, bridges, implementation safety.
- [`references/ledger-template.md`](references/ledger-template.md) — the reduction evidence template.
- [`references/provenance.md`](references/provenance.md) — upstream source, revision, and licence notice.

Companion skills are optional here. When a characterisation-testing, TDD, or
mutation-testing skill is not installed, apply the discipline directly: capture
current behavior before changing it when no usable oracle exists, write the
failing test before any behavior change, and verify the accumulated reduction
once at review readiness with a mutation harness where meaningful — otherwise
an explicit `N/A` with proportionate alternate evidence.
