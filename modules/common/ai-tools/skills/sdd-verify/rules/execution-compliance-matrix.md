## Generate Spec Compliance Matrix

**Impact: CRITICAL**

Step 5: The most important step. Cross-reference EVERY spec scenario against test run results.

### Compliance Matrix Table

For each requirement and scenario in the specs, produce a table:

| Requirement | Scenario | Test | Result |
|-------------|----------|------|--------|
| REQ-01 | Happy path | test_file > test_name | COMPLIANT |
| REQ-01 | Edge case | test_file > test_name | FAILING |
| REQ-02 | Main flow | (none found) | UNTESTED |
| REQ-03 | Invalid input | test_file > test_name | PARTIAL |

### Status Definitions

- **COMPLIANT**: Test exists AND passed during execution
- **FAILING**: Test exists BUT failed during execution (CRITICAL)
- **UNTESTED**: No test found for this scenario (CRITICAL)
- **PARTIAL**: Test exists, passes, but covers only part of scenario (WARNING)

### Critical Rule

**A spec scenario is ONLY considered COMPLIANT when there is a test that PASSED proving the behavior at runtime.**

Static analysis is NOT sufficient. The test must have been executed in step 4 and must have passed.

### Matching Strategy

Match tests to scenarios by:

1. **Test name** (e.g., `test_user_login_with_valid_credentials`)
2. **Test description** in test file
3. **Comments** linking test to requirement ID

### Severity Assignment

- **CRITICAL** for any FAILING or UNTESTED scenario
- **WARNING** for any PARTIAL scenario
- **PASS** if all scenarios are COMPLIANT

### Output

Return the full compliance matrix table with a verdict summary:

```
Spec Compliance Matrix:
{full_table}

Total Scenarios: {total}
Compliant: {compliant_count}
Failing: {failing_count} (CRITICAL)
Untested: {untested_count} (CRITICAL)
Partial: {partial_count} (WARNING)

Verdict: PASS | WARNING | CRITICAL
```
