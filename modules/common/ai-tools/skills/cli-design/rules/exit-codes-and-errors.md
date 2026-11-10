---
title: Make Exit Codes and Errors Semantic
impact: CRITICAL
impactDescription: Lets scripts distinguish failures and users recover
tags: cli-design, exit-codes, errors
---

## Make Exit Codes and Errors Semantic

**Impact: CRITICAL**

### Exit codes

| Code | Meaning | When |
|------|---------|------|
| 0 | Success | Operation completed as expected |
| 1 | Domain failure | Tool-specific failure (e.g. quality threshold not met) |
| 2 | Invalid usage | Bad flags, missing required args, validation error |
| 78 | Configuration error | Invalid config file, missing required config |
| 75 | Temporary, retry-safe failure | Failure occurred before dispatch, or the operation is documented and demonstrably safe to retry |
| 130 | SIGINT | User pressed Ctrl-C (128 + 2) |
| 143 | SIGTERM-style status | Optional documented status when preserving signal termination (128 + 15); a handled graceful shutdown may instead return 0 |

Rules:

- Non-zero exit code **MUST** have a stderr explanation.
- Document exit codes in `--help`.
- Never use codes above 125 for application errors (reserved for signals).
- Use exit 75 only when no mutation was dispatched or retry safety is
  established through idempotency/reconciliation; a merely transient cause is
  not enough.
- If a mutating request may have reached its destination, report an ambiguous
  outcome and direct the user to `status`/reconcile instead of inviting a
  blind retry.
- A handled SIGTERM may finish with 0 or a documented application status such
  as 143; Docker and Kubernetes do not require 143 for graceful shutdown.
- Map non-zero codes to the most important failure modes for your tool.
- A flag the caller simply did not pass is not invalid usage. Exit 2 is for
  input the tool cannot act on; an added gate, threshold, or filter flag is
  opt-in — its absence means the check is off and the command still succeeds
  with 0.
- Order the checks so each failure reaches the code that names it: a later
  validation must not intercept a config or data error and report it as bad
  usage.

### Error design

Every error needs:

1. **Machine-readable code** — `UPPER_SNAKE_CASE` (e.g. `CONFIG_MISSING`,
   `AUTH_EXPIRED`).
2. **What went wrong** — context: which resource, operation, input.
3. **How to fix it** — exact command or action the user should take.
4. **Reference** — docs URL or `mycli help <topic>` (optional).

Human mode:

```text
Error: CONFIG_MISSING — Configuration file not found
No configuration file found at ./mycli.config.ts or ~/.config/mycli/config.ts

Fix: Run `mycli init` to create a default configuration file
Docs: https://mycli.dev/docs/configuration
```

- Put the most important information **last** (the eye is drawn to the end).
- Use red sparingly and intentionally.
- Suggest corrections for typos ("Did you mean 'deploy'?").
- Group similar errors under one header — don't repeat 50 similar-looking
  lines.
- Write debug logs to a file, not the terminal (unless `--debug`).

JSON mode — errors are structured too; `transient` says the cause may clear,
but it does not by itself authorize a retry: callers also need exit code 75
or an explicit retry-safe contract:

```json
{
  "ok": false,
  "error": {
    "code": "CONFIG_MISSING",
    "message": "No configuration file found at ./mycli.config.ts",
    "fix": "Run `mycli init` to create a default configuration file",
    "transient": false
  }
}
```
