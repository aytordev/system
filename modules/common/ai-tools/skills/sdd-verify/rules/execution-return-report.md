## Return Verification Report

**Impact: CRITICAL**

Step 6: Compile all verification results into a structured report.

### Report Template

```markdown
# Verification Report: {change-name}

## Completeness
{task completion table with status}

## Build & Tests Execution
### Test Execution
Command: {test_command}
{test execution output summary}

### Build Execution
Command: {build_command}
{build execution output summary}

### Coverage (if configured)
{coverage percentage and threshold}

## Spec Compliance Matrix
{full compliance matrix from step 5}

## Correctness (Static Analysis)
{static specs match summary from step 2}

## Coherence (Design Match)
{design match summary from step 3}

## Issues Found

### CRITICAL
- {critical issue 1}
- {critical issue 2}

### WARNING
- {warning 1}
- {warning 2}

### SUGGESTION
- {suggestion 1}
- {suggestion 2}

## Verdict
{PASS | PASS WITH WARNINGS | FAIL}

---
Generated: {timestamp}
```

### Verdict Rules

- **FAIL**: Any CRITICAL issues found
- **PASS WITH WARNINGS**: No CRITICAL issues, but WARNING issues exist
- **PASS**: No CRITICAL or WARNING issues

### Persistence

- **openspec** mode: Write `openspec/changes/{change-name}/verify-report.md`
- **engram** mode: Save to Engram with topic `verify/{change-name}`
- **none** mode: Return inline only (do not persist)

### Result Envelope

Return:

```json
{
  "status": "ok | warning | failed",
  "executive_summary": "brief summary of verification results",
  "detailed_report": "full report content",
  "artifacts": ["verify-report.md"],
  "next_recommended": "sdd-archive | sdd-apply (if fixes needed)",
  "risks": ["any risks identified"]
}
```
