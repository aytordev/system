---
title: Write the Registry
impact: HIGH
impactDescription: Defines the output format
tags: output, registry
---

## Write the Registry

**Impact: HIGH**

Build the registry markdown using this format:

```markdown
# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry
to resolve compact rules, then injects them directly into sub-agent prompts.
Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| {trigger from frontmatter} | {skill name} | {full path to SKILL.md} |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into
sub-agent prompts as `## Project Standards (auto-resolved)`.

### {skill-name-1}
- Rule 1
- Rule 2

### {skill-name-2}
- Rule 1
- Rule 2

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| {file} | {path} | {notes} |

Read the convention files listed above for project-specific patterns.
All referenced paths have been extracted — no need to read index files
to discover more.
```

### Key Rules

- If no skills are found, write an empty registry (so sub-agents don't waste time searching)
- If no conventions are found, omit the Project Conventions section
- Keep the same heading structure always — it's machine-parseable
