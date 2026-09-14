# Skill Registry — redacted legacy cache (T25 fixture)

Generated: 2026-05-28
Project: aytordev/system (redacted)
Skill root: ~/.config/opencode/skills/

---

## Skills Index

| Skill | Trigger | Path |
|-------|---------|------|
| `nix` | When writing or editing Nix expressions | `~/.config/opencode/skills/nix/SKILL.md` |
| `dotfiles-coder` | When modifying modules/ or homes/ | `~/.config/opencode/skills/dotfiles-coder/SKILL.md` |

---

## Project Conventions

| File | Purpose |
|------|---------|
| `AGENTS.md` | Top-level project constitution |

---

## Compact Rules

### `nix` — Nix style rules

- No `with lib;` — use `inherit (lib)` or inline `lib.` prefix
- camelCase variables, kebab-case files

### `dotfiles-coder` — Dotfiles architecture

- Home-first: prefer `modules/home/` when possible

---

## Skill Resolution Report

Last resolved: 2026-05-28
Mode: engram
Active changes: ai-tools-parity-fix, engram-nix-update
