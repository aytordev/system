---
name: sdd-archive
description: "Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Trigger: When orchestrator launches you to archive a change after implementation and verification."
---

# SDD Archive

Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Merges delta specs into the source of truth, moves change folder to archive.

## Purpose

You are a sub-agent responsible for SDD archival.

## What You Receive

From the orchestrator:
- **Change name**
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

Retrieve from the locators the orchestrator passed (see
`_shared/sdd-phase-common.md`); do not probe another store or guess paths:

- `engram`: the verify report and all change observations
- `openspec`: all files in `openspec/changes/{change-name}/`
- `none`: from prompt context

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)
- `_shared/closure-policy.md` — **C11 closure policy, dispositions, and the promotion gate**

- `engram`: read `_shared/engram-convention.md`. Artifact type: `archive-report`. Depends on: all prior artifacts. Closure uses references and final evidence; no filesystem copies.
- `openspec`: read `_shared/openspec-convention.md`. Compose deltas through the engine, then archive moves.
- `hybrid`: follow both conventions; persist the archive report to Engram and perform the filesystem compose/moves, using the partial-write/retry rules in `persistence-contract.md`.
- `none`: return the closure summary inline only.

## What to Do

### Step 0: Closure Gate (C11)

Before any write, run `aytordev-sdd closure <change> --revision <candidate-revision>`
and proceed only on `disposition: verified`. An `incomplete-tasks`, `unverified`,
or `stale-verification` result stops the flow; `paused`/`abandoned` are explicit
operator dispositions. See `rules/execution-closure-gate.md`.

### Step 1: Sync Delta Specs to Main Specs

Compose each domain delta into the canonical spec deterministically through
`aytordev-sdd compose`. See `rules/execution-sync-specs.md`.

### Step 2: Move Change to Archive

Relocate the completed change folder to the archive directory with ISO date
prefix, using the adapter's snapshot/readback/collision-safe move. See `rules/execution-move-archive.md`.

### Step 3: Verify Archive Completeness and Return Summary

Confirm all artifacts are archived and compile results into the `sdd-result/v1`
envelope. See `rules/execution-verify-archive.md`.

## Rules

- NEVER archive a change whose closure gate did not return `verified`
- NEVER promote canonical specs for an `unverified`, `paused`, or `abandoned` change
- ALWAYS compose delta specs through the engine before archiving
- Preserve unmentioned requirements during spec merge
- Use ISO date format for archive prefixes
- Must never overwrite an existing archive (collision refuses)
- MUST NOT delete archived changes after archiving
- Never fabricate a PASS; a non-success disposition keeps its distinct status
- Return a `sdd-result/v1` envelope with `schema`, `kind`, `status`, `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`, `skill_resolution`

See `rules/constraints-rules.md` for complete rules.
