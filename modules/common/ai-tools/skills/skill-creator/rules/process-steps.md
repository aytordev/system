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
no such helpers exist here. Metadata and publication checks validate delivery.

### Choose the scope

Ordinary maintenance updates one of `dotfiles-coder`, `nix`, `skill-creator`, or
`skill-registry` and preserves that inventory. Do not auto-expand it after
discovering a useful pattern. Obtain explicit approval for a new published skill
before creating a package under the repository's managed skills root.

### Create after explicit inventory-expansion approval

1. **Understand**: collect concrete, repeated examples that justify a skill.
2. **Plan**: decide which supporting directories are needed (`rules/`,
   `references/`, `scripts/`, `assets/`, `modules/`) and what each holds.
3. **Write `SKILL.md`**: frontmatter (`name`, `description`) plus a concise
   runtime body. Follow the structure in the references.
4. **Write `metadata.json`**: mirror `name` and `description`, and add
   `version` and `organization`.
5. **Add supporting files** only where they carry real content.
   Keep every required support file inside its skill folder. Use skill-relative
   resources, and label target-repository paths as domain context, not bundled
   resources. Record filesystem/terminal requirements without mandating one
   client's tool names. `metadata.json` serves this repo's validation only.
6. **Publish**: the new source folder joins the neutral XDG collection; add its name to `names` in
   `modules/common/ai-tools/ai-skills.nix`. Preserve recursive
   file publication and the capability/client enable guards.
7. **Align the explicit policy**: update `modules/common/ai-tools/AGENTS.md` Current
   Inventory, its README, `checks/ai-tools-inventory` expected names,
   `checks/ai-tools-dependencies` client selections, and the name/publication
   expectations in `checks/gentle-ai-engine` and `checks/ai-skills-transition`.
   Historical old-layout fixtures and the one-time Pi transition script describe
   the old four-skill deployment; do not expand their old-source requirements.
8. **Validate** metadata, standalone export with both clients disabled, and
   realized client publication (below). Verify a dereferenced isolated folder
   still resolves its required resources. A source-only package
   will fail inventory or remain unavailable: do not call that complete. Keep
   this explicit list; do not rebuild a workflow registry loader or orchestrator.

### Validate

```sh
nix build \
  path:.#checks.aarch64-darwin.integration-ai-tools-skill-contract \
  path:.#checks.aarch64-darwin.unit-ai-tools-inventory \
  path:.#checks.aarch64-darwin.unit-ai-tools-dependencies \
  path:.#checks.aarch64-darwin.integration-gentle-ai-engine \
  path:.#checks.aarch64-darwin.integration-ai-skills-transition \
  --override-input secrets path:./checks/fixtures/secrets \
  --no-write-lock-file --no-link
```

The check fails with the offending skill's name when a skill directory is
missing `SKILL.md` or `metadata.json`, when `name` does not match the directory,
when `description` is not a single double-quoted YAML scalar, or when
`metadata.json` disagrees with the frontmatter. The ownership/transition checks
must also prove the collection works without clients, the approved files reach
enabled clients only, custom HOME/XDG paths work, isolated copies are complete,
and native files survive the existing layout transition. New support-path
conventions must be covered by `checks/gentle-ai-engine/portable-folder.py`.

### Update and audit

1. Re-read the skill and compare it against the current contract rules.
2. Keep `SKILL.md` and `metadata.json` in agreement; frontmatter wins on conflict.
3. Preserve existing useful files; do not reorganize a package only to imitate
   another repository.
4. Re-run metadata, inventory, dependency, and affected publication checks;
   update the inventory entry if the description changed without adding names.
