## Execute Tests and Build

**Impact: CRITICAL**

Step 4: Execute the applicable per-unit checks and build surfaces to verify
runtime correctness. Real execution, not just static analysis.

### Resolve Applicable Checks

Read the cached testing capabilities and select the checks that cover the
changed units:

1. Determine the project root of each changed file (longest matching root).
2. Select the `runtime` commands whose covered targets include that root, plus
   any `covers_workspace: true` runtime command.
3. Collect `nix-eval` and `nix-build` commands separately for the root.

Never run a sibling root's runner or a single global command as if it covered
the workspace.

### Execute Runtime Checks

For each applicable `runtime` command, run it in its working directory and
capture:

- **Working directory** and **command**
- **Total tests**
- **Passed tests**
- **Failed tests**
- **Skipped tests**
- **Exit code**
- **Candidate revision** the command ran against (commit hash or content hash)

If the candidate changes after a command ran, that result is stale and must be
re-run before it can support a PASS.

### Execute Nix Surfaces Separately

`nix-eval` and `nix-build` are distinct surfaces and must not be labelled a unit
suite:

- **`nix-eval`** — run `nix flake check` (or the root's eval-level checks).
  Report pass/fail and the checks it evaluated.
- **`nix-build`** — run `nix build` for the affected derivation(s). Report the
  build result. A successful build does not prove runtime tests ran.

### Severity Assignment

- **CRITICAL** if any applicable runtime check or `nix-build` fails (exit code != 0)
- **CRITICAL** if an explicitly requested Strict TDD mode is `blocked` (missing
  prerequisite coverage) — report the blocker, do not invent evidence
- **PASS** if all applicable checks and builds pass

### Coverage Check (Optional)

Only run coverage if `rules.verify.coverage_threshold` is configured in
`config.yaml`. Run it through the unit's own runtime command. **WARNING** (not
CRITICAL) if coverage < threshold.

### Output

Return a summary grouped by root and surface, with the candidate revision:

```
Candidate revision: {hash}

### Runtime Checks
| Root | Command | Result | Exit | Revision |
|------|---------|--------|------|----------|
| packages/core | npm test | 12/12 passed | 0 | {hash} |

### Nix Surfaces
| Root | Surface | Command | Result | Revision |
|------|---------|---------|--------|----------|
| . | nix-eval | nix flake check | pass | {hash} |
| . | nix-build | nix build | pass | {hash} |

Verdict: CRITICAL | WARNING | PASS
```
