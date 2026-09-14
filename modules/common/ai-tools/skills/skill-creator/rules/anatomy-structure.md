---
title: Standard Directory Structure
impact: CRITICAL
impactDescription: Defines the supported package layout
tags: anatomy, structure
---

## Standard Directory Structure

**Impact: CRITICAL**

Every skill is a directory with `SKILL.md` as the entry point and
`metadata.json` beside it. Supporting directories are optional and are added
only when they carry real content.

```text
my-skill/
├── SKILL.md          (required) entry point + YAML frontmatter
├── metadata.json     (required) catalog metadata; agrees with frontmatter
├── rules/            (optional) focused execution rules and constraints
├── references/       (optional) detailed knowledge, schemas, templates
├── scripts/          (optional) deterministic or fragile helpers
├── assets/           (optional) files the agent emits or consumes
└── modules/          (optional) conditional, runtime-loaded modules
```

- `rules/` splits long guidance into one concern per file; `SKILL.md` indexes them.
- `references/` holds material read only when a task needs it.
- `scripts/` is for logic that must run deterministically instead of being described.
- `assets/` is for output resources (templates, images, fonts).
- `modules/` is reserved for conditional content loaded at runtime by a
  specific skill (for example `sdd-apply/modules/strict-tdd.md`).

Do not create a directory that stays empty, and do not move existing useful
files just to imitate another repository's tree.

**Incorrect (unstructured):**

```text
my-skill/
├── README.txt
├── code.py
├── doc.pdf
└── skill_info.md
```

**Correct (contract):**

```text
my-skill/
├── SKILL.md
├── metadata.json
└── rules/
    └── execution-steps.md
```
