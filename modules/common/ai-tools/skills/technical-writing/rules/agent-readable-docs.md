---
title: Write for AI Agents Too
impact: HIGH
impactDescription: Developer docs now have two audiences
tags: technical-writing, agents, tables
---

## Write for AI Agents Too

**Impact: HIGH**

Developer docs now have two audiences. Agent-readable means:

- **Enumerable over prose-only**: anything an agent must choose from —
  options, flags, exit codes, states — appears in a table row, not only
  inside a paragraph.
- **Preconditions and postconditions per operation**: what must be true
  before, what changes after, what exit codes mean. A state-machine table
  ("in state X, the one correct next action is Y") outperforms narrative for
  both audiences.
- **Exact strings**: agents (and humans under pressure) copy-paste. Give the
  exact command, the exact config block, the exact error message — never a
  paraphrase.

Supporting detail — the honest `llms.txt` verdict, clean-source endpoints,
retrievability rules, and the time-sensitivity evidence rule — lives in
`references/agent-docs.md`.
