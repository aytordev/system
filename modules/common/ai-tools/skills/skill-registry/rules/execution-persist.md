---
title: Persist the Local Registry
impact: HIGH
impactDescription: Only explicitly requested persistence writes an index
tags: persistence, engram, filesystem
---

## Persist the Local Registry

Resolve persistence from this invocation only. Default to **session-only**;
do not inherit Shell or another workflow's artifact policy.

| Mode | Target |
|------|--------|
| `none` (default) | Return the index inline; write nothing |
| `file` | Explicit local collection index `.ai-local/skill-registry.md` |
| `engram` | Engram topic `aytordev/local-skill-registry`; no project files |

For `file`, create the parent only after the user requests file persistence.
Read any existing target before replacing it. Refuse unrelated content; rebuild
stale indexes from original `SKILL.md` files rather than transcribing summaries.
Never overwrite `.atl/skill-registry.md`: the official Shell owns that generated
index. Do not edit `.gitignore`; mention the local index's tracking status.

For `engram`, use available native memory tools to resolve the current project
and save/upsert the full index with title `Local skill registry`, type `config`,
topic key `aytordev/local-skill-registry`, and `capture_prompt: false`. Do not
invent a project or session identity. Report unavailable tools or a failed save
and return the index inline; do not silently switch to file persistence.

Read back a persisted index to confirm its fields and exact paths. This skill
does not migrate legacy workflow artifacts, schedule refreshes, or inject prompts.
