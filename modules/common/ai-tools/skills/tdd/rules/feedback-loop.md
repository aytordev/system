---
title: Keep the Feedback Loop Fast and Bounded
impact: CRITICAL
impactDescription: Prevents slow loops, false evidence, and leaked watchers
tags: tdd, watchers, monorepo
---

## Keep the Feedback Loop Fast and Bounded

**Impact: CRITICAL**

The inner loop must optimize for fast, relevant feedback. Before RED, inspect the
project's scripts, test configuration, and runner help: repository-owned commands
take precedence over the examples here.

### Preference order

1. A tested repository-owned watch or affected command.
2. Native VCS-aware selection, when the installed runner and configuration have
   proven its watch behaviour.
3. Native dependency-aware selection from a complete, mechanically derived
   changed-source list.
4. Runner- or orchestrator-selected affected projects, including transitive
   dependents.
5. An exact test file or name — for proving RED or debugging only, followed by a
   broader affected scope for GREEN.

### Representative commands

```bash
# Repository-owned graph-complete watch, when defined and proven
pnpm test:watch

# Diff-selected initial execution (only after repository-level proof)
pnpm exec vitest --changed origin/main --watch
pnpm exec vitest related --run src/example.ts
pnpm exec jest --watch --changedSince=origin/main
pnpm exec jest --findRelatedTests src/example.ts --watch=false

# Exact selector: RED/debug only
pnpm exec vitest run tests/example.test.ts -t "rejects empty names"
pnpm exec jest --runTestsByPath tests/example.test.ts -t "rejects empty names"
```

### Watcher lifecycle and automation safety

- One watcher, in a dedicated reusable terminal or session, reused for the loop.
- Stop it with `Ctrl+C` before gates or handoff. No background watchers left
  behind.
- When automation spawns one, timeout and signal cleanup must terminate the whole
  watcher process group and remove temporary directories.
- Never invoke a watch command from CI, Git hooks, or another script intended to
  terminate. A command mixing a watch flag with a finite marker is still watch
  mode.
- A stale waiting marker, zero collected tests, or `--passWithNoTests` is not
  evidence. Observe output emitted after the relevant rerun.

### Monorepos

Run changed or affected selection from the repository root through the
project-defined command or orchestrator that owns the complete workspace graph. A
shared-package edit can affect several consumers; do not `cd` into one package or
filter by project based only on the edited file.

Confirm the root configuration enumerates every relevant project and that
cross-package imports are graph-visible. Filesystem reads, subprocess targets,
generated output, templates, file-scanning guards, browser-mode tests, and
container-backed tiers may need repository-specific triggers or separate commands.
Preserve configured trigger patterns and rerun triggers.

Watch mode is an inner-loop accelerator, never PR evidence.
