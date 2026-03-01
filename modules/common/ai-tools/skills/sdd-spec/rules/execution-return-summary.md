## Return Specification Summary

**Impact: CRITICAL**

Return a summary with table of specs written, coverage analysis, and next recommended step.

### Template

```markdown
## Specifications Written

| Domain | Type | Requirements | Scenarios |
|--------|------|--------------|-----------|
| auth | DELTA | 3 added, 1 modified, 0 removed | 8 |
| notifications | FULL | 5 | 12 |

### Coverage Summary

**Happy paths**: 12 scenarios
**Edge cases**: 6 scenarios
**Error states**: 2 scenarios

Total: 20 scenarios across 2 domains

### Artifacts

- `openspec/changes/{change-name}/specs/auth/spec.md`
- `openspec/changes/{change-name}/specs/notifications/spec.md`

### Next Recommended

`sdd-design` — Create technical design based on these specifications

### Risks

- None identified
```

### Guidelines

- Count requirements by type (ADDED/MODIFIED/REMOVED for delta, total for full)
- Count scenarios and categorize by type (happy/edge/error)
- List all created spec files
- Recommend `sdd-design` as next step
- Flag any risks (missing scenarios, unclear requirements, etc.)
