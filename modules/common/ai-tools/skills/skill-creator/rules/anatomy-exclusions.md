---
title: Exclude Auxiliary Files
impact: MEDIUM
impactDescription: Reduces clutter
tags: anatomy, exclusions
---

## Exclude Auxiliary Files

**Impact: MEDIUM**

Do not include `README.md`, `CHANGELOG.md`, or generic documentation. Only
include files the agent needs to do the job. The required package files are
`SKILL.md` and `metadata.json`; the optional directories are `rules/`,
`references/`, `scripts/`, `assets/`, and `modules/`.

**Incorrect (cluttered):**

```text
skill/
├── README.md
├── CHANGELOG.md
├── INSTALL.md
└── SKILL.md
```

**Correct (focused):**

```text
skill/
├── SKILL.md
├── metadata.json
└── rules/
    └── execution-steps.md
```
