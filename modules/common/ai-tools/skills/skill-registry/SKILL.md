---
name: skill-registry
description: "Create or update the skill registry for the current project. Scans user skills and project conventions, generates compact rules (5-15 lines per skill), writes .atl/skill-registry.md, and saves to engram if available. Trigger: When user says 'update skills', 'skill registry', 'update registry', or after installing/removing skills."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Skill Registry

Generate or update the **skill registry** — a catalog of all available skills with **compact rules** (pre-digested, 5-15 line summaries) that any delegator injects directly into sub-agent prompts. Sub-agents do NOT read the registry or individual SKILL.md files — they receive compact rules pre-resolved in their launch prompt.

This is the foundation of the **Skill Resolver Protocol** (see `_shared/skill-resolver.md`). The registry is built ONCE (expensive), then read cheaply at every delegation.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Scanning | CRITICAL | `execution-scan` |
| 2 | Compact Rules | CRITICAL | `execution-generate` |
| 3 | Registry Output | HIGH | `execution-write` |
| 4 | Persistence | HIGH | `execution-persist` |

## Quick Reference

### 1. Scanning (CRITICAL)

- `execution-scan-skills` — Scan user and project skill directories
- `execution-scan-conventions` — Scan project convention files

### 2. Compact Rules (CRITICAL)

- `execution-generate-compact` — Generate 5-15 line rule summaries per skill

### 3. Registry Output (HIGH)

- `execution-write-registry` — Build the registry markdown

### 4. Persistence (HIGH)

- `execution-persist` — Write to .atl/ and engram
- `execution-return-summary` — Return structured summary

## Rules

- ALWAYS write `.atl/skill-registry.md` regardless of SDD persistence mode
- ALWAYS save to engram if `mem_save` tool is available
- SKIP `sdd-*`, `_shared`, and `skill-registry` directories when scanning
- Compact rules MUST be 5-15 lines per skill — concise, actionable, no fluff
- Add `.atl/` to `.gitignore` if it exists and `.atl` is not already listed

See `rules/constraints-rules.md` for complete rules.
