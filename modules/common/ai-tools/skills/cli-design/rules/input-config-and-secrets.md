---
title: Make Input Scriptable and Secrets Safe
impact: HIGH
impactDescription: Agents and humans can both drive the tool
tags: cli-design, flags, prompts, secrets, config
---

## Make Input Scriptable and Secrets Safe

**Impact: HIGH**

### Flags over arguments

- **1 positional arg**: acceptable (the "main thing").
- **2 positional args**: suspicious — consider flags instead.
- **3+ positional args**: prefer named flags unless a familiar command grammar
  makes the positions obvious.
- **Exception**: variadic args of the same type are fine
  (`rm a.txt b.txt c.txt`), as are universal idioms (`cp source dest`).

```bash
# Bad — which is source, which is destination?
mycli copy myapp backup

# Good — explicit
mycli copy --from myapp --to backup
```

### Standard flags

Always provide long forms. Short flags only for the most common operations.

| Flag | Meaning |
|------|---------|
| `-h`, `--help` | Show help (this should only mean help) |
| `--version` | Print version to stdout |
| `-q`, `--quiet` | Suppress non-essential output |
| `-v`, `--verbose` | More detail in human output |
| `-d`, `--debug` | Diagnostic output to stderr |
| `-f`, `--force` | Skip confirmation prompts |
| `-n`, `--dry-run` | Show what would happen without doing it |
| `--json` | Structured JSON output |
| `--plain` | Stable, grep-friendly plain text |
| `--no-color` | Disable color output |
| `--no-input` | Disable all prompts/interactivity |
| `-o`, `--output` | Output file |
| `--fields` | Select output columns |

### Prompts and interactivity

- **All prompts MUST be bypassable** via flags for scriptability:
  confirmation → `--yes` or `--force`; selection → `--type=value`; text input
  → `--name=value`; passwords → `--password-file=path` or stdin pipe.
- If stdin is not a TTY, never prompt — fail with a clear error or use
  defaults.
- **Secrets: never via flag values** (leak to `ps` output and shell history).
  Prefer, in order: OS keychain or a `0600` credential file, then stdin
  (`mycli login --with-token < token.txt`), then env vars **only where the
  platform injects them** (CI secret stores) — env leaks to child processes
  and crash reports, so never make it the primary documented path.
- **Scale confirmation to severity**: mild → `y/N` prompt with `--yes` bypass;
  moderate → prompt plus suggest `--dry-run` first; severe/irreversible
  (delete a database, overwrite production) → require typing the resource name
  to confirm.

### Conventions

- Support `--` to stop flag parsing: `mycli run -- --flag-for-child-process`.
- Support `-` for stdin/stdout file arguments: `curl ... | mycli process -`.
- Accept both `--flag=value` and `--flag value`.
- If stdin is expected but is an interactive terminal, display help immediately
  (don't hang like `cat`).

### Config precedence

Highest to lowest priority:

1. **Flags** — per-invocation overrides.
2. **Environment variables** — `MYCLI_*` prefix, per-session.
3. **Project config** — `.myclirc`, `mycli.config.ts`, or in `package.json`.
4. **User config** — `~/.config/mycli/` (follow the XDG Base Directory
   Specification).
5. **Defaults** — sensible built-in values.

Rules:

- Env var naming: `MYCLI_*` prefix, uppercase letters + digits + underscores;
  keep values single-line; don't commandeer POSIX names.
- Respect the general-purpose env vars where relevant: `NO_COLOR`,
  `FORCE_COLOR`, `DEBUG`, `EDITOR`, `PAGER`, `HTTP_PROXY`/`HTTPS_PROXY`/
  `NO_PROXY`, `TMPDIR`, `TERM`, `LINES`/`COLUMNS`.
- Never accept secrets via flags — see "Prompts and interactivity".
- Read `.env` where appropriate, but don't use it as a substitute for proper
  config.
- If you modify configuration that belongs to another program, ask consent
  first.
