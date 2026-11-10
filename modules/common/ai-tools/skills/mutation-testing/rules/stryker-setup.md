---
title: Set Up and Scope the Harness
impact: HIGH
impactDescription: Makes mutation runs affordable and honest about their scope
tags: mutation, stryker, configuration
---

## Set Up and Scope the Harness

**Impact: HIGH**

Use an automated harness first; for JavaScript and TypeScript, Stryker is the
starting point. Manual mutations are the fallback, a teaching aid, or a focused
follow-up.

### Inspect before changing anything

```bash
rg --files | rg '(^|/)(package.json|stryker\.config\.(mjs|cjs|js|json)|stryker\.conf\.(js|json))$'
git status --porcelain
git diff <review-base>...HEAD --name-only
```

Identify the package manager, runner, affected packages, and any existing
configuration. Use the real review boundary: the default branch for a single PR,
the parent branch for a stacked layer. In a monorepo, start in the smallest
affected package and widen once that run is healthy.

### Installing is a repository change

Select exact compatible Stryker versions from official documentation and the
project's runtime constraints, and obtain the same authorization any other
dependency change needs before adding it. Then initialize with the repository's
package manager and inspect the generated config.

### Configuration that earns its keep

- Prefer the project's own runner plugin; use the generic command runner only when
  no tighter integration is practical.
- Mutate first-party production source only. Exclude tests, fixtures, snapshots,
  generated files, declaration files, build output, migrations, and low-signal
  barrels.
- For TypeScript, add the TypeScript checker so type-invalid mutants cost a
  compile error instead of a test run.
- Write **no** `thresholds.break` in a first setup. With no measured baseline any
  value either breaks the build on day one or is decoration. Report the first
  score, then propose a threshold.
- Add `.gitignore` entries for the temp and report output so a run leaves no
  untracked artefacts behind.

### Three scripts, not one

```json
{
  "scripts": {
    "mutation": "stryker run",
    "mutation:incremental": "stryker run --incremental",
    "mutation:diff": "node scripts/stryker-diff.mjs <review-base>"
  }
}
```

The cached script is what makes the scoped reruns of the gate affordable. A small
Node helper, never dense shell in `package.json`: command substitution cannot
preserve NUL-delimited paths, and quoting `*`, `!`, commas, and newlines is
fragile across shells.

### Prove it before you spend the budget

The first invocation after writing a config is a scoped smoke run over one small
file — seconds, not minutes — which surfaces a missing runner plugin, an unreadable
sandbox path, or a blocked port before any mutant is measured. Count attempts, not
results.

The gate gets at most two whole-project runs: one baseline, one closing
verification. Everything else is scoped by file, line range, `--incremental`, or
the diff script — including rechecking a config edit.
