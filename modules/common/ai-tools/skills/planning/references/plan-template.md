# Plan File Template

Use this template for the repository-declared plan artifact. A repository may
own plans in documentation, issues, or another named system; when no owner is
declared and a file-backed plan is appropriate, use `plans/` at the project
root with a descriptive filename (for example, `plans/gift-tracking.md`).
Multiple plans coexist with unique filenames and never conflict across
branches or worktrees.

Classify every slice — **behavior change**, **pure refactor**,
**reduction transition**, or **terminal reduction** — and read the
repository's governing instructions and testing rules before writing slices.
Never inherit a behavior-change workflow into a slice that only preserves
behavior or removes mechanism.

```markdown
# Plan: [Feature Name]

**Branch**: feat/feature-name
**Status**: Active

## Goal

[One sentence describing the outcome.]

## Acceptance Criteria

[Use behavior-driven criteria that describe observable business outcomes, not
implementation details. Test at the lowest level that gives confidence:
unit tests for logic/domain behavior, browser tests for UI interaction, and
end-to-end tests only for end-to-end flows. For a reduction program, define
the conserved observable contract, the terminal same-scope mechanism delta,
the retirement of superseded machinery and expired bridges, the passing
behavior and mechanism gates, and mutation results or an explicit N/A with
proportionate alternate evidence. Do not invent new product behavior or tests
for mechanism shape.]

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Slices

<!-- Classify every slice; behavior-changing slices use red-green-refactor
     increments; every class runs one end-of-phase evidence gate at review
     readiness; reduction classes define the conserved contract, terminal
     mechanism-removal state, and behavior/mechanism gates inline. -->

### Slice 1: [One sentence observable behaviour]

**Value**: [Behavior change: actor and observable outcome. Pure refactor:
preserved consumer surface and maintenance value. Reduction transition: why
this independently verifiable increment is necessary to reach the terminal
state. Terminal reduction: conserved contract plus the mechanism retired.]
**Path**: [Behavior change: entry point -> business path -> state/output ->
observability. Pure refactor: preserved public surface. Either reduction
class: affected trigger-to-outcome path, program/terminal link, and mechanism
scope.]
**Class**: Behavior change / pure refactor / reduction transition / terminal
reduction.
**Delivery**: [Independent PR against trunk (default); cross-slice stack
member referencing the shared `#### Delivery Shape`; or an intra-slice
`#### Delivery Shape` map.]
**Reduction program**: [For either reduction class: reference the plan-level
program and terminal slice — ledger, conserved contract, superseded
mechanism, terminal slice; otherwise `N/A`.]
**Transition/terminal evidence**: [Transition: `behavior gate: pass`,
independent verification, bridge owner/removal/bounded-lifetime metadata when
a bridge exists (`N/A` otherwise), and `mechanism gate: pending — no
net-reduction claim`. Terminal: passing behavior gate, like-for-like
mechanism gate, and removal of the superseded mechanism and expired bridges.
Otherwise `N/A`.]
**Acceptance criteria**: [Behavior change: specific observable outcome. Pure
refactor: conserved surface plus preservation evidence. Reduction transition:
passing behavior gate, independent verification, optional bridge metadata,
pending mechanism gate. Terminal: both gates pass, machinery and expired
bridges gone. **Present to the human and get confirmation before writing any
code.**]
**RED or preservation baseline**: [Behavior change: the failing behavior test
to write. Pure refactor/reduction: the passing oracles and proportionate
non-test evidence that conserve the affected behavior and guarantees.]

### Slice 2: [One sentence observable behaviour]

[Use the same adaptive fields as Slice 1. Classify this slice independently;
do not inherit a workflow from its neighbor.]

## Pre-PR Quality Gate

<!-- For an intra-slice stack, nest the exact `#### Delivery Shape` and the
     whole-stack gate under that slice. For a cross-slice stack, place one
     shared delivery map before the first included slice and reference it
     from each included slice. Never stack an entire plan by default. -->

---
*Complete this plan using the repository's declared lifecycle. For the
fallback `plans/` layout, delete this file and remove the directory when
empty.*
```

## End of Feature

When every slice's owning PR has landed (or the top PR of each intra-slice
stack):

1. **Verify completion** — all owning PRs landed, all acceptance criteria met,
   tests and the end-of-phase evidence gates pass, and any reduction program
   reached a terminal slice with both gates passed and old machinery and
   expired bridges gone.
2. **Merge learnings** — promote significant insights to the repository's
   established guidance or ADR mechanism; use any installed project-guidance
   or ADR skill as an optional companion.
3. **Close the plan** — follow the repository's declared lifecycle; for the
   fallback `plans/` layout, delete the file and remove the directory when
   empty, after promoting lasting decisions to the maintained artifact that
   owns them.
