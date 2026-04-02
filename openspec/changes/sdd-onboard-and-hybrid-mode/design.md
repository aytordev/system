# Technical Design: sdd-onboard-and-hybrid-mode

**Date**: 2026-04-02
**Status**: approved

---

## Architecture Overview

Two additive changes to `modules/common/ai-tools/`:

1. New skill: `skills/sdd-onboard/` + `commands/sdd/sdd-onboard.nix`
2. Protocol extension: `skills/_shared/persistence-contract.md` + two updated sdd-init rules

No existing files are removed. No Nix wiring changes needed — `skillsDir` automatically deploys everything under `skills/`.

---

## Decision 1 — `sdd-onboard` skill architecture

**Chosen**: Local modular architecture (`SKILL.md` + `rules/` directory)
**Rejected**: Upstream monolithic SKILL.md (~200 lines)

**Rationale**: The local architecture is deliberately more maintainable. Each rule file has a single responsibility. This matches every other skill in the repo.

**Rule files needed**:
- `rules/execution-phases.md` — the narrated 8-phase cycle (core logic)
- `rules/execution-phase-selection.md` — criteria for picking a real small improvement
- `rules/constraints-rules.md` — MUST/MUST NOT/SHOULD constraints

The upstream has this all inline in SKILL.md. We split it.

---

## Decision 2 — `hybrid` mode scope

**Chosen**: Add `hybrid` only to `persistence-contract.md` + update sdd-init bootstrap/summary
**Rejected**: Update every SDD phase skill (sdd-propose, sdd-spec, etc.) individually

**Rationale**: `persistence-contract.md` is the single source of truth. All phases read it. Adding hybrid to the contract automatically documents the behavior for every phase. The phases themselves just follow the contract — no changes needed.

The only phase that needs explicit changes is `sdd-init` because it's the one that bootstraps both backends and its summary must show both.

---

## File Changes

| File | Action | What |
|---|---|---|
| `skills/sdd-onboard/SKILL.md` | Create | Skill entry point |
| `skills/sdd-onboard/rules/execution-phases.md` | Create | 8-phase narrated cycle |
| `skills/sdd-onboard/rules/execution-phase-selection.md` | Create | Codebase scan + selection criteria |
| `skills/sdd-onboard/rules/constraints-rules.md` | Create | Skill constraints |
| `skills/sdd-onboard/metadata.json` | Create | Nix metadata |
| `commands/sdd/sdd-onboard.nix` | Create | `/sdd-onboard` command |
| `skills/_shared/persistence-contract.md` | Modify | Add `hybrid` mode |
| `skills/sdd-init/rules/execution-bootstrap.md` | Modify | Add hybrid bootstrap |
| `skills/sdd-init/rules/execution-return-summary.md` | Modify | Add hybrid summary template |

---

## `sdd-onboard` SKILL.md structure

```
Purpose: guided onboarding sub-agent
Receives: artifact store mode, optional codebase hint
Rules:
  - skill-loading.md (Section A)
  - persistence-contract.md (mode resolution)
  - return-envelope.md (Section D)
Steps:
  1. Welcome + codebase scan (execution-phase-selection.md)
  2. Present 2-3 options, let user choose
  3. Narrated phases 1–8 (execution-phases.md)
  4. Onboarding summary
```

## `sdd-onboard` command structure

Follows the pattern of `sdd-new.nix`:
- `agent = "sdd-orchestrator"`
- Routes to sdd-onboard sub-agent
- `allowedTools = "Read, Write, Edit, Bash, Grep, Glob"`

## `hybrid` mode in persistence-contract.md

Add to the mode list: `engram | openspec | hybrid | none`

Add to Behavior Per Mode table:
```
| `hybrid` | Engram (primary) + Filesystem (fallback) | Both | Yes |
```

Add `hybrid` section in Common Rules:
- Write to BOTH Engram AND filesystem for every artifact
- Read from Engram first; fall back to filesystem
- Both writes MUST succeed for the operation to be complete
- Token cost warning: hybrid consumes more tokens per operation

## `sdd-init` hybrid bootstrap

In `execution-bootstrap.md`, add `hybrid` case:
```
Mode: `hybrid`
- Create openspec/ directory structure (same as openspec mode)
- Save detected project context to Engram (same as engram mode)
- Both operations MUST succeed
```

## `sdd-init` hybrid summary

In `execution-return-summary.md`, add hybrid template:
```markdown
## SDD Initialized (Hybrid)

**Persistence**: Hybrid (Engram + openspec/)

### Created
- openspec/ structure (files)
- Engram context saved

### Engram Keys
- sdd-init/{project}: context
- sdd/{project}/testing-capabilities: testing info
```
