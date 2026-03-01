## Detect Project Tech Stack and Conventions

**Impact: CRITICAL**

Read the project to understand what you are working with. This context informs all downstream SDD phases.

### What to Detect

1. **Tech stack** — Look for manifest files:
   - `package.json` (Node.js/TypeScript)
   - `go.mod` (Go)
   - `pyproject.toml` / `requirements.txt` (Python)
   - `Cargo.toml` (Rust)
   - `flake.nix` / `default.nix` (Nix)
   - `pom.xml` / `build.gradle` (Java/Kotlin)

2. **Existing conventions** — Look for:
   - Linters and formatters (`.eslintrc`, `.prettierrc`, `rustfmt.toml`, etc.)
   - Test frameworks (jest config, pytest markers, `_test.go` files)
   - CI/CD pipelines (`.github/workflows/`, `.gitlab-ci.yml`)

3. **Architecture patterns** — Identify:
   - Monorepo vs single package
   - Module/package boundaries
   - Existing directory conventions

### Output

Produce a concise summary of detected context:

```
Project: {name}
Stack: {languages, frameworks, build tools}
Test framework: {detected test runner}
Linter/formatter: {detected tools}
Architecture: {monorepo | single-package | library}
```
