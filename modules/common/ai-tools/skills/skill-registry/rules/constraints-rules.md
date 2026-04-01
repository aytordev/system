---
title: Constraints and Rules
impact: CRITICAL
impactDescription: Prevents incorrect registry generation
tags: constraints
---

## Constraints and Rules

**Impact: CRITICAL**

### Mandatory

- ALWAYS write `.atl/skill-registry.md` regardless of any SDD persistence mode
- ALWAYS save to engram if the `mem_save` tool is available
- SKIP `sdd-*`, `_shared`, `skill-registry`, and `skill-creator` directories when scanning
- Compact rules MUST be 5-15 lines per skill — concise, actionable, no fluff
- Read SKILL.md files (respecting the 200-line guard) to generate accurate compact rules
- Include ALL convention index files found (not just the first)
- If no skills or conventions are found, write an empty registry

### Forbidden

- Do NOT include SDD workflow skills in the registry (they are loaded by the orchestrator directly)
- Do NOT write compact rules longer than 15 lines per skill
- Do NOT include purpose/motivation text in compact rules
- Do NOT modify any source code or configuration files (except `.atl/` and `.gitignore`)
