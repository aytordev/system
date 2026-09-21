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

This file is a local validation convention, not a universal runtime field.
Clients discover standard `SKILL.md` frontmatter; its optional `metadata` field
is a string-to-string map, distinct from this repository's JSON file.

- Must be a JSON object that parses.
- `name` and `description` are duplicates of the frontmatter and must match it
  exactly.
- `version` and `organization` are required catalog fields.
- `date` and `abstract` are optional and may carry additional catalog detail.
- `dependencies` is an optional array naming other required skills. The current
  four-folder collection must be independently consumable, so its packages have
  no sibling dependencies. Bundle necessary references/scripts within the skill.
- It never overrides the frontmatter. When the two disagree, the frontmatter is
  correct and `metadata.json` is stale.

`checks/ai-tools-dependencies` validates the declared graph: every reference
resolves to a skill, the graph is acyclic, each selected set is closed, and the
four portable packages have no sibling dependencies. The `ai-skills` capability
exports the neutral collection independently of clients and publishes the same
folders recursively to enabled clients. Neither client's whole skills root is
owned by Home Manager; resolver support lives inside `skill-registry/references/`.

`checks/ai-tools-skill-contract` enforces this: it lists every skill directory,
reads the frontmatter, and fails with the offending skill's name if `name` does
not match the directory or if `metadata.json` disagrees with the frontmatter.

Do not remove `metadata.json` while consumers exist; keep it consistent instead.
Legacy packages without `license`/`author` are valid; add provenance when
touching a skill rather than inventing it.
