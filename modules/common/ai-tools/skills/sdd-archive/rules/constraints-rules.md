## Archive Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD archive phase.

### MUST

- ALWAYS sync delta specs to main specs BEFORE moving to archive
- ALWAYS preserve requirements not mentioned in the delta when merging
- ALWAYS use ISO date format (YYYY-MM-DD) for archive directory names
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`
- Match requirements by name/ID when applying MODIFIED and REMOVED actions

### MUST NOT

- NEVER archive a change with CRITICAL issues in the verification report
- NEVER delete or modify archived changes (archive is an audit trail)
- NEVER lose existing requirements during merge (only modify what's in the delta)
- NEVER overwrite an existing archive directory (each archive should be timestamped uniquely)

### SHOULD

- Warn and ask for confirmation if a merge operation would be destructive
- Apply `rules.archive` settings from `config.yaml` when available
- Verify verification report shows PASS or PASS WITH WARNINGS before archiving
- Check that `rules.archive.require_clean_verification` is satisfied if configured
