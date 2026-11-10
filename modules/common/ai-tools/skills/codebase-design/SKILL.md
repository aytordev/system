---
name: codebase-design
description: "Trigger: designing or changing an in-process module or package contract, consolidating shallow pass-through modules, deciding what to hide behind a caller-facing interface, comparing alternative interface shapes, or asking whether code should be combined or split for leverage and locality. Designs deep modules - substantial behaviour hidden behind a small, stable contract - and treats physical layout, whole-path reduction claims, and public cross-service API publication as separate concerns."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Codebase Design

Design coherent **deep modules**: substantial, related behavior and design
decisions hidden behind a small, stable caller-facing contract. Optimize for
**leverage** for callers and **locality** for maintainers without creating a
god module.

This skill owns logical responsibility and contract shape. Physical paths,
packages, import direction, and folder migration are a separate structure
concern (the structure-codebase companion, when installed). Evidence-backed
claims that total mechanism disappeared over a whole path are a separate
reduction exercise, not a design outcome: a physical or contract change alone
proves no net reduction.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Designing or changing a module's responsibility or caller-facing contract.
- Consolidating shallow pass-through modules, or asking whether code should be
  combined or split for leverage and locality.
- Deciding what to hide, where a seam earns its place, or which dependency
  strategy fits a collaborator.

Do not use it for physical file layout or import enforcement, for a
repository-wide architecture scan, or for an unselected audit: in an audit,
use only this skill's vocabulary, principles, and evidence tests, and do not
propose an exact interface until a candidate is selected.

## Hard Rules

1. **Hide decisions, not merely code.** A private helper extraction that still
   leaks policy, sequencing, or provider mechanics through parameters and call
   order is not depth.
2. **Keep depth cohesive.** A tiny contract over an incoherent implementation
   is a god module; preserve modules that evolve, fail, deploy, or authorize
   independently.
3. **Apply the behavior-preserving inlining test** before defending a module
   (`rules/deep-module-principles.md`).
4. **Pull complexity downward deliberately**, keeping effects, failure modes,
   resource ownership, and performance costs explicit enough for safe use.
5. **Justify every seam with evidence** — substitution, testing, volatility,
   ownership, trust, runtime failure, or deployment. Adapter count is
   evidence, not a rule, and not every module contract is a seam.
6. **Test at the stable contract.** Never export private helpers or expose
   internal seams solely to test them.
7. **Preserve intentionally thin edges.** A route leaf, CLI command, adapter,
   generated client, or composition root is not shallow merely because it is
   thin; judge whether policy is hidden in the correct inside module.
8. **Import provenance honestly.** This is an attributed adaptation
   (`references/source-notes.md`); never present deep-module or seam
   terminology as original.

## Execution Steps

1. **DEFINE** — the behavior owned, callers, common case, and exclusions;
   read project instructions and relevant tests before naming anything new.
2. **INVENTORY** — the full contract burden each caller carries today
   (`rules/contract-workflow.md`); a short type signature is not a small
   interface.
3. **MAP** — hidden and leaked knowledge, plus counterevidence: independent
   ownership, different failure domains, callers needing separate policy.
4. **CHOOSE RESPONSIBILITY FIRST** — one sentence defining the module's
   coherent responsibility before placing seams or choosing dependencies.
5. **DESIGN FROM SCENARIOS** — representative caller examples including
   invalid input, partial failure, cancellation, retries, and lifecycle. For a
   consequential or expensive-to-reverse choice, compare genuinely different
   designs (`references/design-it-twice.md`).
6. **TEST THE DEPTH CLAIM** — does the common caller learn less, did knowledge
   actually move, would a policy change concentrate here?
7. **ROUTE DELIVERY** — physical placement to the structure skill, published
   cross-ownership HTTP contracts to an explicit API-design process, a
   repository-wide scan to a dedicated architecture audit, whole-path
   reduction to the project's reduction plan (`rules/contract-workflow.md`).

Read the relevant reference before proposing a consequential design:
`references/deepening.md` (consolidating modules, dependency classification,
safe migration), `references/design-it-twice.md` (expensive-to-reverse or
several credible shapes), `references/source-notes.md` (provenance).

## Output Contract

Produce a design that states: the module's one-sentence responsibility and
explicit exclusions; callers and representative usage scenarios; the complete
proposed contract including non-type obligations (invariants, ordering,
errors, effects, performance); knowledge and behavior hidden behind it;
dependencies, seams, adapters or test interactors, and their fidelity
strategy; alternatives considered and why the recommendation wins;
compatibility and incremental migration constraints; behavior tests that
should survive implementation changes; and assumptions, risks, and evidence
still needed.

Before finishing, check: is the contract simpler than the behavior it
provides; does it hide decisions rather than expose orchestration knobs; is
the common case obvious without making uncommon cases impossible; are
cohesion, ownership, failure, and runtime boundaries honest; are seams
justified by real variation or isolation needs; can callers and behavior
tests use the same stable contract; are thin edges still thin and policy-free;
does every compatibility claim have a verification path?

## References

- `rules/deep-module-principles.md` — vocabulary, depth principles, the
  inlining test, thin edges.
- `rules/contract-workflow.md` — inventory, knowledge mapping, responsibility
  before seams, routing decisions.
- `references/deepening.md`, `references/design-it-twice.md`,
  `references/source-notes.md` — deep-dive material.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When a structure, seam-finding,
characterisation-testing, TDD, testing, or refactoring skill is not installed,
apply the rule directly: separate physical placement from contract design,
introduce the minimum enabling point an untested dependency needs before
characterising legacy behavior, write the failing test before the behavior,
and keep changes behavior-preserving.
