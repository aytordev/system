---
title: Check Scope Fidelity Every Round
impact: CRITICAL
impactDescription: Catches silently dropped features and smuggled additions
tags: double-check, scope, fidelity
---

## Check Scope Fidelity Every Round

**Impact: CRITICAL**

Every review must compare the finished work against the original scope, not
just judge the changed code on its own merits. Correct-looking work that
silently drops a requested feature or smuggles in an unrequested one is a
defect. The reviewer must affirmatively check, and report the outcome of, all
three:

1. **Unrequested additions** — features, behaviors, endpoints, options,
   dependencies, or configuration present in the work but absent from the
   original scope. Report each one; the author must justify or remove it. Do
   not assume extra work is a bonus.
2. **Unrequested removals** — features, behaviors, error handling, or
   guarantees that existed before or were required by the scope and are now
   gone or weakened without the scope asking for it.
3. **Removed or weakened tests** — enumerate every test that the work deletes,
   skips, or whose assertions it loosens. Diff the test files directly; do not
   rely on the author's summary. Inspect each one and judge whether the
   removal or update is required by the original scope. A test deleted or
   weakened to make an unrequested behavior change pass silently is a
   `blocker`, because it removes the guardrail that was keeping the requested
   behavior in place.

These checks are mandatory in every round, not optional extras. A response
that omits them is incomplete, and `VERDICT: no-issues` is invalid without an
explicit clean result on all three. If the brief does not state the original
scope well enough to run them, the reviewer must say so as a finding rather
than guessing.

### The refactor carve-out

Behavior-preserving refactoring is not scope drift. Refactoring the code the
work touches is an expected part of finished work even when nobody asked for
it; judge a refactor on whether it is justified and genuinely preserves
behavior, never on whether the scope requested it. A claimed refactor that
changes observable behavior is not a refactor — judge it under the addition
and removal checks above.

The reviewer should also look the other way: flag valuable refactoring
opportunities the work missed in the code it touched — duplication left in
place, unclear names, tangled structure — normally as `minor` or `nit`
findings, judged by whether they would genuinely simplify the touched code.

### Relation to acceptance proof

Scope fidelity is not a substitute for a criterion-by-criterion acceptance
review: that pass proves each criterion of the contract is satisfied, while
these checks catch what lies outside the contract — additions and removals no
criterion ever mentions. When an authoritative requirements artifact exists
and the work is finished implementation approaching a PR, run both as part of
the same pre-PR gate and report the verdicts separately, never merged.
