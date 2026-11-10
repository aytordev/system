---
title: Treat stdout as a Public API
impact: CRITICAL
impactDescription: Prevents breaking every script that consumes the tool
tags: cli-design, stability, robustness, checklist
---

## Treat stdout as a Public API

**Impact: CRITICAL**

Breaking changes to stdout format are breaking changes to the CLI.

| Change | Impact |
|--------|--------|
| Adding new optional JSON fields | Safe (additive) |
| Adding new subcommands | Safe |
| Adding new flags that preserve defaults | Safe |
| Removing or renaming flags | **Breaking** |
| Removing or renaming JSON fields | **Breaking** |
| Changing exit codes | **Breaking** |
| Changing default behavior | **Breaking** |
| Changing human-readable output | Usually OK (not a contract) |

When in doubt, add alongside — don't modify. Deprecate with stderr warnings
before removing — and once you can detect that users have migrated, stop
warning.

### State changes and transparency

- **Confirm state changes** — say what changed and show (or point to) the
  resulting state; traditionally-silent commands look broken to humans.
- **Make current state easy to see** — a `status`-style command for anything
  with complex state (the `git status` pattern).
- **Make hidden actions explicit** — if you read/write files not passed as
  arguments or talk to remote servers, say so (stderr in human mode).
- **Resolve ambiguous mutations** — if transport fails after dispatch, tell
  the user how to inspect or reconcile state; do not label the result
  retry-safe.
- **Page long output** through `$PAGER` only when stdout is a TTY, never when
  piped; do not execute the value through a shell, and document whether it is
  an executable token or parsed by a reviewed shell-word parser.

### Robustness

- **Validate input early** — fail before any side effects, with a clear
  message.
- **Responsiveness for ongoing human work** — in interactive human mode,
  unless `--quiet`, show progress on stderr if an operation is still running
  after roughly 100ms; keep machine modes quiet unless their protocol
  explicitly defines progress, and include time estimates when interactive
  progress can stall.
- **Timeouts on all network operations** — configurable; use exit 75 only
  before dispatch or when retry safety/idempotency is established.
- **Recoverable operations** — re-running may resume only when safe; ambiguous
  mutation outcomes need an explicit status or reconciliation path.
- **Crash-only design** — exit fast on failure, defer cleanup to the next run;
  distinguish visibility-atomic replacement from crash-durable persistence,
  and keep bounded-cleanup timers referenced so Ctrl-C cannot bypass the bound
  (`references/stream-contracts.md`).
- **Expect misuse** — script wrapping, bad connections, concurrent instances,
  environments you never tested.

### Anti-patterns

| # | Anti-Pattern | Why It's Wrong |
|---|-------------|----------------|
| 1 | Mixing data and diagnostics on stdout | Breaks every pipe |
| 2 | Colors/ANSI in piped output | Corrupts downstream parsing; check `isatty(stdout)` + `NO_COLOR` |
| 3 | Interactive prompts with no flag bypass | Agents can't type 'y'; non-TTY without bypass = hang |
| 4 | Printing nothing on success | Silence is ambiguous — show brief confirmation; offer `-q` |
| 5 | Designing for humans OR machines, not both | Detect context (TTY vs pipe), adapt automatically |
| 6 | Output that doesn't guide the next action | Success = next command, failure = fix command |
| 7 | Breaking existing CLI contracts | Add alongside, never modify |
| 8 | `console.log` anywhere except the CLI adapter | Handlers return data; only the presentation layer writes |
| 9 | Handlers that exit the process directly | Let the entry point decide |
| 10 | Non-zero exit without stderr explanation | Scripts need both the code and the reason |
| 11 | Verbose default output | Support `--fields`, `--quiet`, `--json` |

### Verification checklist

After designing or reviewing a CLI:

- [ ] stdout has ONLY data; stderr has everything else.
- [ ] Every command supports `--json` with success data on stdout and
      structured failures on stderr.
- [ ] Exit codes are semantic and documented in `--help`.
- [ ] Every prompt has a `--yes`/`--force`/`--flag` bypass.
- [ ] Errors include: code, message, fix suggestion.
- [ ] `--dry-run` available for mutating commands.
- [ ] Progress/spinners go to stderr, never stdout.
- [ ] `NO_COLOR`, `TERM=dumb`, and `--no-color` respected.
- [ ] Piped output contains zero ANSI escape codes.
- [ ] Success output includes next-action guidance.
- [ ] Existing flags, exit codes, output fields never removed or renamed.
- [ ] JSON schema is versioned (additions safe, removals breaking).
- [ ] Config follows flags > env > project > user > defaults.
- [ ] Secrets never via flags; keychain/credential-file/stdin preferred, env
      only when platform-injected (CI).
- [ ] Severe destructive actions require typed confirmation, not just y/N.
- [ ] Network operations have configurable timeouts; exit 75 is reserved for
      pre-dispatch or demonstrably retry-safe failures.
- [ ] Interactive human operations still running after roughly 100ms show
      progress on stderr unless `--quiet`; machine-mode protocols stay clean.
- [ ] Ctrl-C exits fast with bounded cleanup.
- [ ] `--help` includes 2-3 realistic examples.
- [ ] Human output is grep-parseable (flat rows, no table borders).

### Format hierarchy quick reference

```
Default (TTY)     → colors, tables, formatted text
--plain           → one record per line, stable, grep-friendly
--json            → structured JSON, versioned schema
--format ndjson   → streaming, one JSON object per line
```
