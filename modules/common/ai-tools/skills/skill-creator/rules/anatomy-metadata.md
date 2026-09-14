---
title: Metadata Authority
impact: CRITICAL
impactDescription: Prevents competing sources of truth
tags: anatomy, metadata
---

## Metadata Authority

**Impact: CRITICAL**

`name` and `description` are stored twice: in `SKILL.md` frontmatter and in
`metadata.json`. There is exactly one canonical source.

**Canonical: `SKILL.md` frontmatter.**

- `name` — must equal the skill directory name.
- `description` — single physical line, double-quoted, YAML-safe.
- `license`, `metadata.author`, `metadata.version` — optional provenance, kept
  in frontmatter when the source and license are known.

**Derived projection: `metadata.json`.**

- Must be a JSON object that parses.
- `name` and `description` are duplicates of the frontmatter and must match it
  exactly.
- `version` and `organization` are required catalog fields.
- `date` and `abstract` are optional and may carry additional catalog detail.
- `dependencies` is an optional array naming the skills this skill requires at
  runtime. Each entry is another skill directory name or the shared protocol
  bundle `_shared` (which is not a skill and has no outgoing edges). Declare
  only real requirements: do not parse prose mentions into edges.
- It never overrides the frontmatter. When the two disagree, the frontmatter is
  correct and `metadata.json` is stale.

`checks/ai-tools-dependencies` validates the declared graph: every reference
resolves to a skill or `_shared`, the graph is acyclic, and each client's
selected-skill set is closed under its dependencies (both deployed clients link
the whole skills tree).

`checks/ai-tools-skill-contract` enforces this: it lists every skill directory,
reads the frontmatter, and fails with the offending skill's name if `name` does
not match the directory or if `metadata.json` disagrees with the frontmatter.

Do not remove `metadata.json` while consumers exist; keep it consistent instead.
Legacy packages without `license`/`author` are valid; add provenance when
touching a skill rather than inventing it.
