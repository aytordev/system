## Initialize Persistence Backend Directory Structure

**Impact: CRITICAL**

Create the persistence backend based on the resolved artifact store mode.

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
3. Both operations MUST succeed — if either fails, report as blocked

### Mode: `none`

Do NOT create any files or directories. Return detected context inline without writing to disk.

### Existing State

If `openspec/` already exists (in `openspec` mode):
1. Report what already exists
2. Ask the orchestrator whether to update the existing config or leave it unchanged
3. Do NOT overwrite without confirmation
