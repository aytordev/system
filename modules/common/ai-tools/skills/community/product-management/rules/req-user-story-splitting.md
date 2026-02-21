---
title: User Story Splitting
impact: HIGH
impactDescription: Stories too large to complete in a sprint block velocity and make progress invisible
tags: story splitting, agile, patterns, workflow steps, backlog refinement
---

## User Story Splitting

**Impact: HIGH (Stories too large to complete in a sprint block velocity and make progress invisible)**

Break large stories using 8 proven patterns: workflow steps, business rules, happy/unhappy paths, input variations, data types, operations (CRUD), platforms, and roles. Choose the pattern that produces the smallest independently valuable slice — each resulting story must still deliver user value and meet INVEST criteria. Do not split by technical task (UI / API / DB) — that produces dependent stories with no standalone value. If a split produces a story that cannot be demonstrated to a stakeholder, the split is wrong.

**Incorrect (split by technical layer — stories are dependent and have no standalone value):**

```markdown
Original: As a manager I want to export reports so that I can share them with stakeholders

Split:
- Build export API endpoint
- Build export UI button
- Write export to CSV logic
- Add file download handler
```

**Correct (split by data type and operation — each story ships independently):**

```markdown
Original: As a manager I want to export reports so that I can share them with stakeholders

Split by data type:
- As a manager I want to export reports as CSV so that I can open them in Excel
- As a manager I want to export reports as PDF so that I can share a formatted document

Split by happy/unhappy path:
- As a manager I want to export a report successfully so that I receive the file
- As a manager I want to see a clear error if the export fails so that I know to retry

Split by operation:
- As a manager I want to export a single report
- As a manager I want to export all reports in a date range (deferred to sprint N+2)
```

Reference: [Full framework](../references/user-story-splitting-full.md)
