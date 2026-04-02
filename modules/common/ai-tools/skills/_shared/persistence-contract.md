# Persistence Contract (shared across all SDD skills)

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of: `engram | openspec | hybrid | none`.

Default resolution (when orchestrator does not explicitly set a mode):
1. If Engram is available → use `engram`
2. Otherwise → use `none`

`openspec` and `hybrid` are NEVER used by default — only when the orchestrator explicitly passes them.

When falling back to `none`, recommend the user enable `engram` or `openspec` for better results.

## Mode Roles

- **`engram`**: Working memory between sessions. Upserts overwrite — no iteration history. Local only, not shareable.
- **`openspec`**: Source of truth. Files in repo, git history, team-shareable, full audit trail.
- **`hybrid`**: Both — files for team + engram for cross-session recovery. Higher token cost.
- **`none`**: Ephemeral. Lost when conversation ends.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|------|-----------|----------|---------------|
| `engram` | Engram (see `engram-convention.md`) | Engram | Never |
| `openspec` | Filesystem (see `openspec-convention.md`) | Filesystem | Yes |
| `hybrid` | Engram (primary) + Filesystem (fallback) | Both | Yes |
| `none` | Orchestrator prompt context | Nowhere | Never |

### Mode Comparison

| Capability | `engram` | `openspec` | `hybrid` | `none` |
|------------|----------|------------|----------|--------|
| Cross-session recovery | ✅ | ❌ (needs git) | ✅ | ❌ |
| Shareable with team | ❌ (local DB) | ✅ (committed files) | ✅ (files) | ❌ |
| Full iteration history | ❌ (upsert overwrites) | ✅ (git history) | ✅ (files + git) | ❌ |
| Audit trail (archive) | Partial (report only) | ✅ (full folder) | ✅ (both) | ❌ |
| Project files created | Never | Yes | Yes | Never |

## Common Rules

- If mode is `none`, do NOT create or modify any project files. Return results inline only.
- If mode is `engram`, do NOT write any project files. Persist to Engram and return observation IDs.
- If mode is `openspec`, write files ONLY to the paths defined in `openspec-convention.md`.
- If mode is `hybrid`, write to BOTH Engram AND filesystem. Both writes MUST succeed for the operation to be complete. Read from Engram first; fall back to filesystem if Engram returns no results.
- NEVER force `openspec/` creation unless the orchestrator explicitly passed `openspec` or `hybrid` mode.
- If you are unsure which mode to use, default to `none`.
- **Token cost warning**: `hybrid` consumes more tokens per operation (two persistence calls). Use only when cross-session recovery AND a local file audit trail are both needed.

## Detail Level

The orchestrator may also pass `detail_level`: `concise | standard | deep`.
This controls output verbosity but does NOT affect what gets persisted — always persist the full artifact.
