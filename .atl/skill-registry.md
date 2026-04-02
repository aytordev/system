# Skill Registry — system

Generated: 2026-04-02
Project: aytordev/system (NixOS/nix-darwin dotfiles)
Skill root: ~/.claude/skills/

---

## Skills Index

| Skill | Trigger | Path |
|-------|---------|------|
| `nix` | When writing or editing Nix expressions, modules, flakes, overlays, or options | `~/.claude/skills/nix/SKILL.md` |
| `dotfiles-coder` | When modifying modules/, homes/, flake inputs, NixOS/darwin configs, or Home Manager programs | `~/.claude/skills/dotfiles-coder/SKILL.md` |
| `skill-creator` | When creating or updating a skill (SKILL.md, rules/, references/) | `~/.claude/skills/skill-creator/SKILL.md` |
| `skill-registry` | When regenerating or updating the skill registry | `~/.claude/skills/skill-registry/SKILL.md` |
| `judgment-day` | When performing adversarial code review, quality gate, or final verification before merge | `~/.claude/skills/judgment-day/SKILL.md` |
| `sdd-onboard` | When onboarding a user through the full SDD cycle | `~/.claude/skills/sdd-onboard/SKILL.md` |

---

## Project Conventions

| File | Purpose |
|------|---------|
| `AGENTS.md` | Top-level project constitution — architecture, commands, style rules |
| `modules/common/ai-tools/AGENTS.md` | AI tools domain — agents, commands, skills inventory |
| `modules/home/AGENTS.md` | Home Manager module conventions |
| `modules/darwin/AGENTS.md` | macOS (nix-darwin) module conventions |
| `modules/common/AGENTS.md` | Shared cross-platform module conventions |
| `openspec/config.yaml` | SDD project configuration |

---

## Compact Rules

### `nix` — Nix style rules (trigger: any .nix file)

- No `with lib;` — use `inherit (lib)` or inline `lib.` prefix
- camelCase variables, kebab-case files and directories
- All options namespaced under `aytordev.*`
- Prefer `lib.mkIf` over `if then else` for conditionals
- Module structure: `{ config, lib, pkgs, ... }:` with `let cfg = config.aytordev.<module>; in`
- Use `lib.mkEnableOption` for boolean options, `lib.mkOption` with explicit `type` for others
- `inherit` attrs when possible instead of `attr = attr`
- Format with `nix fmt` before committing

### `dotfiles-coder` — Dotfiles architecture (trigger: modules/, homes/, flake/)

- Home-first: prefer `modules/home/` over `modules/nixos/` or `modules/darwin/` when possible
- Platform splits go in `modules/nixos/` (NixOS-only) or `modules/darwin/` (macOS-only)
- Shared logic belongs in `modules/common/`
- Secrets use sops-nix, never hardcoded
- AI tools live in `modules/common/ai-tools/` — agents, commands, skills, Nix pipeline
- Build check: `nix build .#homeConfigurations.aytordev.activationPackage --dry-run`
- Full rebuild: `sudo nixos-rebuild switch --flake .#${host}` (NixOS) or `darwin-rebuild switch --flake .#${host}` (macOS)

### `skill-creator` — Skill format (trigger: skills/ directory, SKILL.md, rules/)

- Every skill needs: `SKILL.md` (index + protocol) + `rules/` (execution steps + constraints)
- Optional: `references/` (templates), `modules/` (extension modules)
- SKILL.md frontmatter: `name`, `description`, `license`, `metadata.author`, `metadata.version`
- Rule files: kebab-case, named `{category}-{specifics}.md`
- Compact rules in skill-registry must be actionable in ≤5 bullets

### `judgment-day` — Adversarial review (trigger: final verification, pre-merge)

- Two blind judges review independently, then synthesize
- Verdict: APPROVED, APPROVED_WITH_CONCERNS, or REJECTED
- REJECTED requires specific fix list before re-judging
- Convergence after 3 rounds — escalate blockers to user

---

## Skill Resolution Report

Last resolved: 2026-04-02
Mode: openspec
Active change: (none)
