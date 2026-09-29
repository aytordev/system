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

Ordinary local maintenance updates one of five authored packages:
`aytordev-pen-ops`, `dotfiles-coder`, `nix`, `skill-creator`, or `skill-registry`.
The sixth published skill, `impeccable`, is unmodified upstream content from
`pkgs.aytordev.impeccable-skills`, not an authored folder. Never add local
`metadata.json`, rewrite its frontmatter/references, or copy it into `skills/` to
satisfy this authoring contract. Its skill and engine pins/hashes belong together
in `modules/common/ai-tools/catalog.nix`; private preparation recipes live under
`modules/common/ai-tools/upstream/impeccable/`, with direct-import adapters in
`packages/`. These paths are target-repository context, not bundled resources.

The catalog classifies `dotfiles-coder` and `nix` as local, the other three
authored skills as adapted, and Impeccable as upstream. Maintain provenance in
the linked evidence documents. Creator/registry historical comparison revisions
are not original-import or last-synchronized revisions; those remain unknown.
Local descriptions and versions stay in frontmatter/metadata, not the catalog.

Preserve that inventory. Do not auto-expand it after discovering a useful
pattern. Obtain explicit approval for a new published skill before creating a
package under the repository's managed skills root.

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
6. **Publish**: add a `modules/common/ai-tools/catalog.nix` entry with the
   approved name, evidence-based kind, source path, manual update policy, and
   canonical provenance pointer. For adapted content, record the known origin
   repository/content path and baseline role/revision; keep unproven import/sync
   revisions null. Local independent content has no external update origin.
   Tracking is null unless a channel is explicitly configured; a manual policy
   does not establish one. `ai-skills.nix` derives the neutral collection
   and client sources from this data; do not add a second publication list.
   Preserve recursive file publication and the capability/client enable guards.
7. **Align the explicit policy**: update `modules/common/ai-tools/AGENTS.md` Current
   Inventory, its README, `checks/ai-tools-inventory` expected names,
   `checks/ai-tools-dependencies` client selections, and the name/publication
   expectations in `checks/gentle-ai-engine` and `checks/ai-skills-transition`.
   Historical old-layout fixtures and the one-time Pi transition script describe
   the old four-skill deployment; do not expand their old-source requirements.
8. **Validate** authored metadata, standalone export with Pi disabled, and
   realized client publication (below). Verify a dereferenced isolated folder
   still resolves its required resources. A source-only package
   will fail inventory or remain unavailable: do not call that complete. Keep
   these independent expectations; do not rebuild a runtime registry loader,
   automatic updater, or orchestrator.

### Validate

```sh
nix build \
  path:.#checks.aarch64-darwin.integration-ai-tools-skill-contract \
  path:.#checks.aarch64-darwin.unit-ai-tools-inventory \
  path:.#checks.aarch64-darwin.unit-ai-tools-dependencies \
  path:.#checks.aarch64-darwin.integration-gentle-ai-engine \
  path:.#checks.aarch64-darwin.integration-ai-skills-transition \
  path:.#checks.aarch64-darwin.integration-ai-tools-docs-links \
  path:.#checks.aarch64-darwin.integration-impeccable \
  --override-input secrets path:./checks/fixtures/secrets \
  --no-write-lock-file --no-link
```

The local contract check fails with the offending skill's name when an authored
directory is
missing `SKILL.md` or `metadata.json`, when `name` does not match the directory,
when `description` is not a single double-quoted YAML scalar, or when
`metadata.json` disagrees with the frontmatter. The ownership/transition checks
must also prove the collection works without clients, the approved files reach
enabled clients only, custom HOME/XDG paths work, isolated copies are complete,
and native files survive both the historical root transition and per-file skill
retirement. Upstream publication is checked against its complete packaged bytes
and isolated launcher, not local metadata/rule conventions. Native discovery and
the local registry read its standard `SKILL.md` without a metadata adapter. New
authored support-path conventions must be covered by
`checks/gentle-ai-engine/portable-folder.py`.

### Update and audit

1. Re-read the skill and compare it against the current contract rules.
2. Keep `SKILL.md` and `metadata.json` in agreement; frontmatter wins on conflict.
3. Preserve existing useful files; do not reorganize a package only to imitate
   another repository. For adapted content, manually compare the relevant source
   and retain deliberate local differences and notices; never imply an unknown
   synchronization baseline. For intact upstream content, change catalog pins
   only with explicit update approval and verify the sibling engine relationship.
4. Re-run metadata, inventory, dependency, and affected publication checks;
   update the inventory entry if the description changed without adding names.
