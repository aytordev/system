---
title: Resolve Strict TDD Mode
impact: HIGH
impactDescription: Determines TDD enforcement in apply and verify phases
tags: testing, tdd
---

## Resolve Strict TDD Mode

**Impact: HIGH**

Strict TDD has two independent inputs:

- **requested** — the policy the user or project asked for.
- **executable** — whether a runtime check that covers the change scope exists.

Never conflate them. A request is honored, blocked, or left unset; capability is
measured. Resolution produces `enabled`, `disabled`, or `blocked`.

### Step 1: Resolve the Requested Policy

First match wins; this only sets `requested`, it does not inspect runners:

```
1. System prompt / agent config:
   ├── Search for the "strict-tdd-mode" marker in the agent's system prompt
   │   (opencode AGENTS.md, .cursorrules)
   ├── "enabled"  → requested: true
   ├── "disabled" → requested: false
   └── absent     → fall through

2. OpenSpec config:
   ├── openspec/config.yaml → strict_tdd field
   └── present → use that value

3. No explicit setting → requested: unset
```

An explicit disabled setting is honored. If `requested: false`, the effective
mode is `disabled` even when a runner exists; never override an explicit
disabled.

### Step 2: Read the Executable Capability

Use the per-root capability record from `execution-detect-testing.md`. Strict
TDD prerequisite: a **workspace-wide runtime** check, i.e. a `runtime` surface
whose `covers_workspace: true` (or whose `covers` span the change scope).

`nix-eval` and `nix-build` are not runtime checks and never satisfy this
prerequisite. A runner in a sibling root does not cover the scope either.

### Step 3: Resolve the Effective Mode

```
requested: false
└── effective: disabled      (explicitly disabled — honored, no blocker)

requested: true
├── workspace-wide runtime exists
│   └── effective: enabled
└── no workspace-wide runtime
    └── effective: blocked
        blocker: "Strict TDD requested but no workspace-wide runtime check
                  covers the change scope"
        └── Do NOT set disabled, do NOT pick another root's runner, and do NOT
            load any strict module. Report the blocker to the orchestrator.

requested: unset
├── workspace-wide runtime exists
│   └── effective: enabled   (compatible auto-enable from evidenced coverage)
└── no workspace-wide runtime
    └── effective: disabled  (note: no applicable runtime check)
```

### Rules

- Do NOT ask the user interactively — resolve from existing config.
- Persist `requested`, `effective`, and any `blocker` as part of the testing
  capabilities.
- An explicit `requested: true` without prerequisite coverage is `blocked`, not
  downgraded to `disabled`: never silently downgrade an explicit request.
- Normal mode (effective `disabled`) still requires the unit's relevant focused
  checks; it does not waive verification.
- sdd-apply loads `modules/strict-tdd.md` only when `effective: enabled`.
- sdd-verify loads `modules/strict-tdd-verify.md` only when
  `effective: enabled`.
