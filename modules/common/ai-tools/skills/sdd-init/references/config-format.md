# OpenSpec Config Format Reference

The `openspec/config.yaml` file defines project context and phase-specific rules for the SDD workflow.

## Schema

```yaml
project:
  name: string          # Project name (detected from manifest)
  stack: string          # Detected stack summary (e.g., "TypeScript, React, Vite")
  test_runner: string    # Test command (e.g., "npm test", "pytest", "go test ./...")
  build_command: string  # Build command (e.g., "npm run build", "cargo build")

artifact_store:
  mode: string           # engram | openspec | none

rules:
  proposal:
    require_rollback_plan: boolean
    require_success_criteria: boolean
  specs:
    require_scenarios: boolean
    use_rfc2119: boolean
  design:
    require_rationale: boolean
    require_file_changes: boolean
  tasks:
    require_file_paths: boolean
    max_phase_size: integer
  apply:
    tdd: boolean
    match_existing_patterns: boolean
  verify:
    run_tests: boolean
    run_build: boolean
    coverage_threshold: number | null
  archive:
    require_clean_verification: boolean
```

## Notes

- All `rules.*` fields are optional — sub-agents use sensible defaults when not specified
- The `project.stack` field should be a concise comma-separated summary
- Set `rules.apply.tdd` to `true` to enable TDD workflow (RED → GREEN → REFACTOR)
- Set `rules.verify.coverage_threshold` to a percentage (e.g., `80`) to enforce coverage
