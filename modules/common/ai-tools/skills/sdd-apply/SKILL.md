---
name: sdd-apply
description: "Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them. Trigger: When the orchestrator launches you to implement one or more tasks from a change."
---

# SDD Apply

Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them.

## Purpose

You are a sub-agent responsible for implementing tasks.

## What You Receive

From the orchestrator:
- **Change name** (the specific change being worked on)
- **Specific task(s)** to implement (e.g., "Phase 1, tasks 1.1-1.3")
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

You need ALL previous artifacts (proposal, specs, design, tasks). Retrieve them
from the locators the orchestrator passed (see `_shared/sdd-phase-common.md`); do
not probe another store or guess paths:

- `engram`: the proposal, spec, design, and tasks observations by their topic keys
- `openspec`: `openspec/changes/{change-name}/proposal.md`, `.../specs/`, `.../design.md`, `.../tasks.md`, and `openspec/config.yaml`
- `none`: receive artifacts from prompt context

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `apply-progress`. Depends on: `spec`, `design`, `tasks`.
- `openspec`: read `_shared/openspec-convention.md`. Update `tasks.md` with completion marks.
- `hybrid`: follow both conventions; persist progress to both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return progress inline only.

The backend constrains **persistence artifacts** only. Actually changing the
authorized code/config files is the apply phase's job and is allowed in every
backend, including `engram` and `none`.

## What to Do

### Step 1: Read Specs, Design, Tasks, and Existing Code

Load all prior artifacts and understand the current codebase state. See `rules/execution-read-context.md`.

### Step 2: Detect Implementation Mode

Read cached testing capabilities, resolve requested vs effective Strict TDD, and select the applicable per-unit checks. See `rules/execution-detect-mode.md`.

### Step 3: TDD Workflow (RED -> GREEN -> TRIANGULATE -> REFACTOR)

If the resolved mode is `effective: enabled`, follow the cycle with Safety Net and TRIANGULATE. See `rules/execution-tdd-workflow.md`. If Strict TDD is `blocked`, surface the blocker instead of loading the module. When enabled, also load `modules/strict-tdd.md` for assertion quality rules, approval testing, and pure function preference.

### Step 4: Standard Implementation Workflow

If no TDD framework detected, implement tasks following standard workflow. See `rules/execution-standard-workflow.md`.

### Step 5: Mark Tasks Complete, Re-read, and Return Summary

Update the persisted tasks artifact, **re-read it from the same store**, and merge
the cumulative `apply-progress` before reporting completion. Never report
progress from memory. See `rules/execution-mark-complete.md`.

## Rules

- MUST read specs and design before writing any code
- MUST follow design decisions — never silently deviate
- MUST NOT implement tasks not assigned to this invocation
- MUST update and re-read the persisted tasks artifact before reporting completion
- MUST merge `apply-progress` cumulatively across resumed batches (never overwrite)
- If TDD detected, never skip the RED phase (write failing test first)
- Return a `sdd-result/v1` envelope with: `schema`, `kind`, `status`,
  `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`,
  `skill_resolution`

See `rules/constraints-rules.md` for complete rules.
