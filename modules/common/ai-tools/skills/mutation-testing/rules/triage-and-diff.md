---
title: Triage Survivors and Scope the Diff
impact: CRITICAL
impactDescription: Turns a report into decisions instead of a number
tags: mutation, triage, diff
---

## Triage Survivors and Scope the Diff

**Impact: CRITICAL**

### Categories

| Category | Description | Action |
| --- | --- | --- |
| Killed | A test failed with the mutant active | None |
| Survived | Tests passed with the mutant active | Strengthen the test, unless equivalent |
| No coverage | No test exercises the code | Add a behaviour test |
| Equivalent | Mutant produces identical behaviour | None; record the argument |

### The equivalence question comes first

For each survivor: is there any input for which this mutant returns a different
value, persists different state, or emits a different message? If none exists it
is `Equivalent` — a guard whose removal leaves the same result, an identity such
as `+ 0` or `* 1`, a redundant early return, an unreachable branch. No test can
kill it; record the one-line argument.

Only survivors that outlive that question are candidates to kill or defer. Run the
equivalence pass even when you have killed nothing yet: offering to kill every
survivor asserts that none is equivalent, and that is a claim to check survivor by
survivor.

### Kill with a failing test

1. Keep or recreate the mutant.
2. Write the smallest behaviour test that fails against it, for the right reason.
3. Restore the production code.
4. Verify the new test passes.
5. Re-run scoped to the mutated file or line range, then re-run the diff command.

Fix obvious gaps directly: missing boundary tests, weak or absent assertions,
one-sided branch coverage, missing side-effect verification, and high-value rules
such as money, permissions, eligibility, safety, or data loss. Ask the human when
the correct rule is genuinely unclear.

Do not overfit. Strong mutation tests assert observable behaviour — return values,
persisted state, emitted events, permissions, messages, or collaborator calls the
caller supplied.

### The diff script

`mutation:diff <base>` must:

- Default the base to the repository's detected default branch.
- Refuse to run when `git status --porcelain` is non-empty, explaining that
  `base...HEAD` excludes staged, unstaged, and untracked work.
- Collect changed files with
  `git diff --name-only -z --diff-filter=ACMRTUXB <base>...HEAD` and parse
  NUL-delimited records; filenames may contain whitespace or newlines.
- Keep changed production files matching the project's source extensions and drop
  tests, fixtures, snapshots, generated files, declarations, and build output.
- Invoke the repository-local binary without a shell. If `--mutate` takes
  comma-separated patterns, reject a candidate filename containing a comma with a
  clear message rather than silently changing the scope.
- Exit clearly when there is nothing to mutate.

For a tiny follow-up, use an exact range:

```bash
pnpm exec stryker run --incremental --force --mutate src/example.ts:42-57
```

Use the repository's actual package manager and a pinned version; an execution
command must not silently download a moving release.

### CI posture

Start report-only or diff-only when the suite has many survivors. Add failing
thresholds only after a baseline exists, persist reports as artifacts, and treat
the score as a signal rather than a vanity metric: prioritize survivors and
uncovered mutants in changed and high-risk code.
