## Task Creation Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during task breakdown creation.

### MUST

- **Reference concrete file paths in every task** — Every task must specify which file(s) it affects
- **Order tasks by dependency** — Tasks in earlier phases must not depend on tasks in later phases
- **Use hierarchical numbering** — Format: `{phase}.{task}` (e.g., `1.1`, `1.2`, `2.1`)
- **Every task must be completable in ONE session** — If a task requires multiple sessions, break it down further
- **Return a structured envelope** — Include `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`

### MUST NOT

- **NEVER create vague tasks** — "Add auth" is wrong. "Create internal/auth/middleware.go with JWT validation" is correct.
- **NEVER create tasks without file paths** — Every task must reference specific files
- **NEVER exceed project-specific limits** — Check `config.yaml` for `rules.tasks.max_phase_size` and respect it

### SHOULD

- **Apply rules.tasks from config.yaml** — If `require_file_paths: true`, enforce it strictly
- **Integrate TDD tasks when configured** — If `rules.apply.tdd: true`, create RED → GREEN → REFACTOR task triplets
- **Keep phases to max 10 tasks each** — Unless `config.yaml` overrides with `max_phase_size`
- **Use existing test patterns** — If the project has `__tests__/` directories, follow that convention

### Task Quality Criteria

Each task must be:

| Criteria | Example (ok) | Anti-example (bad) |
|----------|-----------|----------------|
| **Specific** | "Create internal/auth/middleware.go with JWT validation" | "Add auth" |
| **Actionable** | "Write test for login failure scenario in auth_test.go" | "Consider testing" |
| **Verifiable** | "Run `go test ./internal/auth/...` — expect pass" | "Make sure it works" |
| **Small** | One file, one concern per task | "Implement entire feature" |

### Integration with config.yaml

If `rules.tasks` is defined in `openspec/config.yaml`:

```yaml
rules:
  tasks:
    require_file_paths: true      # Enforce file path in every task
    max_phase_size: 8             # Limit tasks per phase
```

Apply these constraints when creating tasks.
