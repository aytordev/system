---
title: Keep Data and Diagnostics on Different Streams
impact: CRITICAL
impactDescription: Preserves pipes and machine consumption
tags: cli-design, streams, formats, tty
---

## Keep Data and Diagnostics on Different Streams

**Impact: CRITICAL**

### The Unix stream contract

| Content | Stream | Why |
|---------|--------|-----|
| Primary output (data, results, JSON) | stdout | Pipeable, buffered for throughput |
| Progress bars, spinners, status | stderr, and only when stderr is a TTY | Not data — a pipe consumer never wants a spinner |
| Warnings, errors, diagnostics | stderr | Visible to the user even when stdout is piped |
| Debug/verbose output | stderr | Diagnostic, never data |

Stream behaviour:

- Check stdout and stderr independently; stdout being piped does not mean
  stderr is piped.
- Do not assume C stdio's line/block/unbuffered rules describe every language
  runtime; in Node.js, sync/async process-stream behaviour varies by operating
  system and destination — always respect `.write()` backpressure for
  high-volume output (`references/stream-contracts.md`).

### Format flag contract

Three-tier output hierarchy:

- **Default: human-readable.** Colors, tables, formatted text; progress on
  stderr; tailored to terminal width. May change between versions — not a
  contract.
- **`--plain`: grep/awk-friendly.** One record per line, no formatting, no
  colors, flat rows without borders. Stable between minor versions — this *is*
  a contract. Enables `mycli list --plain | grep error | wc -l`.
- **`--json`: structured data.** On success, stdout contains ONLY valid JSON —
  no spinners, no color, no progress. On **any** non-zero exit, stdout stays
  empty and the final non-empty stderr line is the structured JSON error
  envelope. That includes a domain failure (exit 1) where the run completed
  and the numbers exist — an unmet threshold, gate, or budget is a failure,
  not a success envelope carrying a `false` flag. If the caller still needs
  the figures, put them inside `error` (a `details` field), never on stdout.
  Consumers parse the final non-empty line rather than the whole diagnostic
  stream. Schema is versioned. `--json` implies non-interactive regardless of
  TTY.

Consistent envelopes — the envelope is not optional and renames nothing; a
list of records goes inside `data` rather than replacing the envelope with a
bare array:

```json
{ "ok": true, "data": { ... } }
```

```json
{ "ok": false, "error": { "code": "CONFIG_MISSING", "message": "...", "fix": "..." } }
```

### NDJSON for streaming

For large datasets, use NDJSON (one JSON text per record, terminated by `\n`):

- Each line is independently parseable.
- Any JSON value is valid NDJSON syntax; the application's decoder owns its
  schema.
- Document whether readers ignore or reject empty lines.
- Enables `mycli run --format ndjson | while read -r line; do ...; done`.

Specification details: `references/stream-contracts.md`.

### TTY detection

Check priority order (first match wins):

| Priority | Condition | Effect |
|----------|-----------|--------|
| 1 | `--format json` or `--json` flag | Non-interactive, no color, no animation |
| 2 | `--no-color` flag | Disable color (output may still be interactive) |
| 3 | `FORCE_COLOR` env | Empty, `1`, `2`, `3`, or `true` enables color; every other value (including `0`) disables it. Overrides `NO_COLOR` and `NODE_DISABLE_COLORS` |
| 4 | `NO_COLOR` (non-empty) or `NODE_DISABLE_COLORS` (defined), `FORCE_COLOR` unset | Disable color |
| 5 | `TERM=dumb` | Disable color and animations |
| 6 | `CI=true` | No interactive prompts |
| 7 | stdout is not a TTY | Plain output, no animations on stdout |
| 8 | Default | Full interactive with colors |

- **Resolve the output mode once, in the entry point, before anything is
  written.** Walk the table into a single mode value and pass it to the
  formatters. Write that check even when today's output has no color and no
  animation yet.
- **Check stdout and stderr independently.** When stdout is piped but stderr
  is a TTY, show spinners on stderr while keeping stdout clean.
- **Gate prompts on stdin independently**: prompt only when stdin and the
  prompt's output stream are TTYs.
- Optionally support `MYCLI_NO_COLOR` for app-specific color override.
