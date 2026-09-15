# Persistence Contract (shared across all SDD skills)

**Impact: CRITICAL**

This is the single source of truth for SDD backend resolution and per-backend
behavior. The orchestrator resolves the backend; phases never re-decide it and
never guess artifact paths.

## The Four Backends

`engram | openspec | hybrid | none`

| Backend | Role | Persistence writes | Cross-session recovery |
|---------|------|--------------------|------------------------|
| `engram` | Working memory between sessions (Engram observations) | Engram artifacts; configuration exception only | Yes |
| `openspec` | Source of truth (files in the repo) | Filesystem only | Yes (files persist) |
| `hybrid` | Files for the team + Engram for recovery | Both | Yes (both) |
| `none` | Ephemeral, session-local | None | No |

Only `hybrid` reads more than one store. `engram` and `openspec` never read each
other.

## Backend Resolution — New Change

Resolve once, before the first artifact is written, in this order:

1. **Explicit choice** — the user named a backend (or the command carries one).
   Honor it exactly.
2. **Available selected Engram** — no explicit choice, but the home selected
   Engram and it is reachable. Use `engram`.
3. **No usable backend** — STOP and ask the user which backend to use. Do NOT
   silently choose `none`, do NOT create `openspec/`, and do NOT write memory
   observations before the user answers.

`openspec`, `hybrid`, and `none` are NEVER auto-selected. Record the resolved
backend (and its source: `explicit` | `available-selected` | `recorded`) so a
later phase does not re-ask.

## Backend Resolution — Existing Change

An existing change keeps its recorded backend. Determine it from, in order:

1. the engine readiness probe through the adapter
   (`aytordev-sdd status <change>`, see `sdd-phase-common.md`), or
2. the change's own artifacts/locators (convention paths below).

**No silent cross-store fallback.** If the recorded store is empty or unreadable,
report the change as `blocked`; do NOT read a different store and do NOT
reinitialize. Changing an existing change's backend is a deliberate migration
(see T25) explicitly requested by the user, never an implicit recovery.

## Backend Resolution — Identity

- **project** = git-remote basename, lowercased; `ENGRAM_PROJECT` overrides a
  writer whose project name differs (see `engram-convention.md`).
- **change** = the user-provided slug.
- Artifact locators are deterministic from `backend + project + change`, so the
  orchestrator can pass them to phases instead of each phase deriving them.
- A change created before a rename can carry an older topic key or project name.
  Do NOT silently bridge, re-key, or copy between stores: if the recorded locator
  does not resolve, report `blocked` and ask for the explicit `ENGRAM_PROJECT`
  override (see `engram-convention.md`) or a deliberate migration. Never
  re-initialize the change and never overwrite an existing observation.

## Behavior Per Backend

| Backend | Read from | Write artifacts to | Project files |
|---------|-----------|--------------------|---------------|
| `engram` | Engram (`engram-convention.md`) | Engram artifacts; configuration exception only | Config-only (`openspec/config.yaml`) |
| `openspec` | Filesystem (`openspec-convention.md`) | Filesystem | Yes |
| `hybrid` | Engram (primary), filesystem (fallback) | Both | Yes |
| `none` | Orchestrator prompt context | Nowhere | No persistence artifacts |

## Common Rules

- Only **persistence artifacts** are constrained by the backend. Code/config
  files that the apply phase is explicitly asked to change are **authorized
  implementation edits**, are not persistence writes, and are allowed in every
  backend — including `engram` and `none`.
- `engram`: write all SDD planning artifacts to Engram only. The ONLY permitted
  filesystem persistence file is `openspec/config.yaml`, containing
  `artifact_store: engram` and optional `project`/`rules` metadata.
  Initialization may create its parent directory. Do NOT create or update
  `specs/`, `changes/`, `archive/`, planning files, or any other filesystem
  persistence artifact. Reading this declaration/configuration is permitted;
  filesystem artifact fallback remains forbidden.
- `openspec`: write artifacts ONLY to the paths in `openspec-convention.md`.
- `hybrid`: write the artifact to BOTH stores (see below). Do not treat a
  one-sided write as complete.
- `none`: remain session-local. Write nothing to Engram or the filesystem; return
  results inline and promise no cross-session recovery. Authorized code edits are
  still allowed.
- Create the full `openspec/` layout only for `openspec` or `hybrid`; `engram`
  permits only the configuration exception above. `none` creates nothing.
- If the backend is genuinely unresolved, ask — do not default to `none`.
- **Token cost warning**: `hybrid` consumes more tokens per operation (two
  persistence calls). Use it only when cross-session recovery and a file audit
  trail are both required.

## Hybrid Partial Writes and Retry

Hybrid is the only backend with two writes that can diverge. Keep both stores
consistent:

1. **Write order**: filesystem artifact first (durable and inspectable), then the
   Engram observation. Never delete one side after the other succeeded.
2. **Partial write**: if the Engram write fails after the filesystem write
   succeeded, the operation is `partial`. Return `status: partial` with the failed
   store named; do NOT report success. The artifact is still readable from the
   filesystem.
3. **Retry**: on the next phase launch, compare both stores for the artifact. If
   one is missing or stale, complete the missing write using upsert semantics
   (`mem_save` with the same `topic_key`; in-place file update) so a retry never
   duplicates or regresses content.
4. **Read reconciliation**: read Engram first; if Engram has no complete artifact,
   read the filesystem. When both exist and disagree, prefer the filesystem copy
   (the inspectable source of truth) and note the discrepancy in the envelope.
5. A hybrid operation is only `success` when both stores hold the same, current
   artifact.

## Detail Level

The orchestrator may also pass `detail_level`: `concise | standard | deep`.
This controls output verbosity but does NOT affect what gets persisted — always
persist the full artifact.
