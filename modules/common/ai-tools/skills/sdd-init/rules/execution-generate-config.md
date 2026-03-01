## Generate Configuration File

**Impact: CRITICAL**

Create `openspec/config.yaml` with the detected project context and phase-specific rules. Only applicable in `openspec` mode.

### Config Format

```yaml
project:
  name: {project-name}
  stack: {detected stack summary}
  test_runner: {detected test command}
  build_command: {detected build command}

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
- The `rules` section provides defaults that each phase's sub-agent reads
