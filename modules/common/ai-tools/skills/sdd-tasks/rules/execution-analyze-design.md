## Analyze Design to Identify Implementation Components

**Impact: CRITICAL**

Before writing tasks, analyze the design artifact to extract all concrete implementation requirements.

### What to Extract

1. **File Changes Table** — The design's "File Changes" section lists every file to create, modify, or delete:
   - Map each file to one or more tasks
   - Identify dependency order (what must be built first)

2. **Component Breakdown** — For each component in the design:
   - What files does it span?
   - What are its dependencies (internal and external)?
   - What testing is required?

3. **Integration Points** — Identify:
   - Where components wire together
   - Configuration updates needed
   - Database migrations or schema changes

4. **Testing Requirements** — Per component:
   - Unit test files needed
   - Integration test scenarios
   - Test data or fixtures required

5. **Per-Unit Evidence** — For each resulting task, determine before writing it:
   - **Focused check** — the exact command that verifies this unit (its own
     runner or Nix surface).
   - **Applicable scenario** — the spec scenario (`REQ/S#`) it satisfies, or an
     explicit `N/A — {reason}` when no runtime scenario applies.
   - **Rollback boundary** — what removes just this unit without touching
     unrelated work.

6. **Review Workload Forecast** — Estimate total changed lines from the design's
   File Changes table and derive `400-line budget risk` and
   `Chained PRs recommended` for the required forecast block.

### Output

Create a mental map (or notes) like:

```
Foundation phase:
- Create base types in types.ts — check: npm test -- types; scenario: REQ-01/S1; rollback: remove types.ts
- Create database schema in migrations/001_init.sql — check: npm run migrate:up; scenario: REQ-01/S2; rollback: drop migration

Core phase:
- Implement auth service in services/auth.ts — check: npm test -- auth; scenario: REQ-02/S1; rollback: remove auth.ts

Integration phase:
- Wire auth middleware in middleware/auth.ts — check: npm test -- middleware; scenario: REQ-02/S2; rollback: unwire middleware

Verification phase:
- Update API documentation — check: markdownlint; scenario: N/A — docs only; rollback: revert docs

Review Workload Forecast:
- Estimated changed lines: 180
- 400-line budget risk: Low
- Chained PRs recommended: No
- Decision needed before apply: No
```

This map becomes the source for writing tasks.md.
