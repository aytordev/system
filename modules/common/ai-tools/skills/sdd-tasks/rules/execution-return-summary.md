## Return Task Breakdown Summary

**Impact: CRITICAL**

After creating tasks.md, return a summary in the result envelope following the
versioned `sdd-result/v1` schema (`_shared/return-envelope.md`). The summary MUST
include the `Review Workload Forecast` block so the orchestrator can apply the
delivery strategy without re-deriving it.

### Summary Format

**Executive Summary:**

```
Created task breakdown for {change-name} with {N} tasks across {M} phases.
Estimated complexity: {LOW | MEDIUM | HIGH | VERY HIGH}
Review Workload Forecast: {estimated changed lines} lines; 400-line budget risk {Low|Medium|High}; chained PRs {Yes|No}; decision needed before apply {Yes|No}
Next recommended step: apply (Phase 1, tasks 1.1-1.3)
```

**Detailed Report:**

```markdown
## Task Breakdown: {change-name}

### Overview

| Phase | Tasks | Focus Area |
|-------|-------|------------|
| 1: Foundation | {count} | {brief description} |
| 2: Core Implementation | {count} | {brief description} |
| 3: Integration | {count} | {brief description} |
| 4: Verification / Cleanup | {count} | {brief description} |

**Total tasks:** {N}

### Review Workload Forecast

- Estimated changed lines: {N}
- 400-line budget risk: {Low | Medium | High}
- Chained PRs recommended: {Yes | No}
- Decision needed before apply: {Yes | No}
- Suggested PR slices: {slice 1; slice 2 | —}
- Delivery strategy: {ask-on-risk | auto-chain | single-pr | exception-ok}

### Implementation Order Notes

- Phase 1 establishes {what}
- Phase 2 can proceed in parallel for {which components}
- Phase 3 requires completion of Phase 2 tasks {list dependencies}
- Each unit carries its focused check, scenario, and rollback boundary

### Estimated Complexity

{LOW | MEDIUM | HIGH | VERY HIGH} — {brief justification}

### Next Steps

Recommended: Start with Phase 1, tasks 1.1-1.3 (Foundation)
```

### Artifacts Field

```json
{
  "artifacts": {
    "tasks": "{tasks.md content or reference}",
    "phase_count": 4,
    "task_count": 23,
    "workload_forecast": {
      "estimated_changed_lines": 180,
      "budget_risk": "low",
      "chained_prs": false,
      "decision_needed_before_apply": false
    }
  }
}
```

### Next Recommended

Typically: `"apply"` with specific Phase 1 tasks to start implementation.

### Result Envelope

Return an `sdd-result/v1` envelope (`_shared/return-envelope.md`) with
`schema`, `kind: final`, `status`, `executive_summary`, `artifacts`, `evidence`,
`next_recommended`, `risks`, and `skill_resolution`. Use `status: success` only
when the task breakdown, per-unit evidence, and forecast are all complete;
`status: partial` if the forecast could not be estimated.
