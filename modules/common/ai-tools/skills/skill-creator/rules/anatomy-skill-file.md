---
title: SKILL.md Essentials
impact: CRITICAL
impactDescription: Primary interface for the agent
tags: anatomy, skill-md
---

## SKILL.md Essentials

**Impact: CRITICAL**

`SKILL.md` is the required entry point. It starts with a YAML frontmatter block
and a Markdown body. `name` and `description` are the only required fields;
`name` must equal the directory name.

**Required frontmatter:**

```markdown
---
name: my-skill
description: "Trigger: {essential words users or agents say}. {What this skill does}."
---
```

**Optional provenance** (kept in frontmatter when known):

```markdown
---
name: my-skill
description: "..."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---
```

Rules:

- `description` is a single physical line, double-quoted, and YAML-safe. It must
  not contain a literal newline or a block scalar (`>`/`|`).
- A literal `Trigger:` prefix is a useful convention, not a requirement. Full
  descriptions must remain discoverable without it.
- The body is a runtime contract: state activation conditions, hard rules, and
  execution steps. Push long material to `rules/` or `references/`.

**Incorrect (missing frontmatter):**

```markdown
# My Skill

Here is how to use this skill...
```

See `rules/anatomy-metadata.md` for how `name`/`description` relate to
`metadata.json`.
