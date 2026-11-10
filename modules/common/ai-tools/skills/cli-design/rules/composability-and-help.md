---
title: Design for Real Pipes and Readable Help
impact: HIGH
impactDescription: Chains commands and gets users unstuck fast
tags: cli-design, composability, subcommands, help
---

## Design for Real Pipes and Readable Help

**Impact: HIGH**

### Composability patterns

Design for real-world pipes: filtering with `jq`, streaming NDJSON
line-by-line, feeding stdin, chaining commands through emitted identifiers,
selecting columns with `--fields`, and fanning out with `xargs -P`.

Key patterns:

- Create commands output identifiers so subsequent commands can chain.
- List commands support `--fields` for column selection (reduces output size,
  critical for agent efficiency).
- `--quiet` for CI scripts that only care about the exit code.
- NDJSON for streaming large datasets without buffering everything in memory.
- `--dry-run` with `--json` outputs planned changes as structured data.

Worked shell examples covering each pattern are in
`references/composability.md`.

### Subcommand design

- **noun verb** pattern is most common: `mycli config set`, `mycli report
  generate`.
- Be consistent across all subcommands — same flag names for same things.
- No ambiguous pairs (`update` vs `upgrade` is confusing).
- No catch-all subcommands (you can never add subcommands with conflicting
  names).
- No arbitrary abbreviations — aliases must be explicit and stable.
- With no args: list subcommands (multi-command CLI) or show help
  (single-command CLI).

### Help

- `mycli --help` — top-level help.
- `mycli help <subcommand>` and `mycli <subcommand> --help` — subcommand help.
- With missing required args: show concise help + 1-2 examples + "use --help
  for more".
- **Examples are the most-read section** — lead with them.
- Include flag types, defaults, and allowed values for finite sets.
- Include a support/bug-report link in top-level help; pre-populate issue URLs
  with diagnostics where possible.
- Suggest the likely command on obvious typos ("Did you mean 'deploy'?") —
  ask, never auto-execute.

### Naming, distribution, telemetry

- **Name**: short, memorable, lowercase, easy to type; not so generic it
  collides with existing commands.
- **Distribution**: prefer a single binary; language-ecosystem tools (npm,
  pip) may reasonably assume their interpreter. Make uninstalling easy and
  documented.
- **Telemetry**: never collect usage/crash data without explicit consent —
  opt-in, stating what, why, and retention. Instrumented web docs or download
  counts are usually enough.
