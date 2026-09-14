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

Do NOT create `openspec/` directory. Save detected project context to Engram using `mem_save` with topic_key `sdd-init/{project-name}`.

### Mode: `hybrid`

Perform BOTH the `openspec` bootstrap AND the `engram` save:
1. Create the openspec/ directory structure (same as `openspec` mode)
2. Save detected project context to Engram with topic_key `sdd-init/{project-name}`
3. Both writes must land. If one fails, report `status: partial` naming the failed
   store (not `blocked`); the successful side is kept and the missing write is
   retried with upsert semantics on the next launch — never delete the successful
   side.

### Mode: `none`

Do NOT create any files or directories and do NOT write Engram observations.
Return detected context inline only and promise no cross-session recovery.

### Existing State

If `openspec/` already exists (in `openspec`/`hybrid` mode):
1. Report what already exists
2. Ask the orchestrator whether to update the existing config or leave it unchanged
3. Do NOT overwrite without confirmation
