## Onboarding Rules and Prohibitions

**Impact: HIGH**

### MUST

- ALWAYS use the user's real codebase — no toy examples
- ALWAYS pause after Phase 2 (proposal) for user review before continuing
- ALWAYS narrate each phase in 1-3 sentences before executing it
- ALWAYS follow the format rules of the individual phase skills (sdd-propose, sdd-spec, etc.)
- ALWAYS produce production-quality artifacts — this is a real change, not a demo
- Return a structured envelope with `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`

### MUST NOT

- NEVER proceed past proposal without user confirmation
- NEVER use a change that is too large (multiple sessions), too risky (breaking changes), or not spec-worthy (no clear scenarios)
- NEVER launch sub-agents for phase work — execute each phase inline (you are the executor)
- NEVER skip the archive phase — the cycle must be complete

### SHOULD

- Adapt narration depth to the user: less explanation for experienced devs, more for beginners
- Keep narration SHORT — 1-3 sentences per phase. Teach, don't lecture.
- If anything blocks the cycle (build failure, unclear design, complex codebase), STOP and explain — don't push through
- If the user picks their own improvement, validate scope before accepting it
