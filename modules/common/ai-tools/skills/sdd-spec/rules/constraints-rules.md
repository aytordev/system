## Specification Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the specification phase.

### MUST

- ALWAYS read the proposal's **Capabilities section** first — it tells you exactly which spec files to create
- ALWAYS use Given/When/Then format for all scenarios
- ALWAYS use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY, MUST NOT) for requirement strength
- ALWAYS write delta specs when existing specs exist for that domain
- ALWAYS write full specs when no existing spec exists
- ALWAYS include at least one scenario per requirement
- ALWAYS include happy path AND edge case scenarios
- MODIFIED requirements MUST be the FULL block — copy entire requirement + all scenarios from main spec, then edit. Partial MODIFIED blocks lose content at archive time.
- Spec artifact MUST be under 650 words. Prefer requirement tables over narrative. Each scenario: 3-5 lines max.
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
