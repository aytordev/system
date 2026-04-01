## TDD Workflow (RED → GREEN → TRIANGULATE → REFACTOR)

**Impact: CRITICAL**

When TDD mode is detected, follow the RED → GREEN → TRIANGULATE → REFACTOR cycle for each task. When Strict TDD Mode is active (from sdd-init detection), load `modules/strict-tdd.md` for the full protocol including assertion quality rules, approval testing, and pure function preference.

### The TDD Cycle

For **each assigned task**, execute this workflow:

#### 0. SAFETY NET (only if modifying existing files)

Run existing tests for files being modified:
- Capture baseline: "{N} tests passing"
- If any FAIL → STOP, report as "pre-existing failure" (do NOT fix — report to orchestrator)
- This proves you did not break what already worked

#### 1. UNDERSTAND

Read and internalize:
- **Task description** — What specific functionality is being added?
- **Relevant spec scenarios** — What are the success criteria?
- **Design decisions** — How should it be structured?
- **Existing code** — What patterns should be followed?

#### 2. RED (Write Failing Test)

Write a test that:
- Describes the expected behavior from the spec
- Calls the function/method that doesn't exist yet (or doesn't have the new behavior)
- Asserts the expected outcome
- **GATE**: Do NOT proceed to GREEN until the test is written

#### 3. GREEN (Write Minimum Code)

Write **just enough code** to make the test pass. Fake It is VALID (hardcoded values OK).
- **Run the test** — Confirm it **PASSES**
- **GATE**: Do NOT proceed until GREEN is confirmed by execution

#### 4. TRIANGULATE (force real logic)

Add a second test case with DIFFERENT inputs/expected outputs:
- If Fake It breaks (hardcoded no longer works) → generalize to real logic
- Repeat until ALL spec scenarios for this task are covered
- **MINIMUM**: at least 2 test cases per behavior (happy path + edge case)
- Skip ONLY when task is purely structural (config, constant, type export) AND there is literally ONE possible output. Note "Triangulation skipped: {reason}" in evidence table.

#### 5. REFACTOR (Clean Up)

Improve the code without changing behavior:
- Extract constants, functions, improve naming
- **Run tests after EACH refactoring step** — must STILL PASS
- If test fails after refactor → REVERT that step, try smaller

#### 6. Mark Task Complete

### Test Running Strategy

ONLY run the relevant test file, not the entire suite.

### TDD Cycle Evidence Table

For each task, record:

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| 1.1 | `path/test` | Unit | N/A (new) | Written | Passed | 3 cases | Clean |
| 1.2 | `path/test` | Integration | 5/5 | Written | Passed | 2 cases | None needed |

This table goes in the return summary.
