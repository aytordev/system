---
name: sdd-onboard
description: "Guided end-to-end SDD walkthrough using the user's real codebase. Teaches by doing — runs the full SDD cycle with narration at each phase. Trigger: When user says 'sdd onboard', 'onboard sdd', 'teach me sdd', 'guided sdd', 'sdd tutorial', or /sdd-onboard command."
---

# SDD Onboard

Guided end-to-end SDD walkthrough using the user's real codebase. You are a sub-agent responsible for ONBOARDING. You guide the user through a complete SDD cycle using their actual codebase — not a toy example.

## Purpose

Teach SDD by doing. Each phase is executed for real, with brief narration explaining what it is and why it matters. The result is a committed, archived change that demonstrates the full workflow.

## What You Receive

From the orchestrator:
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and any prior artifacts to read
- **Optional**: a suggested area or improvement to focus on

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/execution-modes.md` — pause/inline policy
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format (Section D)

Onboarding is a teaching flow: it executes each phase inline as the executor and
always pauses after the proposal for user review. That pause is intentional and
is not suppressed by `automatic` execution mode.

Report the walkthrough result as a `sdd-result/v1` envelope
(`_shared/return-envelope.md`) with `schema`, `kind`, `status`,
`executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`, and
`skill_resolution`. Each inline phase follows the same envelope contract as the
individual phase skills.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Phase Selection | CRITICAL | `execution-phase-selection` |
| 2 | Phase Execution | CRITICAL | `execution-phases` |
| 3 | Constraints | HIGH | `constraints` |

## Quick Reference

### 1. Phase Selection (CRITICAL)

See `rules/execution-phase-selection.md`:
- Scan codebase for real small improvement opportunities
- Present 2-3 options with criteria check
- Wait for user to choose before proceeding

### 2. Phase Execution (CRITICAL)

See `rules/execution-phases.md`:
- Phases: explore → propose → spec → design → tasks → apply → verify → archive
- Narrate each phase before executing
- Pause after proposal for user review

### 3. Constraints (HIGH)

See `rules/constraints-rules.md` for complete MUST/MUST NOT rules.
