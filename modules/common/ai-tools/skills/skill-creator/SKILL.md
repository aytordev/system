---
name: skill-creator
description: "Trigger: new skills, updating agent instructions, auditing skill packages. Author and maintain skills in this repository's supported layout."
compatibility: "Requires filesystem read access; authoring needs write access, and repository verification needs a terminal and Nix."
---

# Skill Creator

Authoritative authoring contract for skills under
`modules/common/ai-tools/skills/`. A skill is a runtime instruction contract
for an LLM, not human documentation. Keep `SKILL.md` concise and let supporting
files carry detail.

Use equivalent tools supplied by the host, not a particular client's tool names.
Supporting paths are relative to this skill folder; repository paths identify
the target checkout. `metadata.json` is required by this repository's validation,
not by every Agent Skills host. A host unable to read support files or run checks
must report that limit rather than claiming an authored skill was verified.

## Activation Contract

Use this skill when:

- Adding a new skill or updating an existing one.
- Auditing a skill for layout or metadata compliance.
- Deciding where content belongs (`rules/`, `references/`, `scripts/`, `assets/`, `modules/`).

## Hard Rules

- `SKILL.md` is the required portable entry point; it starts with a YAML frontmatter block.
- `metadata.json` is required and must agree with `SKILL.md` frontmatter
  (see `rules/anatomy-metadata.md`).
- Frontmatter is canonical for `name` and `description`; the directory name must equal `name`.
- `description` is one physical line, double-quoted, YAML-safe. No literal
  `Trigger:` marker is required.
- Keep `SKILL.md` concise and runtime-oriented; push detail into `rules/` or `references/`.
- Do not add `scripts/` or `assets/` until a reusable resource actually exists.
- Validate before finishing; do not hand-maintain a parallel description.
- Ordinary maintenance preserves the published-skill inventory. Creation of another
  repository-published skill requires explicit approval to expand that policy;
  authoring a source package alone does not publish it.

## Decision Gates

| Need | Where it goes |
| --- | --- |
| Focused execution rules, split by concern | `rules/` |
| Detailed knowledge, schemas, templates, long examples | `references/` |
| Deterministic or fragile logic better run than described | `scripts/` |
| Files the agent emits or consumes as output | `assets/` |
| Conditional, runtime-loaded modules | `modules/` |
| Identity and catalog fields | `SKILL.md` frontmatter + `metadata.json` |

## Execution Steps

1. Distinguish maintenance from explicitly approved inventory expansion. For
   creation, confirm approval, reusable value, and no same-named skill.
2. Create `skills/<name>/SKILL.md` with valid frontmatter.
3. Add `metadata.json` mirroring `name` and `description`, plus `version` and `organization`.
4. Add supporting content in the directories selected above.
5. For approved expansion, update the neutral collection's source, the `ai-skills` publication list, documented
   inventory, and explicit inventory/dependency/publication expectations together
   (see `rules/process-steps.md`). Do not recreate a workflow catalog or orchestrator.
6. Verify metadata, standalone collection export, and actual client publication,
   including disabled-client guards and isolated-folder resource resolution.
7. Audit or update by re-applying these rules; keep provenance honest.

## Output Contract

Return files created/modified, the layout directories chosen, approval scope,
and metadata/publication validation results. Do not report a new skill as
available merely because its source files exist.

## References

- `rules/anatomy-structure.md` — supported directory layout.
- `rules/anatomy-skill-file.md` — frontmatter essentials.
- `rules/anatomy-metadata.md` — frontmatter vs `metadata.json` authority.
- `rules/anatomy-exclusions.md` — files to exclude.
- `rules/content-assets.md`, `rules/content-references.md`, `rules/content-scripts.md` — where content belongs.
- `rules/principles-concise.md`, `rules/principles-degrees-of-freedom.md`, `rules/principles-progressive.md` — authoring principles.
- `rules/process-steps.md` — full create/update/audit workflow.
