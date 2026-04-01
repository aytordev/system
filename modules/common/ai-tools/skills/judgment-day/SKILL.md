---
name: judgment-day
description: "Parallel adversarial review protocol. Launches two independent blind judge sub-agents simultaneously to review the same target, synthesizes findings, applies fixes, and re-judges until both pass or escalates. Trigger: When user says 'judgment day', 'judgment-day', 'review adversarial', 'dual review', 'double review', 'juzgar', 'que lo juzguen'."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Judgment Day

Parallel adversarial review protocol that launches two independent blind judge sub-agents simultaneously to review the same target, synthesizes findings, applies fixes, and re-judges until convergence.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Execution Flow | CRITICAL | `execution` |
| 2 | Templates | HIGH | `templates` |
| 3 | Constraints | CRITICAL | `constraints` |

## Quick Reference

### 1. Execution Flow (CRITICAL)

- `execution-skill-resolution` — Resolve skills from registry before launching judges (Pattern 0)
- `execution-parallel-review` — Launch two blind judge sub-agents in parallel (Pattern 1)
- `execution-verdict-synthesis` — Compare results: confirmed, suspect, contradiction (Pattern 2)
- `execution-warning-classify` — Classify WARNING as real vs theoretical (Pattern 3)
- `execution-fix-rejudge` — Fix Agent + re-judge cycle (Pattern 4)
- `execution-convergence` — Threshold rules and escalation (Pattern 5)

### 2. Templates (HIGH)

- `templates-judge-prompt` — Judge and Fix Agent prompt templates

### 3. Constraints (CRITICAL)

- `constraints-rules` — Blocking rules and self-check protocol

## Decision Tree

```
User asks for "judgment day"
├── Target specific? → YES: continue / NO: ask user to specify
▼
Resolve skills (Pattern 0): read registry → match → build Project Standards
▼
Launch Judge A + Judge B in parallel (delegate, async)
▼
Wait for both → Synthesize verdict
├── No issues → JUDGMENT: APPROVED
├── Issues found → Present verdict table, ASK user
│   ├── YES → Fix Agent → re-judge (Round 2)
│   ├── NO → JUDGMENT: ESCALATED
│   └── After 2 iterations with remaining issues → ASK to continue
```

## Rules

- The orchestrator NEVER reviews code itself — only launches judges
- Judges MUST be launched in parallel — never sequential
- Fix Agent is a SEPARATE delegation — never reuse a judge as fixer
- After 2 fix iterations, ASK user before continuing
- NEVER declare APPROVED until both judges return clean

See `rules/constraints-rules.md` for complete blocking rules.
