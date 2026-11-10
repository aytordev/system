---
title: Generate and Rank Evidence-Backed Candidates
impact: CRITICAL
impactDescription: Candidates need evidence, counterevidence, and honest ranking
tags: architecture, candidates, ranking
---

## Generate and Rank Evidence-Backed Candidates

**Impact: CRITICAL**

Look for more than consolidation. Every candidate names an architectural move
and carries both evidence and counterevidence.

### Candidate kinds

- **Deepen** — move repeated coherent decisions behind a smaller stable
  contract.
- **Collapse pass-through chains** — remove layers that expose rather than hide
  knowledge.
- **Split incoherence** — divide a god module whose responsibilities, owners,
  failures, or change axes diverge.
- **Move a seam** — isolate volatility or external failure where behavior
  actually varies.
- **Repair direction** — stop policy from importing concrete providers, routes,
  or framework glue.
- **Restore locality** — reunite behavior, tests, schemas, and mappers that
  change as one unit.
- **Make a contract honest** — expose required errors, effects, lifecycle, or
  performance while hiding collaborator mechanics.

Apply the deep-module lens (depth, leverage, locality, interface burden, seams,
thin-edge safeguards) during candidate analysis — but do not run a full
module-contract design workflow or propose an exact interface before selection.
Load physical-structure, ports-and-adapters, or domain-driven concerns only
when the candidate actually involves them.

### Reject candidates based only on

- file length or folder aesthetics;
- a single adapter or one duplicated code shape;
- speculative future flexibility.

### Rank before designing

| Dimension | Evidence to seek |
|-----------|------------------|
| Why now | Active change pressure, defects, planned work, or measurable maintenance cost |
| Locality gain | Policy, bugs, and verification would move to one coherent owner |
| Caller leverage | Common callers would learn and coordinate materially less |
| Architectural honesty | Ownership, runtime, trust, failure, and dependency direction improve |
| Testability | Stable behavior can be exercised without reconstructing internals |
| Migration safety | A small reversible path and trustworthy verification exist |
| Counterevidence | Independent change axes, thin-edge roles, compatibility, or fidelity gaps argue against it |

Assign one recommendation strength:

- **Strong** — direct evidence, active value, coherent target, credible safe path.
- **Worth exploring** — plausible value with one or two material questions to resolve.
- **Speculative** — weak or future-oriented evidence; record, but do not
  recommend investment now.

Do not use a numeric score that implies false precision. Report a confidence
level separately from recommendation strength.

If no candidate rises above speculative, recommend **no architecture investment
now**. State what evidence or change pressure would justify revisiting the area
rather than manufacturing a top refactor.

### Every reported candidate contains

1. A title naming the architectural change.
2. Exact files/modules and evidence, including line or history references where
   useful.
3. The current friction and why it matters now.
4. Counterevidence and the strongest reason not to proceed.
5. The proposed responsibility change in plain language, without an exact
   interface.
6. Before/after visuals that match the evidence.
7. Expected locality, leverage, dependency, and test-surface gains.
8. Risks, compatibility constraints, fidelity gaps, and decision-record
   conflicts.
9. Recommendation strength and confidence.
10. A bounded next step.
