---
title: Follow the Creation Process
impact: HIGH
impactDescription: Ensures quality and consistency
tags: process
---

## Follow the Creation Process

**Impact: HIGH**

Author skills by hand in the repository. There is no initializer or packager
script; those instructions were inherited from another repo and removed because
no such helpers exist here. The contract check is the supported validation step.

### Create

1. **Understand**: collect concrete, repeated examples that justify a skill.
2. **Plan**: decide which supporting directories are needed (`rules/`,
   `references/`, `scripts/`, `assets/`, `modules/`) and what each holds.
3. **Write `SKILL.md`**: frontmatter (`name`, `description`) plus a concise
   runtime body. Follow the structure in the references.
4. **Write `metadata.json`**: mirror `name` and `description`, and add
   `version` and `organization`.
5. **Add supporting files** only where they carry real content.
6. **Validate** (see below).
7. **Register** the skill in `modules/common/ai-tools/AGENTS.md` Current Inventory.

### Validate

```sh
nix build .#checks.aarch64-darwin.integration-ai-tools-skill-contract
```

The check fails with the offending skill's name when a skill directory is
missing `SKILL.md` or `metadata.json`, when `name` does not match the directory,
when `description` is not a single double-quoted YAML scalar, or when
`metadata.json` disagrees with the frontmatter.

### Update and audit

1. Re-read the skill and compare it against the current contract rules.
2. Keep `SKILL.md` and `metadata.json` in agreement; frontmatter wins on conflict.
3. Preserve existing useful files; do not reorganize a package only to imitate
   another repository.
4. Re-run the check and update the inventory entry if the description changed.
