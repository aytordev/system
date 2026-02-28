## Verify Static Specs Match

**Impact: CRITICAL**

Step 2: Check that the implementation structurally matches spec requirements through static analysis.

### For Each Requirement

Retrieve all requirements from the specs. For each requirement and scenario:

1. **Identify the GIVEN, WHEN, THEN** components
2. **Search the codebase** for structural evidence:
   - Is the GIVEN condition handled?
   - Is the WHEN action implemented?
   - Is the THEN outcome produced?
   - Are edge cases covered?

### Severity Assignment

- **CRITICAL** if a requirement is not implemented at all
- **WARNING** if a requirement is partially implemented
- **PASS** if structural evidence exists for all components

### Output

Return a table:

```
| Requirement | GIVEN | WHEN | THEN | Edge Cases | Status |
|-------------|-------|------|------|------------|--------|
| REQ-01      | Found | Found| Found| Missing    | WARNING|
| REQ-02      | Missing | N/A| N/A  | N/A        | CRITICAL|
```

**Note:** This is static analysis only. Runtime compliance is verified in step 5 (compliance matrix).
