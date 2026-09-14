---
title: Write the Registry Index
impact: HIGH
impactDescription: Defines the index format consumed by delegators
tags: output, registry, index
---

## Write the Registry Index

**Impact: HIGH**

Build the registry markdown using this format:

```markdown
# Skill Registry

**Index, not a compiler.** `SKILL.md` is the source of truth. Delegators pass
exact `SKILL.md` paths; executors read the selected originals plus the references
they need. Generated summaries are not authoritative.

See `_shared/skill-resolver.md` for the full resolution protocol.

## Index

| Name | Description | Scope | Path | Freshness |
|------|-------------|-------|------|-----------|
| {skill name} | {complete frontmatter description} | project \| global | {exact absolute path to SKILL.md} | {sha256:... or size:mtime} |

## Shadowed / Ambiguous

| Name | Kept | Shadowed | Reason |
|------|------|----------|--------|
| {name} | {kept path} | {other path(s)} | {same-scope duplicate / shadowed by project} |

## Project Conventions

| File | Path | Scope | Notes |
|------|------|-------|-------|
| {file} | {path} | {subtree it governs} | {notes} |

## Invocation Eligibility

- Domain skills (all non-`sdd-*`, non-`_shared` entries above) MAY be auto-selected by delegators.
- SDD phase skills (`sdd-*`) and `_shared` protocols are phase-only: loaded by the orchestrator for their phase, not auto-selected as domain skills.
```

### Key Rules

- Every index entry carries `name`, the complete `description`, `scope`, the exact `SKILL.md` `path`, and a `freshness` identity.
- The `Shadowed / Ambiguous` section is omitted only when there are no duplicates.
- The `Project Conventions` section is omitted when no conventions are found.
- If no skills are found, write an empty `Index` so agents stop searching blindly.
- Index the full inventory; mark eligibility separately.
- Keep the heading structure stable — it is machine-parseable.
