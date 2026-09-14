---
title: Scan User and Project Skills
impact: CRITICAL
impactDescription: Foundation for the entire index
tags: scanning, skills, discovery
---

## Scan User and Project Skills

**Impact: CRITICAL**

Discover `*/SKILL.md` across every configured and native skill root. Scan ALL roots that exist, not just the first match. Reuse the clients' native discovery where it already supplies the facts; do not add a second scanner merely to mirror it.

### Global roots

- **OpenCode**: the OpenCode config directory's `skill(s)` subdirectory, i.e. `$XDG_CONFIG_HOME/opencode/skill(s)/` (default `$XDG_CONFIG_HOME` is `~/.config`). Both singular and plural names are accepted.
- **Pi**: `~/.pi/agent/skills/` and `~/.agents/skills/`
- **Configured roots**: any additional skill root the active client declares in its settings
- The parent directory of this skill file (catch-all)

### Project roots

- `.opencode/skill/` and `.opencode/skills/`
- `.pi/skills/`
- `.agents/skills/`
- `{project-root}/skills/`

### Scopes

Every root maps to a scope: roots inside the project are `project`; the rest are `global`. Project scope wins over global scope for the same skill name (see precedence in `_shared/skill-resolver.md`).

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
2. **Configured root order over catch-all** — within one scope, order roots as listed above.
3. **Ambiguous duplicates** — when the same name appears at the same precedence tier (e.g. two global roots), keep the first in root order and record every other candidate in the `Shadowed / Ambiguous` section so the delegator can decide.

### Symlinks

Follow Nix symlinks when reading `SKILL.md`; the freshness identity is computed from the resolved content, not the link target path.

### Output

Build one index row per skill: `Name | Description | Scope | Path | Freshness`, plus the shadowed/ambiguous table.
