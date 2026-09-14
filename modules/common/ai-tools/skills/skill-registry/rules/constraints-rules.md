---
title: Constraints and Rules
impact: CRITICAL
impactDescription: Prevents incorrect index generation
tags: constraints
---

## Constraints and Rules

**Impact: CRITICAL**

### Mandatory

- The registry is an **index**. Always record `name`, full `description`, `scope`, exact `SKILL.md` path, and a `freshness` identity per skill.
- Read the full frontmatter `description`. Never require a literal `Trigger:` substring.
- Resolve precedence deterministically: project scope over global scope. Record every candidate when the same name appears at the same precedence tier.
- Surface shadowed and ambiguous duplicates in the registry; never silently keep the first-found entry.
- Index the full inventory, but mark invocation eligibility separately: `sdd-*` and `_shared` are phase-only.
- Read-only listing and `none` persistence mode MUST write nothing: no `.atl/`, no `.gitignore`, no Engram.
- In `engram` mode persist to Engram only; do not write project files.
- In `openspec`/`hybrid` (or explicit file persistence) write `.atl/skill-registry.md`.
- If no skills are found, produce an empty index so agents stop searching blindly.

### Forbidden

- Do NOT generate or inject compact rules or summaries as authoritative content. `SKILL.md` remains the source of truth.
- Do NOT replace the original runtime contract with a generated digest.
- Do NOT silently edit `.gitignore`.
- Do NOT flatten every path referenced by a root index into a global standard; preserve each subtree's scope.
- Do NOT modify any source code or configuration files.
