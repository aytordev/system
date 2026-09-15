## Initialization Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD initialization phase.

### MUST

- ALWAYS detect the real tech stack from actual project files — never guess
- ALWAYS initialize the backend the orchestrator resolved, and honor an explicit
  backend choice exactly (`persistence-contract.md`)
- ALWAYS return a structured `sdd-result/v1` envelope with `schema`, `kind`,
  `status`, `executive_summary`, `artifacts`, `evidence`, `next_recommended`,
  `risks`, `skill_resolution`
- If `openspec/` already exists, report what exists and ask before updating
- If no backend is usable, STOP and ask before choosing one or creating artifacts

### MUST NOT

- NEVER create placeholder spec files during initialization
- NEVER choose `openspec` (or `hybrid`/`none`) automatically — only an explicit
  choice, an existing change's recorded backend, or available selected Engram
- NEVER write **persistence artifacts** from one backend into another's surface.
  Write only the resolved backend's own persistence: `engram` permits only
  `openspec/config.yaml` (the declaration plus optional `project`/`rules`
  metadata) and keeps every planning artifact in Engram; `openspec`/`hybrid`
  write only their documented `openspec/` layout; `none` writes nothing.
  Authorized implementation code edits are not persistence artifacts and are
  unaffected
- NEVER read a different store when the recorded backend is empty or unreadable —
  report the change as blocked instead (no silent cross-store fallback)

### SHOULD

- Keep `config.yaml` context CONCISE — no more than 10 lines for the project section
- Recommend a persistent backend (`engram` or `openspec`) only after asking, never
  by silently passing `none`
- Detect project roots and associate each runner/check with its working directory and covered targets
