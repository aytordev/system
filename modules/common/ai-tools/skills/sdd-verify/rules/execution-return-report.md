## Return Verification Report

**Impact: CRITICAL**

Step 6: Compile all verification results into a structured report.

### Report Template

```markdown
# Verification Report: {change-name}

## Candidate Revision
{commit hash or content hash verified; every evidence row is bound to it}

## Spec Grammar & Counts
- Grammar: {canonical | legacy | mixed}
- Requirements: {N} parsed / {N} in matrix
- Scenarios: {N} parsed ({c} canonical + {l} legacy) / {N} in matrix

## Completeness
{task completion table with status; persisted checkboxes are authoritative}

## Build & Tests Execution
### Test Execution
Command: {test_command}; exit: {code}; revision: {hash}
{test execution output summary}

### Build Execution
Command: {build_command}; exit: {code}; revision: {hash}
{build execution output summary}

### Coverage (if configured)
{coverage percentage and threshold}

## Spec Compliance Matrix
{full compliance matrix from step 5, including per-row revisions}

## Correctness (Static Analysis)
{static specs match summary from step 2}

## Coherence (Design Match)
{design match summary from step 3}

## Issues Found

### CRITICAL
- {critical issue 1}

### WARNING
- {warning 1}

### SUGGESTION
- {suggestion 1}

## Verdict
{PASS | PASS WITH WARNINGS | FAIL | BLOCKED}

Stale, missing, or count-mismatched evidence is never a PASS.

---
Generated: {timestamp}
```

### Verdict Rules

- **FAIL**: Any CRITICAL issues found
- **PASS WITH WARNINGS**: No CRITICAL issues, but WARNING issues exist
- **PASS**: No CRITICAL or WARNING issues
- **BLOCKED**: Spec counts cannot be reconciled, evidence is stale, or a required check could not run

### Persistence

Persist to the backend the orchestrator resolved (no cross-store fallback):

- **openspec**: Write `openspec/changes/{change-name}/verify-report.md`
- **engram**: Save to Engram with topic_key `sdd/{change-name}/verify-report`
- **hybrid**: Both, with the partial-write/retry rules
- **none**: Return inline only (do not persist)

Tracking verification state is allowed; closing the change is not. Do not label
an unverified change as verified.

### Result Envelope

Return an `sdd-result/v1` envelope (`_shared/return-envelope.md`):

```json
{
  "schema": "sdd-result/v1",
  "kind": "final",
  "status": "success | partial | blocked | failed",
  "executive_summary": "brief summary of verification results",
  "artifacts": ["verify-report"],
  "evidence": [
    {"check": "npm test -- auth", "exit": 0, "result": "pass", "revision": "3752d5c", "relevant": "REQ-01/S1"}
  ],
  "next_recommended": "sdd-archive | sdd-apply (if fixes needed)",
  "risks": ["any risks identified"],
  "skill_resolution": "paths-injected"
}
```

Map the verdict: `PASS` → `success`, `PASS WITH WARNINGS`/`PARTIAL` → `partial`,
`FAIL`/`CRITICAL` → `failed`, unresolved blocker/count mismatch/stale evidence →
`blocked`. Only `success` may advance; a stale PASS is never `success`.
