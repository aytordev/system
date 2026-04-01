---
title: Resolve Strict TDD Mode
impact: HIGH
impactDescription: Determines TDD enforcement in apply and verify phases
tags: testing, tdd
---

## Resolve Strict TDD Mode

**Impact: HIGH**

Determine whether Strict TDD Mode should be enabled. Resolution follows a priority chain — first match wins.

### Priority Chain

```
1. System prompt / agent config (highest priority):
   ├── Search for "strict-tdd-mode" marker in the agent's system prompt
   │   (CLAUDE.md, GEMINI.md, .cursorrules, opencode AGENTS.md)
   ├── If found and says "enabled" → strict_tdd: true
   ├── If found and says "disabled" → strict_tdd: false
   └── This is the preference set by the user

2. OpenSpec config:
   ├── Read openspec/config.yaml → strict_tdd field
   └── If found → use that value

3. Auto-enable if test runner detected:
   ├── If test runner was found in testing detection step
   ├── Default: strict_tdd: true
   └── This ensures TDD is active even without explicit config

4. No test runner detected:
   ├── strict_tdd: false
   └── Include NOTE: "Strict TDD Mode unavailable — no test runner detected"
```

### Rules

- Do NOT ask the user interactively — resolve from existing config
- The resolved value is persisted as part of testing capabilities
- sdd-apply reads this to decide whether to load the strict-tdd module
- sdd-verify reads this to decide whether to load the strict-tdd-verify module
