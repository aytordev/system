## Verify Archive Completeness and Return Summary

**Impact: CRITICAL**

Step 3: Verify that the archive operation completed successfully and return a comprehensive summary.

### Verification Checklist

Confirm:

1. **Main specs updated**: All delta specs were merged into main specs
2. **Change folder moved**: Source directory no longer exists
3. **Archive contains all artifacts**: proposal, specs, design, tasks, verify-report
4. **Active changes no longer has this change**: `openspec/changes/{change-name}/` does not exist

### Summary Template

```markdown
# Archive Complete: {change-name}

## Change Information
- **Change Name**: {change-name}
- **Archive Location**: `openspec/changes/archive/YYYY-MM-DD-{change-name}/`
- **Archived On**: {timestamp}

## Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| auth | ADDED | 3 new requirements |
| api | MODIFIED | 2 requirements updated |
| ui | created | New spec from delta |

## Archive Contents
- [x] proposal.md
- [x] specs/{domain}/delta.md
- [x] design.md
- [x] tasks.md
- [x] verify-report.md

## Source of Truth Updated
Main specs in `openspec/specs/` now reflect this change.

## SDD Cycle Complete
{change-name} is archived. The change is complete and the specs are up to date.
```

### Result Envelope

Return:

```json
{
  "status": "ok",
  "executive_summary": "{change-name} archived successfully. Specs synced and change moved to archive.",
  "detailed_report": "full summary content",
  "artifacts": ["openspec/changes/archive/YYYY-MM-DD-{change-name}/"],
  "next_recommended": null,
  "risks": []
}
```

### Persistence

- **openspec** mode: Summary already exists in archive folder
- **engram** mode: Save summary to Engram with topic `archive/{change-name}`
- **none** mode: Return inline only
