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

Do NOT create `openspec/` directory. Save detected project context to Engram using `mem_save` with topic `project-context`.

### Mode: `none`

Do NOT create any files or directories. Return detected context inline without writing to disk.

### Existing State

If `openspec/` already exists (in `openspec` mode):
1. Report what already exists
2. Ask the orchestrator whether to update the existing config or leave it unchanged
3. Do NOT overwrite without confirmation
