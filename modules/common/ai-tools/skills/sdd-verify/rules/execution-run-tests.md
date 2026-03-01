## Execute Tests and Build

**Impact: CRITICAL**

Step 4: Execute tests and build to verify runtime correctness. Real execution, not just static analysis.

### Detect Test Runner

Determine test command from:

1. `config.yaml` (`project.test_runner`)
2. `package.json` (`scripts.test`)
3. `pyproject.toml` (`[tool.pytest]`)
4. `Makefile` (test target)
5. Default conventions (`go test ./...`, `cargo test`, etc.)

### Execute Tests

Run the test command and capture:

- **Total tests**
- **Passed tests**
- **Failed tests**
- **Skipped tests**
- **Exit code**

### Severity Assignment for Tests

- **CRITICAL** if exit code != 0 (tests failed)
- **PASS** if exit code == 0 (all tests passed)

### Detect Build Command

Determine build command from:

1. `config.yaml` (`rules.verify.build_command`)
2. `package.json` (`scripts.build`) — also run `tsc --noEmit` if `tsconfig.json` exists
3. `Makefile` (build target)
4. Default conventions (`cargo build`, `go build`, etc.)

### Execute Build

Run the build command and capture:

- **Exit code**
- **Errors**
- **Warnings**

### Severity Assignment for Build

- **CRITICAL** if build fails (exit code != 0)
- **WARNING** if build succeeds with warnings
- **PASS** if build succeeds without warnings

### Coverage Check (Optional)

Only run coverage if `rules.verify.coverage_threshold` is configured in `config.yaml`:

1. Run coverage tool
2. Capture coverage percentage
3. **WARNING** (not CRITICAL) if coverage < threshold

### Output

Return a summary:

```
Tests: {passed}/{total} passed, {failed} failed, {skipped} skipped (exit: {code})
Build: {status} (exit: {code})
Coverage: {percentage}% (threshold: {threshold}%)
Verdict: CRITICAL | WARNING | PASS
```
