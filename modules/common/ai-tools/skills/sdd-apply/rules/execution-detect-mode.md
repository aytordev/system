## Detect Implementation Mode (TDD vs Standard)

**Impact: CRITICAL**

Read cached testing capabilities to determine implementation mode.

### Read Testing Capabilities

```
Read from (in order):
├── engram: mem_search("sdd/{project}/testing-capabilities") → mem_get_observation(id)
├── openspec: openspec/config.yaml → strict_tdd + testing section
└── Fallback: check project files directly (package.json, go.mod, etc.)
```

### Mode Resolution

```
IF strict_tdd: true AND test runner exists
└── STRICT TDD MODE → Load and follow modules/strict-tdd.md
    (read the file at the skill directory level)

IF strict_tdd: false OR no test runner
└── STANDARD MODE → use execution-standard-workflow.md (no TDD module loaded)
```

**Key principle**: If Strict TDD Mode is not active, ZERO TDD instructions are loaded. The `strict-tdd.md` module is never read, never processed, never consumes tokens.

### Test Runner Detection (fallback)

If not cached, detect the test command from:

1. `config.yaml` → `project.test_runner`
2. `package.json` → `scripts.test`
3. `pyproject.toml` → `[tool.pytest]`
4. `Makefile` → `test:` target
5. `flake.nix` → `nix flake check`
6. **Fallback by stack**: `npm test`, `pytest`, `go test ./...`, `cargo test`

### Result

```
Mode: Strict TDD | Standard
Test runner: {command}
```
