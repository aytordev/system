---
title: Scan User and Project Skills
impact: CRITICAL
impactDescription: Foundation for the entire index
tags: scanning, skills, discovery
---

## Scan User and Project Skills

**Impact: CRITICAL**

By default, discover `*/SKILL.md` in the neutral local collection:
`${XDG_DATA_HOME:-$HOME/.local/share}/aytordev/skills`. It does not depend on a
client being installed. If absent, use an explicitly supplied collection or
skill folder; report unavailable roots instead of assuming an installation.

For an explicitly requested broader inventory, include the requested project and
host roots below. Scan all selected roots, not just the first match. Reuse native
discovery where available; do not install another scanner or refresh service.

### Additional global roots (when requested)

- **OpenCode**: the OpenCode config directory's `skill(s)` subdirectory, i.e. `$XDG_CONFIG_HOME/opencode/skill(s)/` (default `$XDG_CONFIG_HOME` is `~/.config`). Both singular and plural names are accepted.
- **Pi**: `~/.pi/agent/skills/` and `~/.agents/skills/`
- **Configured roots**: any additional skill root the active client declares in its settings
- The supplied collection containing this skill, when requested

### Project roots (when requested)

- `.opencode/skill/` and `.opencode/skills/`
- `.pi/skills/`
- `.agents/skills/`
- `{project-root}/skills/`

### Scopes

Every root maps to a scope: roots inside the project are `project`; the rest are
`global`. Project scope wins over global scope for the same skill name (see
`references/skill-resolver.md`, relative to this skill's root). These example
client roots are not a universal discovery standard; do not infer Pen scanning.

### Extraction

For each skill found, read the `SKILL.md` frontmatter to extract:

- `name` — the skill name
- `description` — the **complete** description string, including any `Trigger:` text verbatim. Never truncate it or require a marker.
- `scope` — `project` or `global`
- `path` — the exact absolute path to `SKILL.md`
- `freshness` — a content identity for the file: a SHA-256 digest of `SKILL.md` when hashing is available, otherwise size plus modification time. A same-size content change MUST produce a different freshness.

If a `SKILL.md` exceeds 200 lines, still read the frontmatter in full; index the entry, then read further sections only when a task needs them.

### Precedence and duplicates

Resolve deterministically, in this order:

1. **Project over global** — for the same name, keep the project-scope entry.
2. **Aliases before duplicates** — when the collection and client projections
   resolve to the same original `SKILL.md`, index it once at the neutral path and
   record the client paths as aliases. Equal contents alone do not prove identity.
3. **Ambiguous duplicates** — distinct originals with the same name at the same
   scope remain ambiguous; record every candidate so the caller can decide.

### Symlinks

Follow Nix symlinks when reading `SKILL.md`; the freshness identity is computed from the resolved content, not the link target path.

### Output

Build one index row per skill: `Name | Description | Scope | Path | Freshness`, plus the shadowed/ambiguous table.
