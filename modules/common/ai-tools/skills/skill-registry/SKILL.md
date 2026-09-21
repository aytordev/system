---
name: skill-registry
description: "Discover and index available skills by name, full description, scope, and exact SKILL.md path, with a content freshness identity. Supports read-only listing and explicitly requested persistence. Trigger: When the user requests the local skill registry, invokes /skill:skill-registry, or asks to refresh the local skill index."
compatibility: "Needs filesystem read access; file persistence needs write access, and optional Engram persistence needs host-provided Engram tools."
---

# Skill Registry

Discover and index available skills. The registry is an **index, not a compiler**: it carries each skill's name, full description, scope, exact `SKILL.md` path, and a freshness identity. `SKILL.md` stays the source of truth — delegators pass exact paths and executors read the selected originals plus the references they need. Generated summaries are never authoritative.

This is an explicitly invoked local collection index. Optional knowledge selection
is described in [references/skill-resolver.md](references/skill-resolver.md); it does not own a workflow.
Use `/skill:skill-registry` in Pi to select this local skill. Shell's
`gentle-ai-skill-registry` is a separate upstream skill.

Use equivalent file-reading, discovery, and optional hashing capabilities supplied
by the host. If unavailable, report the limit rather than claiming a completed
scan. Supporting paths are relative to this skill folder. Default to the neutral
`$XDG_DATA_HOME/aytordev/skills` collection; broader discovery is explicitly scoped.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Scanning | CRITICAL | `execution-scan` |
| 2 | Index Output | CRITICAL | `execution-write` |
| 3 | Listing | HIGH | `execution-list` |
| 4 | Persistence | HIGH | `execution-persist` |

## Quick Reference

### 1. Scanning (CRITICAL)

- `execution-scan-skills` — Discover skills, parse full descriptions, record scope, path, and freshness
- `execution-scan-conventions` — Index project conventions without flattening subtree scope

### 2. Index Output (CRITICAL)

- `execution-write-registry` — Build the index (name, description, scope, path, freshness)

### 3. Listing (HIGH)

- `execution-list-readonly` — Read-only listing that writes nothing

### 4. Persistence (HIGH)

- `execution-persist` — Persistence-aware refresh
- `execution-return-summary` — Return structured summary

## Rules

- NEVER generate compact rules or summaries as authoritative content — index exact paths
- Parse the full frontmatter description; never require a literal `Trigger:` marker
- Prefer project scope over global scope deterministically; surface ambiguous duplicates
- Distinguish the full inventory from invocation eligibility (see below)
- Read-only listing and default `none` mode MUST write nothing
- Explicit file persistence uses `.ai-local/skill-registry.md`, never Shell's `.atl/skill-registry.md`
- NEVER silently edit `.gitignore`
- Old compact-rule caches cannot satisfy this contract — regenerate them

See `rules/constraints-rules.md` for complete rules.

## Inventory vs Invocation Eligibility

The index lists **every** discovered skill. Selection depends on its full
description and the actual task; being indexed never starts a workflow. Shared
support without `SKILL.md` is not a skill. Do not filter arbitrary user skills
solely by a name prefix. Shell's own index may exclude the literal local
`skill-registry` name; native Pi skill discovery still exposes it.
