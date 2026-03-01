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

Return the standard envelope:

```json
{
  "status": "ok",
  "executive_summary": "{one-line summary}",
  "detailed_report": "{optional: full proposal text if mode is none}",
  "artifacts": [
    {
      "type": "proposal",
      "location": "{path or 'engram' or 'inline'}",
      "change_name": "{change-name}"
    }
  ],
  "next_recommended": "specs",
  "risks": [
    "{risk if high-impact}"
  ]
}
```

### Guidelines

- Keep summary concise — orchestrator reads this
- `next_recommended` is typically `specs` after proposal
- Include full proposal text in `detailed_report` only if mode is `none`
- Note if this was an update vs new proposal
