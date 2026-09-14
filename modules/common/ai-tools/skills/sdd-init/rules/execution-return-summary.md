## Return Initialization Summary

**Impact: CRITICAL**

Return a summary appropriate for the resolved persistence mode.

> **Engram Limitations** (include this notice in `engram` and `hybrid` mode summaries):
> Engram is a local-only memory store. Observations are NOT shareable with teammates and upserts **overwrite** prior iterations — there is no history. For team-shareable artifacts with full audit trails, use `openspec` or `hybrid` mode.

### Template: `engram` Mode

```markdown
## SDD Initialized (Engram)

**Project**: {name}
**Stack**: {stack summary}
**Persistence**: Engram (artifacts saved to memory)
**Strict TDD requested**: {true / false / unset}
**Strict TDD effective**: {enabled / disabled / blocked}
**Strict TDD blocker**: {reason or —}

### Testing Capabilities
| Root | Command | Surface | Covers | Workspace-wide |
|------|---------|---------|--------|----------------|
| {root} | `{command}` | {runtime / nix-eval / nix-build} | {targets} | yes/no |

### Context Saved
- **Engram key**: sdd-init/{project-name}
- **Testing capabilities key**: sdd/{project-name}/testing-capabilities
- **Skill registry**: Engram `skill-registry`

No project files created.

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
- `.atl/skill-registry.md` — skill index

### Next Steps
- Use `/sdd-new <change-name>` to start a new change
- Use `/sdd-explore <topic>` to investigate before committing
```

### Template: `hybrid` Mode

```markdown
## SDD Initialized (Hybrid)

**Project**: {name}
**Stack**: {stack summary}
**Persistence**: Hybrid (Engram + openspec/)
**Strict TDD requested**: {true / false / unset}
**Strict TDD effective**: {enabled / disabled / blocked}
**Strict TDD blocker**: {reason or —}

### Testing Capabilities
| Root | Command | Surface | Covers | Workspace-wide |
|------|---------|---------|--------|----------------|
| {root} | `{command}` | {runtime / nix-eval / nix-build} | {targets} | yes/no |

### Created (OpenSpec)
- `openspec/config.yaml` — project configuration
- `openspec/specs/` — specification directory
- `openspec/changes/` — active changes directory

### Saved (Engram)
- **Context key**: sdd-init/{project-name}
- **Testing capabilities key**: sdd/{project-name}/testing-capabilities
- **Skill registry**: Engram `skill-registry` + `.atl/skill-registry.md`

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
- Project roots: {root} → {per-root commands and surfaces}

### Next Steps
- Use `/sdd-new <change-name>` to start a new change
```
