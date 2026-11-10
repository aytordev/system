---
name: tdd
description: "Trigger: adding, implementing, or fixing production behaviour, including a one-line fix or a named-file change. Runs RED-GREEN-REFACTOR with a fast feedback loop, records RED/GREEN/final-run evidence, and closes with one mutation or alternate-evidence gate at PR readiness."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Test-Driven Development

TDD is the practice for new or changed observable behaviour: every such change is
written in response to a failing behaviour test. A small fix still starts from a
failing test, not from an edit.

Pure behaviour-preserving work is different. It begins from passing proportionate
evidence and stays green while structure changes; it never fabricates a failing
test or a structural mutant to look RED. If the work changes behaviour or settles
a disputed bug, return to RED.

In this skill a **phase** is one PR-sized, independently mergeable slice — the
accumulated scope of one branch and its PR.

`rules/` is bundled with this skill. Repository commands and configuration always
override the generic examples below.

## Activation Contract

Use this skill when:

- Implementing a feature, a fix, or any changed observable behaviour.
- A request calls the change trivial, a one-liner, or confined to one file.
- Mixed implementation work needs a governing workflow.

Do not use it for pure refactoring or mechanism reduction, or for a plan-only
request.

## Hard Rules

1. **No production code before a failing behaviour test** for new or changed
   behaviour. The test must fail for the right reason.
2. **Never run the full suite after every edit.** Use the narrowest selector that
   demonstrates RED, then the runner-derived affected scope for GREEN and
   REFACTOR.
3. **Never leave a watcher behind.** Stop it before PR gates or handoff, and
   terminate its whole process group when automation owns it.
4. **Watch mode is not PR evidence.** The pre-PR record comes from a completed
   non-watch run against the final tree.
5. **One mutation gate per phase**, not per increment. Record its outcome in the
   final reply; an unstated gate is an unrecorded gate.
6. **Name the evidence.** RED, GREEN, and the final non-watch run are stated by
   selector and observed failure, not as test counts.

## Execution Steps

1. **Honour the repository start point.** If it requires a proven watcher before
   the first edit, start it once; otherwise write RED first and start the watcher
   immediately afterwards.
2. **RED** — add the behaviour test, run the narrowest selector, confirm the
   expected failure.
3. **GREEN** — write only enough code to pass. Faking it is legitimate: hardcode,
   then triangulate with a second case that forces the real implementation.
4. **REFACTOR** — assess with the passing tests as the safety net; apply the
   project's refactoring rule only where restructuring is valuable, otherwise
   record `N/A`.
5. **Repeat** until the PR scope is complete, without running the mutation
   harness in between.
6. **PR gate** — stop watchers, verify the accumulated result once (mutation
   evidence or explicit `N/A` plus proportionate alternate evidence), then run the
   repository's complete non-watch gate.

## Output Contract

Report: the RED selector and the failure it produced, the GREEN selector, the
completed non-watch run, and one mutation line — `Mutation: ran, X killed / Y
survived (score Z%)`, `Mutation: N/A — <rationale>; alternate evidence: <what>`,
or `Mutation: deferred to the PR gate — this slice is not yet PR-ready`.

## References

- `rules/feedback-loop.md` — selectors, watcher lifecycle, monorepos.
- `rules/evidence-and-gates.md` — evidence record, mutation gate, PR checklist.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When a testing, mutation-testing, or refactoring
skill is not installed, apply the rule directly: test behaviour through the
public interface, scan for boundaries the tests would not kill, and keep the
existing tests green while structure changes.
