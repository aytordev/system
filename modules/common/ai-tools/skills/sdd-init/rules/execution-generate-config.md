## Generate Configuration File

**Impact: CRITICAL**

Create `openspec/config.yaml` declaring the resolved backend. Applies to every
persistent backend (`engram`, `openspec`, `hybrid`); `none` writes no config at
all.

### Declaration (all persistent backends)

The declaration is a single flat, same-line key. Substitute the **resolved**
backend literal — `engram`, `openspec`, or `hybrid` — never a default:

```yaml
artifact_store: {resolved-backend}
```

Never emit a nested mapping (`artifact_store:` with an indented `mode:`); the
pinned engine cannot see a nested declaration and would silently fall back to
`openspec`.

### Full Template (`openspec` and `hybrid` only)

```yaml
project:
  name: {project-name}
  stack: {detected stack summary}

artifact_store: {resolved-backend}

testing:
  requested: {true | false | unset}       # explicit policy only
  effective: {enabled | disabled | blocked}
  blocker: {reason or null}
  roots:
    - root: {relative path}
      working_dir: {path}
      surface: {runtime | nix-eval | nix-build | quality}
      command: {command}
      covers: [{targets}]
      covers_workspace: {true | false}

rules:
  proposal:
    require_rollback_plan: true
    require_success_criteria: true
  specs:
    require_scenarios: true
    use_rfc2119: true
  design:
    require_rationale: true
    require_file_changes: true
  tasks:
    require_file_paths: true
    max_phase_size: 10
  apply:
    tdd: false
    match_existing_patterns: true
  verify:
    run_tests: true
    run_build: true
    coverage_threshold: null
  archive:
    require_clean_verification: true
```

### Minimal Template (`engram` only)

`engram` permits only the declaration plus optional `project`/`rules` metadata.
No `testing` section and no other local content: testing capabilities are saved
to Engram in Step 2, not to this file.

```yaml
artifact_store: engram

project:
  name: {project-name}
  stack: {detected stack summary}

rules:
  apply:
    match_existing_patterns: true
```

### Guidelines

- Keep the context section CONCISE — no more than 10 lines
- Use detected values, do not guess or assume
- If a value cannot be detected, use `null` or omit it
- `testing.roots` records one entry per command with its working directory and
  covered targets; do not collapse roots into one `test_runner`
- `testing.requested` is the explicit policy; `testing.effective` is the resolved
  mode. Never write `effective: disabled` to hide a `blocked` request
- The `rules` section provides defaults that each phase's sub-agent reads
- The declaration substitutes the resolved backend literal; defaulting to
  `openspec` would silently misdirect the pinned engine
