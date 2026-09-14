---
name: skill-registry
description: "Discover and index available skills by name, full description, scope, and exact SKILL.md path, with a content freshness identity. Supports read-only listing and persistence-aware refresh. Trigger: When user says 'update skills', 'skill registry', 'update registry', or after installing/removing skills."
---

# Skill Registry

Discover and index available skills. The registry is an **index, not a compiler**: it carries each skill's name, full description, scope, exact `SKILL.md` path, and a freshness identity. `SKILL.md` stays the source of truth — delegators pass exact paths and executors read the selected originals plus the references they need. Generated summaries are never authoritative.

This is the foundation of the **Skill Resolver Protocol** (see `_shared/skill-resolver.md`).

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
- Read-only listing and `none` mode MUST write nothing (no `.atl/`, no `.gitignore`, no Engram)
- NEVER silently edit `.gitignore`
- Old compact-rule caches cannot satisfy this contract — regenerate them

See `rules/constraints-rules.md` for complete rules.

## Inventory vs Invocation Eligibility

The index lists **every** discovered skill (inventory), but delegators only auto-select **eligible** domain skills. SDD phase skills (`sdd-*`) and shared protocols are indexed but phase-only: they are loaded by the orchestrator for their phase, not auto-selected as domain skills. Do not drop arbitrary user skills solely because of a name prefix.
