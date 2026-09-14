## Return Proposal Summary

**Impact: CRITICAL**

Return a concise summary appropriate for the artifact store mode.

### Summary Template

```markdown
## Proposal Created: {change-name}

**Location**: {file path or "Engram" or "inline only"}
**Status**: {new | updated}

### Summary
**Intent**: {one-line summary}
**Scope**: {one-line summary of what's in/out}
**Approach**: {one-line summary}
**Risk Level**: {low/medium/high}

### Key Risks
- {top risk if any, or "None identified"}

### Next Steps
{Recommended next phase — typically "specs and design"}
```

### Envelope Structure

Return the standard `sdd-result/v1` envelope (`_shared/return-envelope.md`); the
legacy `{status: ok|warning|failed, artifacts: [...]}` shape is rejected. Populate
`schema`, `kind`, `status`, `executive_summary`, `artifacts`, `evidence`,
`next_recommended`, `risks`, and `skill_resolution`. `status` is one of
`success | partial | blocked | failed` (never `ok`/`warning`) and `artifacts` is a
list of locator strings, e.g. `openspec/changes/{change-name}/proposal.md` or the
Engram topic key `sdd/{change-name}/proposal`. A `final` envelope requires at
least one evidence entry; use `status: success` only when the artifact and its
evidence are current, otherwise `partial` (unconfirmed) or `blocked`.

### Guidelines

- Keep summary concise — orchestrator reads this
- `next_recommended` is typically `sdd-spec` after proposal
- In `none` mode include the full proposal text inline; no file or observation is created
- Note if this was an update vs new proposal
