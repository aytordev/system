# Skill Registry — system

Generated: 2026-05-28
Project: aytordev/system (NixOS/nix-darwin dotfiles)
Skill root: ~/.claude/skills/

---

## Skills Index

| Skill | Trigger | Path |
|-------|---------|------|
| `nix` | When writing or editing Nix expressions, modules, flakes, overlays, or options | `~/.claude/skills/nix/SKILL.md` |
| `dotfiles-coder` | When modifying modules/, homes/, flake inputs, NixOS/darwin configs, or Home Manager programs | `~/.claude/skills/dotfiles-coder/SKILL.md` |
| `branch-pr` | When creating, opening, or preparing PRs for review | `~/.claude/skills/branch-pr/SKILL.md` |
| `chained-pr` | When PRs exceed 400 lines, or splitting stacked changes for review | `~/.claude/skills/chained-pr/SKILL.md` |
| `cognitive-doc-design` | When writing guides, READMEs, RFCs, onboarding, or architecture docs | `~/.claude/skills/cognitive-doc-design/SKILL.md` |
| `comment-writer` | When writing PR feedback, issue replies, reviews, or GitHub comments | `~/.claude/skills/comment-writer/SKILL.md` |
| `issue-creation` | When creating GitHub issues, bug reports, or feature requests | `~/.claude/skills/issue-creation/SKILL.md` |
| `judgment-day` | When performing adversarial code review, quality gate, or final verification before merge | `~/.claude/skills/judgment-day/SKILL.md` |
| `work-unit-commits` | When planning commits, splitting changes, or preparing for review | `~/.claude/skills/work-unit-commits/SKILL.md` |
| `skill-creator` | When creating or updating a skill (SKILL.md, rules/, references/) | `~/.claude/skills/skill-creator/SKILL.md` |
| `skill-registry` | When regenerating or updating the skill registry | `~/.claude/skills/skill-registry/SKILL.md` |
| `sdd-init` | When initializing SDD context in a project | `~/.claude/skills/sdd-init/SKILL.md` |
| `sdd-explore` | When exploring ideas or investigating codebase before committing to a change | `~/.claude/skills/sdd-explore/SKILL.md` |
| `sdd-propose` | When creating a structured change proposal | `~/.claude/skills/sdd-propose/SKILL.md` |
| `sdd-spec` | When writing specifications with requirements and scenarios | `~/.claude/skills/sdd-spec/SKILL.md` |
| `sdd-design` | When creating technical design documents for a change | `~/.claude/skills/sdd-design/SKILL.md` |
| `sdd-tasks` | When breaking a change into an implementation task checklist | `~/.claude/skills/sdd-tasks/SKILL.md` |
| `sdd-apply` | When implementing tasks from a change | `~/.claude/skills/sdd-apply/SKILL.md` |
| `sdd-verify` | When validating that implementation matches specs and design | `~/.claude/skills/sdd-verify/SKILL.md` |
| `sdd-archive` | When archiving a completed change and syncing delta specs | `~/.claude/skills/sdd-archive/SKILL.md` |
| `sdd-onboard` | When onboarding a user through the full SDD cycle with narration | `~/.claude/skills/sdd-onboard/SKILL.md` |

---

## Project Conventions

| File | Purpose |
|------|---------|
| `AGENTS.md` | Top-level project constitution — architecture, commands, style rules |
| `modules/common/AGENTS.md` | Shared cross-platform module conventions |
| `modules/home/AGENTS.md` | Home Manager module conventions |
| `modules/darwin/AGENTS.md` | macOS (nix-darwin) module conventions |
| `checks/AGENTS.md` | Nix check discovery and auto-loader conventions |
| `flake/AGENTS.md` | Flake outputs organization |
| `openspec/config.yaml` | SDD project configuration (strict_tdd: false) |

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

### `branch-pr` — Pull request creation (trigger: creating or preparing PRs)

- Check for an existing issue before creating a PR; open one if absent
- PR title follows conventional commit format: `type(scope): description`
- PR description links to the issue and summarizes what changed and why
- Include build/test evidence: `nix fmt && nix flake check` output
- Request review from CODEOWNERS; apply labels per `.github/labeler.yml`

### `chained-pr` — Oversized PR splitting (trigger: PRs >400 lines, stacked changes)

- Split into a base PR (foundation/types) + one or more follow-on PRs
- Each PR in the chain must be independently reviewable and must not break CI
- PR description references the parent PR and explains its position in the chain
- Keep each PR under ~400 lines of substantive change
- Mark follow-on PRs as draft until the base is merged

### `cognitive-doc-design` — Documentation (trigger: READMEs, guides, architecture docs)

- Lead with the "why" before the "what" — context before detail
- Use progressive disclosure: overview → details → reference
- One concept per section; avoid mixing concerns
- Prefer concrete examples before abstract rules
- Active voice, present tense; avoid "will", "should", "might"

### `comment-writer` — Collaboration comments (trigger: PR reviews, issue replies)

- Reference specific lines or functions — never vague ("this looks off")
- Classify: blocking (must fix before merge) vs. non-blocking (suggestion/nit)
- Propose an alternative when raising a concern — not just the problem
- Acknowledge what works before listing concerns
- Use "we" framing for collaborative suggestions, not "you did X wrong"

### `issue-creation` — GitHub issues (trigger: bug reports, feature requests)

- Check for duplicate issues before creating
- Use the appropriate `.github/ISSUE_TEMPLATE/` template
- Bugs: include reproduction steps, expected vs. actual, and environment info
- Features: include acceptance criteria and motivation
- Apply labels from `.github/labeler.yml`

### `judgment-day` — Adversarial review (trigger: final verification, pre-merge)

- Two blind judges review independently, then synthesize findings
- Verdict: APPROVED, APPROVED_WITH_CONCERNS, or REJECTED
- REJECTED requires a specific fix list before re-judging
- Convergence after 3 rounds — escalate unresolved blockers to user

### `work-unit-commits` — Commit planning (trigger: implementation, commit splitting)

- One logical change per commit — tests, docs, and code together in the same commit
- Never split a change such that intermediate commits break CI
- Commit message format: `type(scope): description` (conventional commits)
- Prefer atomic commits; avoid WIP or checkpoint commits in final history
- Use `git rebase -i` to clean history before pushing

### `skill-creator` — Skill format (trigger: skills/ directory, SKILL.md, rules/)

- Every skill needs: `SKILL.md` (index + protocol) + `rules/` (execution steps + constraints)
- Optional: `references/` (templates), `modules/` (extension modules)
- SKILL.md frontmatter: `name`, `description`
- Rule files: kebab-case, named `{category}-{specifics}.md`
- Compact rules in skill-registry must be actionable in 5-15 bullets

---

## Skill Resolution Report

Last resolved: 2026-05-28
Mode: engram
Active changes: ai-tools-parity-fix, engram-nix-update, sdd-onboard-and-hybrid-mode
