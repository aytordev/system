# Proposal: sdd-onboard-and-hybrid-mode

**Status**: draft
**Date**: 2026-04-02
**Author**: aytordev

## Intent

Add two missing features identified by comparing the local dotfiles ai-tools module against the upstream `gentle-ai` repository:

1. **`sdd-onboard` skill** — guided end-to-end SDD walkthrough using the user's real codebase. Currently exists in `gentle-ai` upstream v1.0 but is absent from the local Nix module.
2. **`hybrid` persistence mode** — dual-backend mode that writes to both Engram (cross-session recovery) and OpenSpec (git-trackable audit trail) simultaneously. The upstream `persistence-contract.md` supports it; the local version does not.

## Problem

- Users new to SDD lack a guided entry point. The existing commands require prior knowledge of the workflow.
- Teams working on shared codebases cannot simultaneously benefit from Engram's cross-session recovery AND OpenSpec's git-trackable audit trail. They must choose one.

## Proposed Solution

### 1. `sdd-onboard` skill

Create `modules/common/ai-tools/skills/sdd-onboard/` following the local modular architecture (`SKILL.md` + `rules/` directory). The skill guides users through a complete SDD cycle — explore → propose → spec → design → tasks → apply → verify → archive — using their own codebase, with narration at each step.

Add the corresponding `commands/sdd/sdd-onboard.nix` command.

### 2. `hybrid` mode

Update `modules/common/ai-tools/skills/_shared/persistence-contract.md` to:
- Add `hybrid` as a valid mode alongside `engram | openspec | none`
- Define hybrid behavior: persist to BOTH Engram AND filesystem per phase
- Update the mode comparison table
- Update all `behavior per mode` tables

Also update `sdd-init`'s `rules/execution-bootstrap.md` and `rules/execution-return-summary.md` to handle hybrid bootstrap and summary output.

## Scope

**In scope**:
- `skills/sdd-onboard/` — new skill (SKILL.md + rules/)
- `commands/sdd/sdd-onboard.nix` — new command
- `skills/_shared/persistence-contract.md` — add hybrid mode
- `skills/sdd-init/rules/execution-bootstrap.md` — hybrid bootstrap
- `skills/sdd-init/rules/execution-return-summary.md` — hybrid summary

**Out of scope**:
- Updating every individual SDD phase skill for hybrid (persistence-contract.md is the single source of truth — phases read it)
- Any changes to the Nix module wiring (skillsDir handles deployment automatically)

## Capabilities

| Capability Key | Description |
|---|---|
| `sdd-onboard` | Guided SDD onboarding skill |
| `hybrid-persistence` | Hybrid engram+openspec mode in persistence-contract |

## Rollback Plan

- All changes are additive (new files + one file extension)
- `persistence-contract.md` change is backwards-compatible (existing `engram | openspec | none` modes unchanged)
- Rollback: `git revert` the commit or delete the new files

## Risks

- `sdd-onboard` touches every SDD phase — if any phase skill has a bug, onboarding will fail at that step
- `hybrid` mode adds write overhead (two backends per phase) — minimal risk since it's opt-in
