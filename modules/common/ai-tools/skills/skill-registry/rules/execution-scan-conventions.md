---
title: Scan Project Conventions
impact: HIGH
impactDescription: Captures project-specific patterns
tags: scanning, conventions
---

## Scan Project Conventions

**Impact: HIGH**

Check the project root for convention files:

### Files to look for

- `AGENTS.md` or `agents.md`
- `CLAUDE.md` (project-level only, NOT `~/.claude/CLAUDE.md`)
- `.cursorrules`
- `GEMINI.md`
- `copilot-instructions.md`

### Index file handling

If an index file is found (e.g., `AGENTS.md`): READ its contents and extract all referenced file paths. These index files typically list project conventions with paths — extract every referenced path and include it in the registry alongside the index file itself.

### Output

Build a table of: `File | Path | Notes`

Include both the index file AND all paths it references — zero extra hops for sub-agents.

### Example

```markdown
## Project Conventions

| File | Path | Notes |
|------|------|-------|
| AGENTS.md | ./AGENTS.md | Index — references files below |
| AI Tools AGENTS | modules/common/ai-tools/AGENTS.md | Referenced by AGENTS.md |
| Home AGENTS | modules/home/AGENTS.md | Referenced by AGENTS.md |
```
