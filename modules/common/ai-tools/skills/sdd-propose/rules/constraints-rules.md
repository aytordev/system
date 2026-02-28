## Proposal Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD proposal phase.

### MUST

- ALWAYS create `proposal.md` in `openspec` mode (write to file system)
- Every proposal MUST have a rollback plan — this is non-negotiable
- Every proposal MUST have success criteria with checkboxes
- Use concrete file paths in Affected Areas table
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`

### MUST NOT

- NEVER skip the rollback plan section
- NEVER skip the success criteria section
- NEVER use vague file references like "the module" or "the service"
- NEVER write a new proposal without reading existing one first (if it exists)

### SHOULD

- If change directory already exists with a proposal, READ first and UPDATE
- Keep proposal concise — aim for 1-2 pages
- Apply `rules.proposal` from `openspec/config.yaml` if available
- Use the template from `references/proposal-template.md` as the base structure
- Be specific about risks and mitigations
