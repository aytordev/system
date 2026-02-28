## Initialization Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD initialization phase.

### MUST

- ALWAYS detect the real tech stack from actual project files — never guess
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`
- If `openspec/` already exists, report what exists and ask before updating

### MUST NOT

- NEVER create placeholder spec files during initialization
- NEVER choose `openspec` mode automatically — only when explicitly passed by the orchestrator
- NEVER write project files when mode is `engram` or `none`

### SHOULD

- Keep `config.yaml` context CONCISE — no more than 10 lines for the project section
- Recommend `engram` or `openspec` when falling back to `none` mode
- Detect test runner and build commands when possible
