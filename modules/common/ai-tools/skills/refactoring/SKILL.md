---
name: refactoring
description: "Trigger: a request to clean up, tidy, simplify, restructure, deduplicate, collapse, or merge look-alike code, or the refactor step after a passing baseline. Requires a recoverable baseline, a labelled Critical/High/Nice/Skip assessment, and a behaviour-preserving change with proportionate preservation evidence."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Refactoring

Refactoring improves structure without changing behaviour. It is the last step
of a red-green-refactor increment, assessed only after the tests establish a
passing baseline.

Do not run a mutation harness before or after each refactor. Mutation testing
verifies the accumulated result once the phase is otherwise ready for review.
Because that evidence is deferred, keep each refactor small, strictly
behaviour-preserving, and green under the existing oracles.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The user asks to clean up, tidy, simplify, restructure, deduplicate, collapse,
  or merge look-alike code in a selected area.
- A red-green cycle just reached GREEN and restructuring is applicable.
- A refactor was proposed and needs assessment before any edit.

Do not use it for insufficiently evidenced code, for adding behaviour, or for a
whole-path reduction program. A selected whole-path reduction has its own
governing ledger: create or use the project's reduction plan, and treat this
skill as secondary when it applies.

## Hard Rules

1. **No baseline, no refactor.** Establish a verified, recoverable baseline
   first: applicable tests pass, or the conserved behaviour has proportionate
   evidence. If the baseline cannot be restored without creating a commit, stop
   and ask for approval rather than committing implicitly.
2. **Assess before the first edit.** Run the applicable tests yourself, list
   every candidate change, and label each one Critical, High, Nice, or Skip.
3. **The assessment is part of the answer.** The final reply carries the
   labelled list, Skip items included, one line per candidate, closed by a
   `Decision:` line. A summary of what changed is not an assessment.
4. **Behaviour preservation is the contract.** No new behaviour, no speculative
   abstraction, no behaviour change disguised as cleanup.
5. **Commits need explicit approval**, and refactoring commits stay separate
   from feature commits.
6. **Extract for readability or shared knowledge, never for testability alone.**
   The consuming behaviour already has tests.

## Execution Steps

1. **BASELINE** — run the applicable tests; record what proves the behaviour.
2. **CHECKPOINT** — record the baseline and preservation evidence. Create a
   baseline commit only with explicit approval.
3. **ASSESS** — enumerate candidates, label each one, and state the decision.
4. **REFACTOR** — small steps, behaviour-preserving, under the project's fast
   feedback policy.
5. **VERIFY** — focused and affected tests stay green after each step; do not
   rerun the whole suite after every edit.
6. **PR GATE** — when the phase is ready for review, verify the accumulated
   result once (mutation evidence where meaningful, otherwise explicit `N/A`
   plus proportionate alternate evidence).

## Output Contract

Present the verified change, the labelled `Critical:`/`High:`/`Nice:`/`Skip:`
lines, and the closing `Decision:` line. When every candidate is Skip, say so in
those words and change nothing — after running the tests, because a refusal is
still an assessment.

## References

- `rules/assessment-and-reply.md` — priority classes and the reply shape.
- `rules/baseline-and-preservation.md` — baseline, checkpoints, verification cadence.
- `rules/dry-knowledge.md` — when duplication is shared knowledge and when it is not.
- `rules/boundaries.md` — when not to refactor, new-behaviour evidence, commit format.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When an architecture-discovery, module-design,
TDD, characterisation-testing, or mutation-testing skill is not installed, apply
the rule directly: discover and rank candidates before designing, write the
failing test before the behaviour, capture legacy behaviour before changing it,
and verify the accumulated result before review.
