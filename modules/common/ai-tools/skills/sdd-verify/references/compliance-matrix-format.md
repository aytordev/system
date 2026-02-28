# Spec Compliance Matrix Format

The compliance matrix cross-references spec scenarios with test execution results to prove runtime correctness.

## Table Format

| Requirement | Scenario | Test | Result |
|-------------|----------|------|--------|
| REQ-01 | Happy path login | auth_test.ts > testValidLogin | COMPLIANT |
| REQ-01 | Invalid credentials | auth_test.ts > testInvalidCreds | FAILING |
| REQ-02 | Password reset flow | (none found) | UNTESTED |
| REQ-03 | Token expiration | auth_test.ts > testTokenExpiry | PARTIAL |

## Status Definitions

### COMPLIANT

- Test exists for this scenario
- Test was executed during verification
- Test PASSED

**Only this status indicates proven correctness.**

### FAILING

- Test exists for this scenario
- Test was executed during verification
- Test FAILED

**Severity: CRITICAL** — The implementation does not meet the spec for this scenario.

### UNTESTED

- No test found for this scenario
- Or test exists but was not executed

**Severity: CRITICAL** — No proof that the implementation meets the spec.

### PARTIAL

- Test exists and passed
- Test covers only part of the scenario
- Some aspects of the scenario are not tested

**Severity: WARNING** — Implementation may be correct, but proof is incomplete.

## Examples

### Good Coverage

```
| REQ-01 | User login | auth_test.ts > testLogin | COMPLIANT |
| REQ-01 | Login with 2FA | auth_test.ts > testLogin2FA | COMPLIANT |
| REQ-01 | Failed login lockout | auth_test.ts > testLockout | COMPLIANT |
```

All scenarios tested and passing = PASS verdict.

### Critical Issues

```
| REQ-02 | Password reset | (none found) | UNTESTED |
| REQ-03 | Token validation | auth_test.ts > testToken | FAILING |
```

UNTESTED + FAILING = FAIL verdict (CRITICAL issues).

### Warning Issues

```
| REQ-04 | Session timeout | session_test.ts > testTimeout | PARTIAL |
```

Test exists and passes but doesn't cover all timeout edge cases = WARNING.

## Matching Tests to Scenarios

Match by:

1. **Test name** convention (e.g., `test_user_login_with_valid_credentials`)
2. **Test description** or docstring
3. **Comments** linking to requirement ID (e.g., `// REQ-01`)
4. **Code coverage** showing scenario code is executed

## Notes

- Static analysis (step 2) checks structure; compliance matrix (step 5) proves runtime behavior
- A spec scenario without a COMPLIANT test is incomplete, even if code exists
- Coverage percentage is informative but does NOT replace the compliance matrix
