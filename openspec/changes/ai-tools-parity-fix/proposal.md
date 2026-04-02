# Proposal: ai-tools-parity-fix

## Intent

Fix a filename bug in the SDD workflow (delta.md vs spec.md) and add `hybrid` mode support to all phase SKILL.md files to achieve 100% functional parity with gentle-ai upstream. Without these fixes, the SDD workflow produces inconsistent file paths and hybrid mode behavior is undefined.

## Scope

### In Scope
- Unify `delta.md` → `spec.md` in the 4 affected rules files
- Add `hybrid` mode to the 9 phase SDD SKILL.md files that omit it
- Create `_shared/sdd-phase-common.md` (consolidates 3 shared files into 1)
- Upgrade `_shared/persistence-contract.md` → v2 (sub-agent context rules + orchestrator templates)
- Update all SKILL.md files to reference `sdd-phase-common.md` instead of 3 separate files
- Upgrade `sdd-init/SKILL.md` → v3.0 with explicit hybrid support and Engram limitations warning

### Out of Scope
- New skills (branch-pr, issue-creation)
- New agent support (Cursor, VSCode, Windsurf)
- OpenCode multi-mode

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `ai-tools`: fix delta.md→spec.md paths, hybrid mode, sdd-phase-common protocol upgrade

## Approach

Four batches of atomic commits ordered by impact:
- **Batch A**: filename bug fix (4 rules files)
- **Batch B**: hybrid mode in 9 SKILL.md files
- **Batch C**: protocol upgrade (_shared refactor)
- **Batch D**: sdd-init v3.0

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `skills/sdd-spec/rules/execution-write-delta.md` | Modified | delta.md → spec.md |
| `skills/sdd-archive/rules/execution-sync-specs.md` | Modified | delta.md → spec.md |
| `skills/sdd-archive/rules/execution-move-archive.md` | Modified | delta.md → spec.md |
| `skills/sdd-archive/rules/execution-verify-archive.md` | Modified | delta.md → spec.md |
| `skills/sdd-*/SKILL.md` (×9) | Modified | +hybrid mode |
| `skills/_shared/sdd-phase-common.md` | Create | new consolidated file |
| `skills/_shared/persistence-contract.md` | Modified | v2 with sub-agent rules |
| `skills/sdd-init/SKILL.md` + rules | Modified | v3.0 |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Breaking active changes that use delta.md | Low | No active changes use delta.md today |
| Regression in sdd-archive merge | Low | Archive reads same file sdd-spec writes |

## Rollback Plan

`git revert` individual commits or `git checkout main -- modules/common/ai-tools/skills/`.

## Dependencies

- None

## Success Criteria

- [ ] `grep -r "delta\.md" skills/sdd-spec/ skills/sdd-archive/` returns empty
- [ ] `grep "hybrid" skills/sdd-*/SKILL.md` returns result in all 9+1 skills
- [ ] `skills/_shared/sdd-phase-common.md` exists with sections A/B/C/D
- [ ] `nix fmt` passes without errors
