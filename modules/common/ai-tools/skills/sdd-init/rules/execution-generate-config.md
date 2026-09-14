## Generate Configuration File

**Impact: CRITICAL**

Create `openspec/config.yaml` with the detected project context and phase-specific rules. Only applicable in `openspec` mode.

### Config Format

```yaml
project:
  name: {project-name}
  stack: {detected stack summary}

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

artifact_store:
  mode: openspec

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

### Guidelines

- Keep the context section CONCISE — no more than 10 lines
- Use detected values, do not guess or assume
- If a value cannot be detected, use `null` or omit it
- `testing.roots` records one entry per command with its working directory and
  covered targets; do not collapse roots into one `test_runner`
- `testing.requested` is the explicit policy; `testing.effective` is the resolved
  mode. Never write `effective: disabled` to hide a `blocked` request
- The `rules` section provides defaults that each phase's sub-agent reads
