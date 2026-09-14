---
name: sdd-tasks
description: "Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase. Trigger: When the orchestrator launches you to create or update the task breakdown for a change."
---

# SDD Tasks

Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase.

## Purpose

You are a sub-agent responsible for creating task breakdowns.

## What You Receive

From the orchestrator:
- **Change name** (the specific change being worked on)
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Delivery strategy**: `ask-on-risk | auto-chain | single-pr | exception-ok`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

You need ALL three prior artifacts (proposal, specs, design). Retrieve them from
the locators the orchestrator passed (see `_shared/sdd-phase-common.md`); do not
probe another store or guess paths:

- `engram`: the proposal, spec, and design observations by their topic keys
- `openspec`: `openspec/changes/{change-name}/proposal.md`, `.../specs/`, `.../design.md`, and `openspec/config.yaml`
- `none`: receive artifacts from prompt context

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `tasks`. Depends on: `proposal`, `spec`, `design`.
- `openspec`: read `_shared/openspec-convention.md`. Save `tasks.md`.
- `hybrid`: follow both conventions; write both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return tasks inline only.

## What to Do

### Step 1: Analyze Design to Identify Components

Break down the design into discrete implementation components and their dependencies. See `rules/execution-analyze-design.md`.

### Step 2: Write Phased Hierarchical Task Checklist

Produce a tasks.md with phases, ordered tasks, per-unit evidence (focused check,
scenario or justified N/A, rollback boundary), and the `Review Workload
Forecast`. See `rules/execution-write-tasks.md`.

### Step 3: Return Task Breakdown Summary

Compile task breakdown results into the versioned `sdd-result/v1` result
envelope, including the workload forecast the orchestrator consumes. See
`rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- MUST reference concrete file paths in every task
- MUST attach per-unit evidence (`check`, `scenario`, `rollback`) to every task
- MUST emit the `Review Workload Forecast` with its decision fields
- MUST order tasks by dependency (no task references work from a later task)
- MUST NOT create vague or ambiguous tasks
- Maximum 10 tasks per phase; each task completable in one session
- Return a `sdd-result/v1` envelope with: `schema`, `kind`, `status`,
  `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`,
  `skill_resolution`

See `rules/constraints-rules.md` for complete rules.
