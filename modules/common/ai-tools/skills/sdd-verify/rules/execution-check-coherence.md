## Verify Design Match

**Impact: CRITICAL**

Step 3: Verify that implementation matches the design document.

### Design Decision Compliance

Check that design decisions were followed:

- **Selected alternatives** were implemented (not rejected alternatives)
- **Rationale** from design decisions is reflected in implementation

### File Changes Match

Compare implementation against design's **File Changes** table:

- All files listed in design are modified as described
- No unexpected major files are modified
- File change descriptions match actual changes

### Interfaces and Contracts

Verify design's **Interfaces/Contracts** section:

- Function signatures match design
- API contracts match design
- Data structures match design

### Severity Assignment

- **CRITICAL** if core design decisions were ignored
- **WARNING** if minor design elements are missing
- **PASS** if implementation matches design

### Output

Return a summary:

```
Design Decisions: {followed_count}/{total_count} followed
File Changes: {matched_count}/{expected_count} matched
Interfaces: {matched_count}/{expected_count} matched
Verdict: CRITICAL | WARNING | PASS
```
