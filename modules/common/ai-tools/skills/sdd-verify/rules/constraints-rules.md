## Verification Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD verification phase.

### MUST

- ALWAYS read actual source code — never rely on descriptions alone
- ALWAYS execute tests — static analysis alone is NOT sufficient
- ALWAYS validate requirement/scenario counts against both supported spec grammars (`#### Scenario:` and `**Scenario:**`)
- ALWAYS bind results to the candidate revision; re-run or downgrade stale evidence
- A spec scenario is ONLY considered COMPLIANT when a test has PASSED during execution
- ALWAYS compare against SPECS first, then DESIGN
- ALWAYS return a structured `sdd-result/v1` envelope with `schema`, `kind`, `status`, `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`, `skill_resolution`
- ALWAYS make the persisted report's **first non-empty line** the engine `gentle-ai.verify-result/v1` fence and validate it through `aytordev-sdd verify` (see `execution-return-report.md` and `_shared/closure-policy.md`)
- ALWAYS bind `evidence_revision` in that fence to the candidate revision so the C11 archive gate can refuse a stale report

### MUST NOT

- NEVER fix any issues found — only report them (verification is read-only)
- NEVER skip test execution (unless tests don't exist, which is CRITICAL)
- NEVER mark UNTESTED scenarios as COMPLIANT
- NEVER report a count that does not match the parsed spec
- NEVER treat stale (post-change) evidence as current
- NEVER confuse static analysis (step 2) with runtime compliance (step 5)

### SHOULD

- Be objective and evidence-based
- Apply `rules.verify` settings from `config.yaml` when available
- Use severity levels consistently:
  - **CRITICAL** = must fix before archive
  - **WARNING** = should fix but won't block
  - **SUGGESTION** = improvements, not blockers
- Link issues to specific requirements and test results
