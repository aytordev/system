## Move Change to Archive

**Impact: CRITICAL**

Step 2: Move the change folder to the archive with a timestamped directory name.

### Archive Path

- **Source**: `openspec/changes/{change-name}/`
- **Destination**: `openspec/changes/archive/YYYY-MM-DD-{change-name}/`

Use **ISO date format** (YYYY-MM-DD) for the timestamp. Use today's date.

### Create Archive Directory

If `openspec/changes/archive/` does NOT exist, create it first.

### Move Operation

Move the entire change directory:

```
openspec/changes/{change-name}/ → openspec/changes/archive/2026-03-01-{change-name}/
```

This includes all artifacts:
- proposal.md
- specs/{domain}/delta.md
- design.md
- tasks.md
- verify-report.md
- Any other files created during the change

### Verification

After moving:

1. Confirm source directory no longer exists: `openspec/changes/{change-name}/`
2. Confirm destination exists: `openspec/changes/archive/YYYY-MM-DD-{change-name}/`
3. Confirm all files were moved

### Output

Return a confirmation:

```
Archived: openspec/changes/{change-name}/ → openspec/changes/archive/2026-03-01-{change-name}/
Files moved: {count}
```
