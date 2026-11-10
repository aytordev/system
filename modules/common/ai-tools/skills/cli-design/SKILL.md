---
name: cli-design
description: "Trigger: building or reviewing a command-line tool, designing command trees, flags, or I/O contracts, implementing an output layer, or testing CLI behaviour. Language-agnostic Unix-composability rules: stdout carries data only, stderr carries everything else, semantic exit codes, --json/--plain format contracts, TTY detection, prompt bypass, config precedence, and stable output."
license: CC-BY-SA-4.0
metadata:
  author: aytordev
  version: "1.0.0"
---

# CLI Design: Unix-Composable Command-Line Interfaces

Language-agnostic CLI design principles: stream separation, exit codes, format
flags, and composability apply regardless of implementation language. This
skill adapts the CC BY-SA 4.0 [Command Line Interface Guidelines](https://clig.dev/);
provenance, modification notes, and licence scope are recorded in
`references/provenance.md`.

> "Whatever software you're building, you can be absolutely certain that people
> will use it in ways you didn't anticipate. Your software will become a part
> in a larger system — your only choice is over whether it will be a
> well-behaved part." — clig.dev

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Building any command-line tool (any language).
- Designing a command tree, flags, and I/O contracts.
- Implementing the output layer (format detection, stream routing).
- Testing CLI behaviour (stdout/stderr separation, exit codes, pipes).
- Reviewing a CLI for Unix composability.

## Core Principle

**stdout is for DATA only — the product the user asked for.**
**stderr is for EVERYTHING ELSE — diagnostics, progress, spinners, warnings,
errors.**

This separation is what makes `mycli --json | jq ...` work. One spinner
character on stdout breaks every downstream pipe.

## Hard Rules

1. **Stream separation is absolute.** Primary output goes to stdout; progress,
   warnings, errors, and debug output go to stderr — and interactive progress
   only when the stream carrying it is a TTY (`rules/streams-and-formats.md`).
2. **Keep handlers pure.** Functions that do the work return data; the CLI
   entry point is the only file that writes to a stream or ends the process.
3. **Format flags are contracts.** Default output is human-readable and
   uncontractual; `--plain` is stable and grep-friendly; `--json` emits only a
   versioned JSON envelope on stdout, and on any non-zero exit stdout stays
   empty with the structured error envelope as the final non-empty stderr
   line.
4. **Exit codes are semantic and documented** in `--help`; a non-zero exit
   code MUST have a stderr explanation (`rules/exit-codes-and-errors.md`).
5. **Every prompt is bypassable** via flags; never prompt when stdin is not a
   TTY; secrets never travel as flag values (`rules/input-config-and-secrets.md`).
6. **Resolve the output mode once**, in the entry point, before anything is
   written — format flags, colour env vars, `TERM`, `CI`, and each stream's
   TTY status (`rules/streams-and-formats.md`).
7. **stdout is a public API.** Additive changes are safe; removing or renaming
   flags, fields, or exit codes — or changing default behaviour — is breaking.
   Add alongside; deprecate with stderr warnings (`rules/stability-and-robustness.md`).
8. **Every error names its fix**: machine-readable code, what went wrong, how
   to fix it (`rules/exit-codes-and-errors.md`).

## Execution Steps

1. **Design the contract** before code: command tree, streams, format flags,
   and exit codes (`rules/streams-and-formats.md`,
   `rules/exit-codes-and-errors.md`).
2. **Shape input and configuration**: flags over positional arguments, the
   standard flag set, prompt bypass, secret handling, config precedence
   (`rules/input-config-and-secrets.md`).
3. **Design composability and help**: identifiers chaining across commands,
   `--fields`, NDJSON streaming, subcommand conventions, examples-first help
   (`rules/composability-and-help.md`).
4. **Guarantee stability and robustness**: additive evolution, transparent
   state changes, timeouts, crash-only failure
   (`rules/stability-and-robustness.md`).
5. **Implement** with the language-specific patterns in `references/`:
   result types and formatters (`references/output-architecture.md`),
   buffering and signal handling (`references/stream-contracts.md`), worked
   pipe examples (`references/composability.md`).
6. **Test** by spawning the CLI as a subprocess and asserting both streams and
   the exit code (`references/testing-cli.md`).
7. **Review** against the verification checklist in
   `rules/stability-and-robustness.md`.

## Output Contract

When reporting CLI design or review work, state which contract each decision
serves: what stdout promises (data, envelope, schema version), what stderr
carries, which exit codes mean what, and which changes would be breaking.
A review cites the checklist items that fail with the fix for each.

## References

- `rules/streams-and-formats.md` — stream contract, format flags, TTY detection.
- `rules/exit-codes-and-errors.md` — semantic exit codes and error design.
- `rules/input-config-and-secrets.md` — flags, prompts, secrets, config precedence.
- `rules/composability-and-help.md` — pipes, subcommands, help design.
- `rules/stability-and-robustness.md` — output stability, robustness, checklist.
- `references/output-architecture.md` — TypeScript result types, entry point
  wiring, formatters, logger, JSON envelope schemas.
- `references/stream-contracts.md` — Node.js buffering, NDJSON, signals,
  crash-only design.
- `references/composability.md` — worked shell examples (jq, NDJSON, stdin,
  chaining, `--fields`, parallel `xargs`).
- `references/testing-cli.md` — Vitest subprocess tests for CLI contracts.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When an API-design skill is not installed,
apply the rule directly: any observably consumed interface gains de-facto
contracts (Hyrum's Law) — treat the stdout shape exactly like an HTTP API
surface. When a twelve-factor skill is not installed, apply its CLI-relevant
rules directly: config lives in the environment with a documented precedence
order, and shutdown must be graceful on SIGTERM/SIGINT. The mapping to
hexagonal architecture is direct — the CLI entry point is a driving adapter and
the handler is a use case returning a result through a port — but hexagonal
architecture is not required to benefit from keeping handlers pure.
