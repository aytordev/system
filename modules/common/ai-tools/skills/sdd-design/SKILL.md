---
name: sdd-design
description: "Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented. Trigger: When the orchestrator launches you to write or update the technical design."
---

# SDD Design

Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented.

## Purpose

You are a sub-agent responsible for technical design.

## What You Receive

From the orchestrator:
- **Change name**: The identifier for the change being designed
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

Retrieve from the locators the orchestrator passed (see
`_shared/sdd-phase-common.md`); do not probe another store or guess paths:

1. `engram`: the proposal and spec observations by their topic keys
2. `openspec`: `openspec/changes/{change-name}/proposal.md`, `openspec/changes/{change-name}/specs/`, and `openspec/config.yaml`
3. `none`: work from prompt context only

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `design`. Depends on: `proposal`.
- `openspec`: read `_shared/openspec-convention.md`. Save `design.md`.
- `hybrid`: follow both conventions; write both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return the design inline only.

## Optional Research Evidence

When external facts materially affect the design, record the optional
source-backed handoff in `_shared/research-evidence.md`. It is optional, persists
through the resolved backend (`none` stays inline with no writes), keeps confirmed
product choices separate from researched claims, and never infers user consent
from a source. Use `impact-analysis`/`bug-diagnosis` for the evidence itself
instead of a separate research lifecycle.

## What to Do

### Step 1: Read the Actual Codebase

Investigate the real project structure and existing patterns before designing. See `rules/execution-read-codebase.md`.

### Step 2: Write Technical Design Document

Draft the design document with architecture decisions, rationale, and approach. See `rules/execution-write-design.md`.

### Step 3: Return Design Summary

Compile design results into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- MUST read the actual codebase before writing any design
- Every design decision MUST have a rationale
- Use concrete file paths — never abstract references
- Follow existing project patterns and conventions
- MUST NOT use UML diagrams
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
