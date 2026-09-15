## Initialize Persistence Backend Directory Structure

**Impact: CRITICAL**

Create the persistence backend for the **resolved** backend. Resolve it per
`_shared/persistence-contract.md` first: an explicit choice wins; otherwise prefer
available selected Engram for a new project; an existing change keeps its recorded
backend. If no backend is usable, STOP and ask — do not bootstrap anything.

### Mode: `openspec`

Create the following directory structure:

```
openspec/
├── config.yaml
├── specs/
└── changes/
    └── archive/
```

### Mode: `engram`

Create only the `openspec/` parent directory; `openspec/config.yaml` (the
declaration) is written in Step 5. Planning artifacts stay in Engram. Do NOT
create `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/`, or
any other filesystem artifact. Saving project context to Engram happens in
Step 7 (`rules/execution-persist-context.md`), not here.

### Mode: `hybrid`

Perform BOTH the `openspec` bootstrap AND the Engram side:
1. Create the full openspec/ directory structure (same as `openspec` mode)
2. Planning artifacts for the Engram side need no filesystem work; project
   context is saved to Engram in Step 7 (`rules/execution-persist-context.md`)
3. Both stores must land. If one fails, report `status: partial` naming the failed
   store (not `blocked`); the successful side is kept and the missing write is
   retried with upsert semantics on the next launch — never delete the successful
   side.

### Mode: `none`

Do NOT create any files or directories and do NOT write Engram observations.
Return detected context inline only and promise no cross-session recovery.

### Existing State

Before writing anything for a persistent backend (`engram`, `openspec`, or
`hybrid`), check what already exists. If `openspec/` already exists:
1. Report what already exists
2. If an existing `openspec/config.yaml` already declares the same resolved
   backend, retain it as-is. If it declares a different backend, ask the
   orchestrator whether to update it or leave it unchanged. If the file nests
   `mode:` under `artifact_store:`, conflicts with a sibling `config.yml`, or is
   otherwise ambiguous, BLOCK: preserve it untouched and require a separately
   authorized migration — the pinned engine cannot see a nested declaration.
3. Do NOT overwrite without confirmation

A declaration/Engram-save failure blocks initialization (`status: blocked`);
hybrid keeps its partial-write/retry semantics.
