---
title: Generate Compact Rules
impact: CRITICAL
impactDescription: These are what sub-agents actually receive
tags: compact-rules, generation
---

## Generate Compact Rules

**Impact: CRITICAL**

For each skill found in the scan step, generate a **compact rules block** (5-15 lines max) containing ONLY:

- Actionable rules and constraints ("do X", "never Y", "prefer Z over W")
- Key patterns with one-line examples where critical
- Breaking changes or gotchas that would cause bugs if missed

### What to EXCLUDE

- Purpose/motivation text
- When-to-use descriptions
- Full code examples (one-line snippets are OK)
- Installation steps
- Anything the sub-agent doesn't need to APPLY the skill

### Format

```markdown
### {skill-name}
- Rule 1
- Rule 2
- ...
```

### Example — compact rules for a Nix skill

```markdown
### nix
- No `with lib;` — use `inherit (lib)` or inline `lib.` prefix
- camelCase for variables, kebab-case for files/dirs
- All options under `aytordev.*` namespace
- Prefer `lib.mkIf` over `if then else`
- Use `lib.optionalString` for conditional string values
- Destructure module args: `{ config, lib, pkgs, ... }`
- Format with `nix fmt` before committing
```

### Quality Check

The compact rules are the **MOST IMPORTANT output** of this skill. Invest time making them accurate and concise. Each block should be something a sub-agent can follow immediately without reading additional files.
