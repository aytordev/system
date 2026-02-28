## Design Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the technical design phase.

### MUST

- ALWAYS read the actual codebase before designing
- ALWAYS provide a rationale for every architecture decision
- ALWAYS include concrete file paths in the File Changes section
- ALWAYS use ASCII diagrams for data flow (keep simple, box-and-arrow style)
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`
- If open questions BLOCK the design, set `status: blocked` and explain clearly

### MUST NOT

- NEVER design without reading the codebase first
- NEVER use generic best practices that conflict with the project's actual patterns
- NEVER use vague file descriptions ("update auth module" instead of `src/routes/auth.ts`)
- NEVER use complex UML diagrams (ASCII box-and-arrow is sufficient)

### SHOULD

- Follow existing project patterns (if codebase uses pattern X, design with X not Y)
- Apply `rules.design` from `config.yaml` when available (e.g., `require_rationale`, `require_file_changes`)
- Include both happy path and error handling in data flow diagrams
- List open questions as a checklist (makes it easy to track resolution)
- Keep the Technical Approach section to one paragraph (executive summary, not essay)
