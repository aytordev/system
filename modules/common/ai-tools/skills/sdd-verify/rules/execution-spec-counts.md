## Validate Spec Counts and Bind Evidence to Revisions

**Impact: CRITICAL**

Step 0 (before static analysis): parse the supported spec grammar, reconcile the
requirement/scenario counts, and tie every verification result to the candidate
revision it was collected against.

### Supported Spec Grammar

Both grammars are accepted; count them together, never one only:

| Element | Canonical | Legacy |
|---------|-----------|--------|
| Requirement heading | `### Requirement: {name}` | `## Requirement: {name}` (full spec) |
| Scenario heading | `#### Scenario: {name}` | `**Scenario: {name}**` under `#### Scenarios` |

Count:
- **Requirements** — one per requirement heading.
- **Scenarios** — `#### Scenario:` headings plus bold-legacy `**Scenario:`
  markers.

### Canonicalization of Legacy Specs

Both grammars are accepted, and **canonical `#### Scenario:` is the target**.
When archiving an old change whose `openspec`/`hybrid` spec still uses the bold
grammar, normalize it through the adapter (preview, preserved original, atomic
publish, readback):

```
aytordev-sdd migrate scenarios --input <spec> --backend <openspec|hybrid>
```

Memory-backed (`engram`) and ephemeral (`none`) specs are **not** converted by
the file adapter; they are read in place and re-authored through the phase.
Conversion never changes requirement headings and never rewrites the original.

### Count Reconciliation (MANDATORY)

- Report the parsed totals: `Requirements: {N}`, `Scenarios: {N} (canonical {c} + legacy {l})`.
- The verification report's counts MUST equal the parsed spec counts.
- A spec with zero requirements, a requirement with zero scenarios, or a
  report/scenario total that does not match the parsed counts is **malformed**:
  return `status: blocked` (or `failed`) and do NOT produce a PASS. A count
  mismatch means the verification did not cover the actual spec.
- Any scenario present in the spec but absent from the compliance matrix is
  UNTESTED (CRITICAL), not silently omitted.

### Candidate Revision Binding (MANDATORY)

- Record the **candidate revision** verified: the commit hash, or a content
  hash/snapshot id when the change is not a git commit.
- Every evidence row (test result, build, static check) records the `revision`
  it ran against and the requirement/scenario or unit it addresses.
- Evidence is valid only while its `revision` equals the current candidate
  revision. **Any source change after evidence was collected makes it stale.**
- A stale PASS is not a PASS: re-run the affected checks, or downgrade the
  verdict and return `status: partial`/`failed`. A hash alone does not prove
  test relevance — `relevant` must name what the check exercised.

### Output

```
Spec Grammar: {canonical | legacy | mixed}
Requirements: {N}
Scenarios: {N} (canonical {c} + legacy {l})
Report counts match parsed: {yes | no}
Candidate revision: {hash}
Stale evidence: {count} (must be re-run or downgraded)
Verdict: PASS | WARNING | CRITICAL | BLOCKED
```
