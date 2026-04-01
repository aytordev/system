---
title: Scan User and Project Skills
impact: CRITICAL
impactDescription: Foundation for the entire registry
tags: scanning, skills
---

## Scan User and Project Skills

**Impact: CRITICAL**

Glob for `*/SKILL.md` files across ALL known skill directories. Check every path — scan ALL that exist, not just the first match.

### User-level (global skills)

- `~/.claude/skills/`
- `~/.config/opencode/skills/`
- `~/.gemini/skills/`
- `~/.cursor/skills/`
- `~/.copilot/skills/`
- The parent directory of this skill file (catch-all)

### Project-level (workspace skills)

- `{project-root}/.claude/skills/`
- `{project-root}/.gemini/skills/`
- `{project-root}/.agent/skills/`
- `{project-root}/skills/`

### Filtering Rules

- **SKIP `sdd-*`** — SDD workflow skills, not coding/task skills
- **SKIP `_shared`** — shared conventions, not skills
- **SKIP `skill-registry`** — this skill
- **SKIP `skill-creator`** — meta-skill for creating skills

### Deduplication

If the same skill name appears in multiple locations, keep the **project-level** version (more specific). If both are user-level, keep the first found.

### Extraction

For each skill found, read the **full SKILL.md** to extract:
- `name` field (from frontmatter)
- `description` field → extract the trigger text (after "Trigger:" in the description)
- Rule files in `rules/` — read to generate compact rules (see `execution-generate-compact.md`)

If a SKILL.md exceeds 200 lines, focus on the frontmatter and first-level headings only.

### Output

Build a table of: `Trigger | Skill Name | Full Path`
