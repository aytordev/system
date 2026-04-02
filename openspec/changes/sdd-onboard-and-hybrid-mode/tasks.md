# Tasks: sdd-onboard-and-hybrid-mode

**Change**: sdd-onboard-and-hybrid-mode
**Date**: 2026-04-02

---

## Phase 1: `sdd-onboard` skill

- [x] 1.1 Create `skills/sdd-onboard/metadata.json` with name, version, description, author, license, tags
- [x] 1.2 Create `skills/sdd-onboard/SKILL.md` — skill entry point with purpose, received context, execution contract references, rule index, and constraints
- [x] 1.3 Create `skills/sdd-onboard/rules/execution-phase-selection.md` — codebase scan criteria and option presentation logic
- [x] 1.4 Create `skills/sdd-onboard/rules/execution-phases.md` — narrated 8-phase SDD cycle (explore → archive), each phase with narration template
- [x] 1.5 Create `skills/sdd-onboard/rules/constraints-rules.md` — MUST/MUST NOT/SHOULD rules for the onboarding skill

## Phase 2: `sdd-onboard` command

- [x] 2.1 Create `commands/sdd/sdd-onboard.nix` — command Nix expression following `sdd-new.nix` pattern (description, allowedTools, agent = "sdd-orchestrator", prompt)
- [x] 2.2 Verify `commands.nix` auto-imports the new command (check import pattern used by existing commands)

## Phase 3: `hybrid` persistence mode

- [x] 3.1 Update `skills/_shared/persistence-contract.md` — add `hybrid` to mode list, behavior table, and add hybrid Common Rules section
- [x] 3.2 Update `skills/sdd-init/rules/execution-bootstrap.md` — add hybrid bootstrap case (create openspec/ AND save to Engram)
- [x] 3.3 Update `skills/sdd-init/rules/execution-return-summary.md` — add hybrid summary template

## Phase 4: Verification

- [x] 4.1 Run `nix fmt` — verify formatting passes (1 file reformatted, no errors)
- [x] 4.2 Run `nix build .#darwinConfigurations.wang-lin.system --dry-run` — Nix evaluates cleanly, all derivations resolved
- [x] 4.3 Spot-check installed skill: verify `~/.claude/skills/sdd-onboard/SKILL.md` would be present after rebuild (skillsDir points to modules/common/ai-tools/skills/)
