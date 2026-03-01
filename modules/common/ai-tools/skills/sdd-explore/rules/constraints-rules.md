## Exploration Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD exploration phase.

### MUST

- ALWAYS read real code — never guess implementation details
- ALWAYS return a structured envelope with `status`, `executive_summary`, `detailed_report`, `artifacts`, `next_recommended`, `risks`
- Keep analysis concise — focus on actionable insights

### MUST NOT

- NEVER modify any existing code or files (exploration is read-only)
- NEVER create files unless tied to a named change in `openspec` mode
- NEVER fake confidence when uncertain — say "needs clarification on X"

### SHOULD

- Say clearly if not enough information is available
- Say what specific clarification is needed if request is too vague
- Present at least 2 approaches when feasible
- Use concrete file paths in all analysis sections
