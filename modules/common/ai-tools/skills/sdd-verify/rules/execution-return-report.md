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

### Engine Verify Envelope (mandatory, first bytes)

The pinned engine admits a verification report only when its **first non-empty
line** is a fenced `yaml` block declaring the strict envelope. Any narrative
before the fence makes the report inadmissible, so canonical spec promotion
(C11) stays blocked.

The persisted report MUST begin with exactly this fence (the `yaml` tag and the
key order are significant):

````markdown
```yaml
schema: gentle-ai.verify-result/v1
evidence_revision: sha256:<64 lowercase hex of the candidate revision>
verdict: pass
blockers: 0
critical_findings: 0
requirements: <parsed>/<parsed>
scenarios: <parsed>/<parsed>
test_command: <command or true>
test_exit_code: <code>
test_output_hash: sha256:<64 lowercase hex>
build_command: <command or true>
build_exit_code: <code>
build_output_hash: sha256:<64 lowercase hex>
```
````

- `evidence_revision` is the **candidate revision** the evidence ran against
  (commit hash or content hash); it must equal the revision in `## Candidate
  Revision`. The archive gate refuses a mismatch (`stale-verification`).
- `verdict` MUST be `pass` for a successful closure; a failed/CRITICAL report
  keeps closure blocked.
- The counts MUST equal the parsed spec counts (see `execution-spec-counts.md`).
- Validate the exact bytes through the adapter before returning:
  `aytordev-sdd verify --input <report> --requirements <n> --scenarios <n>`.

This envelope is the artifact the engine reads. The `sdd-result/v1` envelope
returned to the orchestrator is separate and still required (below).

### Legacy Report (pre-engine)

A prior report that does **not** begin with the `gentle-ai.verify-result/v1`
fence is **inadmissible**: it is historical prose, not current, relevant
evidence, and it cannot close a change. Detect it without editing it:

```
aytordev-sdd migrate verify-report --input <report>
```

The adapter preserves the file and reports `requires-reverification`. **Re-run
verification** against the current candidate to produce a current, fenced report.
Never synthesize the fence, upgrade an old verdict, or fabricate a PASS from a
legacy report.

### Persistence

Persist to the backend the orchestrator resolved (no cross-store fallback):

- **openspec**: Write `openspec/changes/{change-name}/verify-report.md`
- **engram**: Save to Engram with topic_key `sdd/{change-name}/verify-report`
- **hybrid**: Both, with the partial-write/retry rules
- **none**: Return inline only (do not persist)

Tracking verification state is allowed; closing the change is not. Do not label
an unverified change as verified. Closure obligations, dispositions, and the
promotion rule are defined in `_shared/closure-policy.md`.

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
