---
title: Rate and Report With Evidence
impact: HIGH
impactDescription: Keeps a review falsifiable and actionable
tags: review, ratings, findings
---

## Rate and Report With Evidence

**Impact: HIGH**

### Rating discipline

- `Strong` — the evidence is in the test or a run.
- `Mixed` — holds in part of the scope; name where it fails.
- `Weak` — a real defect; name the file and line.
- `Not assessed` — the evidence was not gathered. Never guess to fill the row.

Cite locations as `path:line` plus the reason. "Weak, tests are unclear" is not
evidence; "Weak, `scoring.test.ts:42` asserts `toHaveBeenCalled` on an internal
collaborator" is.

### Report shape

```markdown
## Test design review: [scope]

| Property | Rating | Evidence |
| --- | --- | --- |
| Understandable | Strong/Mixed/Weak/Not assessed | [file:line and reason] |
| Maintainable | ... | ... |
| Repeatable | ... | ... |
| Atomic | ... | ... |
| Necessary | ... | ... |
| Granular | ... | ... |
| Fast | ... | ... |
| First | ... | ... |

### Findings

1. **[severity] — [problem]** (`path:line`)
   Impact: [observable risk].
   Smallest fix: [action].

### Validation gaps

- [What was not assessed and the evidence it would need]
```

### Findings that earn a place

Rank by impact on behaviour evidence, not by style taste. A finding is worth
reporting when it means the suite could stay green over a broken rule, could fail
for an unrelated reason, or cannot run reliably.

Prefer the smallest change that strengthens observable behaviour:

- Add the boundary case the code actually branches on.
- Replace a spy on an internal collaborator with an assertion on the outcome.
- Replace a shared mutable fixture with a factory call.
- Remove a test that duplicates another's evidence.

### What is not a finding

- One assertion per test as a rule.
- A test file per implementation file as a requirement.
- Unit tests demanded where an integration or browser contract owns the claim.

Those are preferences, or design evidence about a missing seam. Name them as such
in the validation gaps, not as defects in the tests.
