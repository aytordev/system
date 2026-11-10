---
title: Choose the Green and Gate Scope
impact: HIGH
impactDescription: Prevents hand-picked green scopes and watch results passed off as gates
tags: testing, execution, gate
---

## Choose the Green and Gate Scope

**Impact: HIGH**

Preference order for GREEN and REFACTOR:

1. A tested repository-owned watch or affected command.
2. Native VCS-aware selection, when the installed runner and configuration have
   proven its watch behaviour.
3. Native dependency-aware selection from a complete, mechanically derived
   changed-source list.
4. Runner- or orchestrator-selected affected projects, including transitive
   dependents.
5. Exact test file or name — for RED or debugging only, then a broader scope.

| Runner | Affected scope for GREEN | RED/debug-only selector |
| --- | --- | --- |
| Vitest | Repository watcher first; otherwise diff-selected watch only under proven conditions, or `--run` for one-shot | `vitest run <file> -t <name>` |
| Jest | `--watch`, adding `--changedSince=<base>` across commits; one-shot `--onlyChanged`, `--changedSince`, or `--findRelatedTests` | `--runTestsByPath <file> -t <name>` |
| pytest | Existing repository affected task; otherwise the owning suite plus known consumers | `pytest path::test_name` |
| Playwright | Repository script, or `--only-changed[=<base>]`, or a mechanically derived project set | `--grep`, `--last-failed`, or a single project to prove RED |
| Go / Rust / JVM | Existing affected task or dependency-graph package set | Exact package/class/test selector |

### Rules that decide the scope

- Do not mistake "changed test files" for "all relevant tests": the target is the
  tests affected by the changed behaviour.
- If the runner has no dependency graph, use its exact selector only for RED or
  debugging, then run the behaviour test plus every known consumer and the owning
  suite, widening when impact is uncertain.
- A runner that permits an empty selection to pass (`related`, `--passWithNoTests`)
  requires proof that at least one expected test executed.
- Newly created test files must join the loop; a frozen test-file list at watcher
  startup is a defect.

### The gate

Watch mode is an inner-loop accelerator, never the PR gate. Before review:

1. Stop the watcher and its children.
2. Run the repository's complete non-watch command for the final tree.
3. In a monorepo, include every configured project and the required integration
   and end-to-end suites.
4. If verification changes production code or applicable tests afterwards, rerun
   what it invalidated.
