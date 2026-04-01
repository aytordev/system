# Strict TDD Module — Verify Phase

> **Loaded ONLY when Strict TDD Mode is enabled AND a test runner exists.**

## TDD Compliance Check (Step 5a)

Read the `apply-progress` artifact and verify TDD was actually followed:

```
Read TDD Cycle Evidence table from apply-progress:
FOR EACH task row:
├── RED: test file must EXIST in the codebase
├── GREEN: test file must PASS when executed now
├── TRIANGULATE: if "N cases" → verify N test cases exist in test file
│   └── If spec has multiple scenarios but only 1 case → WARNING
├── SAFETY NET: if file was modified but shows "N/A" → WARNING
└── If NO evidence table found → CRITICAL (protocol not followed)
```

## Test Layer Distribution (Step 5 expanded)

Classify ALL test files related to this change:

```
Unit: tests single function/class in isolation (no render, no HTTP)
Integration: tests component interaction (render, screen, userEvent)
E2E: tests full system (page.goto, playwright/cypress)

Report distribution table:
| Layer | Tests | Files | Tools |
```

## Changed File Coverage (Step 5d)

When coverage tool is available, report for changed files only:

```
Per changed file:
├── Line coverage %
├── Branch coverage % (if available)
├── Uncovered line ranges
└── Rating: ≥95% Excellent / ≥80% Acceptable / <80% Low
```

## Quality Metrics (Step 5e)

Run quality checks on changed files only:
- Linter: if available, report errors/warnings for changed files
- Type checker: if available, report type errors for changed files

## Report Extensions

Include these tables when Strict TDD is active:

```markdown
### TDD Compliance
| Check | Result | Details |
|-------|--------|---------|
| TDD Evidence reported | yes/no | Found in apply-progress / Missing |
| All tasks have tests | yes/no | N/total tasks have test files |
| GREEN confirmed | yes/no | N/total tests pass on execution |
| Triangulation adequate | yes/partial/na | N tasks triangulated |
| Safety Net for modified | yes/partial | N/total modified files had safety net |

### Test Layer Distribution
| Layer | Tests | Files | Tools |
|-------|-------|-------|-------|
| Unit | N | N | {tool} |
| Integration | N | N | {tool or "not installed"} |
| E2E | N | N | {tool or "not installed"} |

### Changed File Coverage
| File | Line % | Uncovered Lines | Rating |
|------|--------|-----------------|--------|
| path/to/file | 95% | — | Excellent |
```
