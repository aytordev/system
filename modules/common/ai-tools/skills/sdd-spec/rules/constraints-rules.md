## Specification Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the specification phase.

### MUST

- ALWAYS use Given/When/Then format for all scenarios
- ALWAYS use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY, MUST NOT) for requirement strength
- ALWAYS write delta specs when existing specs exist for that domain
- ALWAYS write full specs when no existing spec exists
- ALWAYS include at least one scenario per requirement
- ALWAYS include happy path AND edge case scenarios
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`

### MUST NOT

- NEVER include implementation details (specs describe WHAT not HOW)
- NEVER create empty spec files
- NEVER write specs without scenarios
- NEVER mix delta and full spec formats in the same file

### SHOULD

- Keep scenarios testable and specific
- Apply `rules.specs` from `config.yaml` when available (e.g., `require_scenarios`, `use_rfc2119`)
- Group related requirements under the same domain
- Include error state scenarios for failure modes
- Use concrete examples in scenarios
