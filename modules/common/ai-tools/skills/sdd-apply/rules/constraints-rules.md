## Implementation Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during task implementation.

### MUST

- **Read specs before implementing** — Never implement without understanding the requirements
- **Follow design decisions** — The design describes HOW to implement; follow it unless you find a critical flaw
- **Match existing code patterns** — Especially when `rules.apply.match_existing_patterns: true` in config.yaml
- **Mark tasks complete as you go** — Update tasks.md after each task
- **Load and follow relevant coding skills** — If the project has custom coding conventions or patterns loaded as skills, apply them

### MUST NOT

- **NEVER implement unassigned tasks** — If you were assigned tasks 1.1-1.3, do NOT implement 1.4 "while you're at it"
- **NEVER silently deviate from design** — If you must deviate, note it explicitly in the detailed report
- **NEVER skip reading existing code** — Matching project patterns is critical for maintainability
- **NEVER run the entire test suite** — Only run relevant tests (file or directory)

### SHOULD

- **Apply rules.apply from config.yaml** — Respect project-specific implementation rules
- **Run only relevant test file/suite** — Not the entire test suite (slow, noisy)
- **If design is wrong/incomplete, NOTE IT** — Don't silently work around design flaws; report them
- **If blocked, STOP and report** — Return `status: "blocked"` with clear explanation

### Deviation Handling

If the design conflicts with reality:

**Example 1: Non-existent dependency**

```
Design says: Use @/lib/jwt for token generation
Reality: No such module exists, but `jsonwebtoken` package is installed

Action:
1. Use jsonwebtoken package
2. Note deviation: "Design specified @/lib/jwt (non-existent); used jsonwebtoken package instead"
3. Suggest: "Recommend updating design.md to reflect actual dependency"
```

**Example 2: Pattern mismatch**

```
Design says: Implement as class with methods
Reality: Entire codebase uses functional approach

Action (if rules.apply.match_existing_patterns: true):
1. Implement as functions
2. Note deviation: "Design specified class-based implementation; used functional approach to match existing codebase patterns"
```

### Blocking Conditions

Return `status: "blocked"` if:

1. **Missing dependencies** — Required libraries or modules don't exist and can't be installed
2. **Contradictory requirements** — Specs and design conflict
3. **Impossible task** — Task cannot be completed as described (e.g., "modify non-existent file")
4. **Critical design flaw** — Design approach is fundamentally broken

**Blocked response format:**

```json
{
  "status": "blocked",
  "executive_summary": "Cannot implement task 2.1: required dependency @/lib/jwt does not exist",
  "detailed_report": "...",
  "next_recommended": "design (update to use jsonwebtoken package)",
  "risks": ["Implementation stalled until design is updated"]
}
```

### Integration with config.yaml

If `rules.apply` is defined in `openspec/config.yaml`:

```yaml
rules:
  apply:
    tdd: true                        # Use TDD workflow
    match_existing_patterns: true    # Prioritize consistency over design
```

Apply these rules during implementation.
