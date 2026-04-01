---
title: Detect Testing Capabilities
impact: CRITICAL
impactDescription: Downstream phases depend on cached testing capabilities
tags: testing, detection
---

## Detect Testing Capabilities

**Impact: CRITICAL**

Scan the project for ALL testing infrastructure. This determines what testing modes are available for sdd-apply and sdd-verify.

### Detection Tree

```
Test Runner:
├── package.json → devDependencies: vitest, jest, mocha, ava
├── package.json → scripts.test (what command it runs)
├── pyproject.toml / pytest.ini → pytest
├── go.mod → go test (built-in)
├── Cargo.toml → cargo test (built-in)
├── flake.nix → nix flake check / nix build (Nix projects)
├── Makefile → make test
└── Result: {framework, command} or NOT FOUND

Test Layers:
├── Unit: test runner exists → AVAILABLE
├── Integration:
│   ├── JS/TS: @testing-library/* in dependencies
│   ├── Python: pytest + httpx/factory-boy
│   ├── Go: net/http/httptest (built-in)
│   └── Result: AVAILABLE or NOT INSTALLED
├── E2E:
│   ├── playwright, cypress, selenium in dependencies
│   └── Result: AVAILABLE or NOT INSTALLED
└── Each layer → record tool name

Coverage Tool:
├── JS/TS: vitest --coverage, jest --coverage, c8, nyc
├── Python: coverage.py, pytest-cov
├── Go: go test -cover (built-in)
└── Result: {command} or NOT AVAILABLE

Quality Tools:
├── Linter: eslint, pylint, ruff, golangci-lint, clippy, statix (Nix)
├── Type checker: tsc --noEmit, mypy, pyright, go vet
├── Formatter: prettier, black, gofmt, nixfmt, alejandra
└── Each: {command} or NOT AVAILABLE
```

### Persist Testing Capabilities

This step is MANDATORY — downstream phases depend on this cache.

**engram mode:**
```
mem_save(
  title: "sdd/{project-name}/testing-capabilities",
  topic_key: "sdd/{project-name}/testing-capabilities",
  type: "config",
  project: "{project-name}",
  content: "{testing capabilities markdown}"
)
```

**openspec mode:** Write as a section in `openspec/config.yaml` under `testing:`.

### Output Format

```markdown
## Testing Capabilities

**Strict TDD Mode**: {enabled/disabled/unavailable}
**Detected**: {date}

### Test Runner
- Command: `{command}`
- Framework: {name}

### Test Layers
| Layer | Available | Tool |
|-------|-----------|------|
| Unit | yes/no | {tool or —} |
| Integration | yes/no | {tool or —} |
| E2E | yes/no | {tool or —} |

### Coverage
- Available: yes/no
- Command: `{command or —}`

### Quality Tools
| Tool | Available | Command |
|------|-----------|---------|
| Linter | yes/no | {command or —} |
| Type checker | yes/no | {command or —} |
| Formatter | yes/no | {command or —} |
```
