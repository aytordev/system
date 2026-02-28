## Verification Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD verification phase.

### MUST

- ALWAYS read actual source code — never rely on descriptions alone
- ALWAYS execute tests — static analysis alone is NOT sufficient
- A spec scenario is ONLY considered COMPLIANT when a test has PASSED during execution
- ALWAYS compare against SPECS first, then DESIGN
- ALWAYS return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`

### MUST NOT

- NEVER fix any issues found — only report them (verification is read-only)
- NEVER skip test execution (unless tests don't exist, which is CRITICAL)
- NEVER mark UNTESTED scenarios as COMPLIANT
- NEVER confuse static analysis (step 2) with runtime compliance (step 5)

### SHOULD

- Be objective and evidence-based
- Apply `rules.verify` settings from `config.yaml` when available
- Use severity levels consistently:
  - **CRITICAL** = must fix before archive
  - **WARNING** = should fix but won't block
  - **SUGGESTION** = improvements, not blockers
- Link issues to specific requirements and test results
