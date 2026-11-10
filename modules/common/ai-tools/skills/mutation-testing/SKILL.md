---
name: mutation-testing
description: "Trigger: verifying whether tests actually catch bugs, running or setting up mutation testing with Stryker, or triaging surviving mutants at PR readiness. Scopes runs to the branch diff, classifies every survivor, and strengthens tests only where the evidence earns it."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Mutation Testing

Mutation testing answers one question: **would my tests catch a bug here?**
Coverage says what the tests execute; mutation testing says what they would
detect. Full line coverage alone proves nothing about assertions.

`rules/` is bundled with this skill. Repository scripts and runner configuration
refer to the target repository.

## Activation Contract

Use this skill when:

- A phase of work is complete and ready to become a PR.
- Reviewing a branch for test effectiveness after TDD and refactoring.
- Weak tests appear to have coverage, or edge cases look missing.
- The user asks for mutation testing, Stryker, a mutation score, or survivor
  analysis.

Do not use it inside each RED-GREEN increment. Its cost grows with the codebase
and it degrades the short feedback loop that TDD depends on.

## Hard Rules

1. **One gate per phase.** Baseline run, focused reruns, one closing verification —
   nothing in between the increments.
2. **Prove the harness works with a scoped smoke run** before spending the
   baseline. A crashed run has still spent its slot.
3. **Never re-run to re-read output.** Capture the baseline report once and triage
   from the copy.
4. **Classify every survivor** as killed, `No coverage`, `Equivalent` with its
   one-line argument, or an explicitly deferred judgement call. Listing survivors
   without classification is not a triaged report.
5. **Ask before treating an ambiguous survivor as a defect** — intentionally
   unspecified behaviour and uncertain equivalence are human decisions.
6. **Diff runs require a clean tree.** `base...HEAD` excludes staged, unstaged,
   and untracked work; never silently commit or stash to make the scope look
   complete.

## The Process

1. **Baseline** — one run over the accumulated branch or PR scope. Capture the
   report to a file.
2. **Triage** — ask the equivalence question of each survivor first; then decide
   kill or defer.
3. **Kill** — for each survivor worth killing: keep the mutant, write the smallest
   behaviour test that fails against it, restore the code, verify the test passes,
   re-run scoped to the file or line range.
4. **Close** — at most one final full run, then the repository's remaining PR
   verification.

## Output Contract

State the report in one line: `Mutation: ran, X killed / Y survived (score Z%)`
with the survivor classification, or `Mutation: N/A — <rationale>; alternate
evidence: <what>`. For survivors, name the file, the mutation, the category, and
the smallest test that would kill it — or the argument for why it is equivalent.

## References

- `rules/stryker-setup.md` — inspection, installation authority, configuration, scripts.
- `rules/triage-and-diff.md` — survivor categories, the kill loop, diff scoping.
- `references/provenance.md` — upstream source, revision, and licence notice.

When no harness can target the code, apply the mutator shapes manually — operator
changes, boundary shifts, boolean inversions, removed statements, changed return
values — and revert each one before the next. The classification discipline does
not relax.
