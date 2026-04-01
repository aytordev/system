# Strict TDD Module — Apply Phase

> **Loaded ONLY when Strict TDD Mode is enabled AND a test runner exists.**
> If you are reading this, the orchestrator already verified both conditions.

## The Three Laws

1. Do NOT write production code until you have a failing test
2. Do NOT write more test than is necessary to fail
3. Do NOT write more code than is necessary to pass the test

## Choosing Test Layer

Based on cached testing capabilities:

```
Pure logic, utility, calculation → Unit test
Component rendering, interaction → Integration test (or Unit with mocks)
Multi-component flow, API interaction → Integration test
Critical business flow, full journey → E2E test (or Integration fallback)
Default → Unit test (always available)
```

Use the HIGHEST available layer that fits. Never skip a task because a layer is unavailable — degrade to the next layer.

## Pure Function Preference

Prefer pure functions (same input → same output, no side effects):

```
PREFER: function calculateDiscount(price, quantity) → number
AVOID:  function calculateDiscount(item) → mutates globalState
```

## Approval Testing (for refactoring tasks)

When refactoring EXISTING code (not new code):
1. Write approval tests that capture current behavior
2. Run → must PASS (describes current reality)
3. Refactor production code
4. Run → must STILL PASS
5. If spec says behavior should CHANGE → update test to new expectation → RED → implement → GREEN

## Assertion Quality Rules

### Banned Patterns (NEVER write these)

- **Tautologies**: `expect(true).toBe(true)`, `assert 1 == 1`
- **Type-only assertions alone**: `expect(result).toBeDefined()` without value check
- **Ghost loops**: assertions inside `for` over `queryAll` that may return empty array
- **Smoke-test-only**: `render(<Comp/>)` + `toBeInTheDocument()` without behavioral check
- **CSS class assertions**: `expect(el.className).toContain("text-xs")`

### Valid Assertions MUST

1. Call production code
2. Assert a specific expected value
3. Would FAIL if production logic were wrong

### Mock Hygiene

- ≤ 3 mocks per test file → healthy
- 4-6 mocks → consider extracting logic to pure function
- 7+ mocks → STOP — test at wrong layer. Extract logic or move to integration/E2E.

## Test Execution

Run ONLY the relevant test file during the cycle, not the full suite:
```
JS/TS: {runner} {test-file-path}
Python: pytest {test-file-path}
Go: go test ./{package}/... -run {TestName}
```
Full suite runs happen in sdd-verify, not here.
