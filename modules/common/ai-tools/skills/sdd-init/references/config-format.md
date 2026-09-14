# OpenSpec Config Format Reference

The `openspec/config.yaml` file defines project context and phase-specific rules for the SDD workflow.

## Schema

```yaml
project:
  name: string          # Project name (detected from manifest)
  stack: string          # Detected stack summary (e.g., "TypeScript, React, Vite")

testing:
  requested: boolean | null  # Explicit policy: true | false | null (unset)
  effective: string          # enabled | disabled | blocked
  blocker: string | null     # Reason when requested=true has no coverage
  roots:                     # One entry per command
    - root: string           # Relative project root
      working_dir: string    # Directory the command runs in
      surface: string        # runtime | nix-eval | nix-build | quality
      command: string        # e.g., "npm test", "nix flake check"
      covers: [string]       # Targets the command exercises
      covers_workspace: boolean

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
- `testing.effective` is derived from `testing.requested` plus executable
  coverage. An explicit `requested: true` without a workspace-wide runtime check
  resolves to `blocked`; it is never silently downgraded to `disabled`
- `testing.roots` keeps each runner/check with its own working directory and
  covered targets, so a monorepo never claims one root's runner for another
- Set `rules.apply.tdd` to `true` to enable the TDD workflow (RED → GREEN → REFACTOR)
- Set `rules.verify.coverage_threshold` to a percentage (e.g., `80`) to enforce coverage
