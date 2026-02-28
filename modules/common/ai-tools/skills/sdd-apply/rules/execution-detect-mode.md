## Detect Implementation Mode (TDD vs Standard)

**Impact: CRITICAL**

Determine whether to use TDD workflow or standard implementation mode.

### Mode Detection Priority

Check in this order (first match wins):

1. **Explicit config** — `openspec/config.yaml`:
   ```yaml
   rules:
     apply:
       tdd: true  # or false
   ```

2. **Installed skills** — Check if user has TDD skills:
   - If `skills/tdd/SKILL.md` exists → TDD mode
   - If user's global skills include TDD → TDD mode

3. **Existing test patterns** — Analyze the codebase:
   - If existing tests follow TDD conventions (RED comments, test-first structure) → TDD mode
   - If tests exist but not TDD-style → Standard mode

4. **Default** — No tests, no config, no skills → **Standard mode**

### Test Runner Detection

Detect the test command from:

1. `config.yaml` → `project.test_runner`
2. `package.json` → `scripts.test`
3. `pyproject.toml` → `[tool.pytest]`
4. `Makefile` → `test:` target
5. **Fallback by stack**:
   - JavaScript/TypeScript: `npm test`
   - Python: `pytest`
   - Go: `go test ./...`
   - Rust: `cargo test`

### Result

Store detected mode and test runner for use in subsequent execution steps:

```
Mode: TDD
Test runner: npm test -- auth.test.ts
```

or

```
Mode: Standard
Test runner: (not applicable)
```
