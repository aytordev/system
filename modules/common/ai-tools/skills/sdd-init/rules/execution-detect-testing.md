---
title: Detect Testing Capabilities
impact: CRITICAL
impactDescription: Downstream phases depend on per-root testing capabilities
tags: testing, detection
---

## Detect Testing Capabilities

**Impact: CRITICAL**

Scan the project for testing infrastructure **per project root**. A monorepo or
mixed stack has several roots; the capability record must keep their commands
separate. This determines which checks sdd-apply and sdd-verify may run, and
whether Strict TDD is executable.

### 1. Discover Project Roots

Walk the project tree and record every directory that contains a manifest:

| Manifest | Root kind |
|----------|-----------|
| `flake.nix` | Nix |
| `package.json` | JS/TS |
| `pyproject.toml`, `pytest.ini` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `Makefile` | make |

One root may hold several manifests. A nested manifest is its own root (a
monorepo package is a separate root); never collapse every root into a single
project-wide runner.

### 2. Associate Every Command With Its Root

For each root, record commands as structured entries — never as one command
string. Each entry carries the project root, the working directory, the covered
targets, and the surface. The `covers` field lists the covered targets:

```yaml
- root: packages/core         # project root (relative path)
  working_dir: packages/core  # directory the command runs in
  surface: runtime            # runtime | nix-eval | nix-build | quality
  command: npm test
  runner: vitest
  covers: [packages/core]     # targets the command actually exercises
  covers_workspace: false     # true only with declared workspace scope
```

`covers` is the key field: it states which targets the command exercises. A
runner declared in `packages/core` covers `packages/core`, not its sibling.

### 3. Classify Surfaces

`nix-eval`, `nix-build`, and `runtime` are different surfaces. Never call any of
them "the unit suite" interchangeably:

- **`nix-eval`** — `nix flake check` and evaluation-only checks. Evaluates the
  flake and its checks. It is not a derivation build and it is not a unit suite.
- **`nix-build`** — `nix build .#...`. Builds derivations. It proves the build
  succeeds, not that runtime tests ran.
- **`runtime`** — an executable test runner (`vitest`, `jest`, `pytest`,
  `go test`, `cargo test`). Only this surface can satisfy a unit, integration,
  or E2E layer, and only this surface can back Strict TDD.
- **`quality`** — linters, type checkers, formatters. Evidence for quality, not
  a test suite.

### Evidence Coverage, Do Not Assume It

`covers_workspace: true` requires evidence in the manifest: npm/yarn/pnpm
`workspaces`, a `--workspace` target, a pytest rootdir that spans every root, or
an explicit flake `checks` set covering every package. Without that evidence a
command covers only its own root. Never attribute one root's runner to another
root, and never treat a `nix-eval` or `nix-build` surface as a workspace test.

### 4. Test Layers and Quality Tools (per root)

Within each root:

```
Test Layers:
├── Unit: runtime runner exists for the root → AVAILABLE
├── Integration:
│   ├── JS/TS: @testing-library/* in dependencies
│   ├── Python: pytest + httpx/factory-boy
│   ├── Go: net/http/httptest (built-in)
│   └── Result: AVAILABLE or NOT INSTALLED
├── E2E:
│   ├── playwright, cypress, selenium in dependencies
│   └── Result: AVAILABLE or NOT INSTALLED
└── Each layer → record tool name, command, and root

Coverage Tool:
├── JS/TS: vitest --coverage, jest --coverage, c8, nyc
├── Python: coverage.py, pytest-cov
├── Go: go test -cover (built-in)
└── Result: {command, root} or NOT AVAILABLE

Quality Tools:
├── Linter: eslint, pylint, ruff, golangci-lint, clippy, statix (Nix)
├── Type checker: tsc --noEmit, mypy, pyright, go vet
├── Formatter: prettier, black, gofmt, nixfmt, alejandra
└── Each: {command, root} or NOT AVAILABLE
```

### Persist Testing Capabilities

This step is MANDATORY — downstream phases depend on this cache. Persist to the
resolved backend (`persistence-contract.md`); one-sided writes are not success.

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

**hybrid mode:** Do both — the `config.yaml` section AND the Engram observation —
with the partial-write/retry rules.

**none mode:** Return the capabilities inline in the envelope; persist nothing.

### Output Format

```markdown
## Testing Capabilities

**Strict TDD requested**: {true | false | unset}
**Strict TDD effective**: {enabled | disabled | blocked}
**Strict TDD blocker**: {reason or —}
**Detected**: {date}

### Project Roots
| Root | Manifests | Working directory | Command | Surface | Covers | Workspace-wide |
|------|-----------|-------------------|---------|---------|--------|----------------|
| . | flake.nix | . | `nix flake check` | nix-eval | workspace | yes |
| packages/core | package.json | packages/core | `npm test` | runtime | packages/core | no |

### Test Layers
| Root | Layer | Available | Tool |
|------|-------|-----------|------|
| packages/core | Unit | yes/no | {tool or —} |
| packages/core | Integration | yes/no | {tool or —} |
| packages/core | E2E | yes/no | {tool or —} |

### Coverage
| Root | Available | Command |
|------|-----------|---------|
| packages/core | yes/no | `{command or —}` |

### Quality Tools
| Root | Tool | Available | Command |
|------|------|-----------|---------|
| packages/core | Linter | yes/no | {command or —} |
| packages/core | Type checker | yes/no | {command or —} |
| packages/core | Formatter | yes/no | {command or —} |
```

Strict TDD fields are resolved by `execution-strict-tdd-resolution.md`, not
here. Detection only reports executable capability; it never enables or disables
the policy itself.
