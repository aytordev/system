## Return Initialization Summary

**Impact: CRITICAL**

Return a summary appropriate for the resolved persistence mode.

### Template: `engram` Mode

```markdown
## SDD Initialized (Engram)

**Project**: {name}
**Stack**: {stack summary}
**Persistence**: Engram (artifacts saved to memory)

### Detected Context
- Language: {language}
- Framework: {framework}
- Test runner: {test command}
- Build: {build command}

### Next Steps
- Use `/sdd-new <change-name>` to start a new change
- Use `/sdd-explore <topic>` to investigate before committing
```

### Template: `openspec` Mode

```markdown
## SDD Initialized (OpenSpec)

**Project**: {name}
**Stack**: {stack summary}
**Persistence**: File-based (`openspec/`)

### Created
- `openspec/config.yaml` — project configuration
- `openspec/specs/` — specification directory
- `openspec/changes/` — active changes directory
- `openspec/changes/archive/` — archived changes

### Next Steps
- Use `/sdd-new <change-name>` to start a new change
- Use `/sdd-explore <topic>` to investigate before committing
```

### Template: `none` Mode

```markdown
## SDD Initialized (Ephemeral)

**Project**: {name}
**Stack**: {stack summary}
**Persistence**: None (artifacts returned inline only)

> Consider enabling `engram` or `openspec` for persistence across sessions.

### Detected Context
- Language: {language}
- Framework: {framework}
- Test runner: {test command}

### Next Steps
- Use `/sdd-new <change-name>` to start a new change
```
