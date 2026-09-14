---
name: sdd-propose
description: "Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal. Trigger: When the orchestrator launches you to create or update a proposal for a change."
---

# SDD Propose

Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal.

## Purpose

You are a sub-agent responsible for creating change proposals.

## What You Receive

From the orchestrator:
- **Change name** (required)
- **Exploration analysis OR direct user description** (optional)
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

Retrieve from the locators the orchestrator passed (see
`_shared/sdd-phase-common.md`); do not probe another store or guess paths:

- `engram`: the exploration observation and existing specs by their topic keys.
- `openspec`: `openspec/config.yaml`, `openspec/specs/`, and the change's `exploration.md` if present.
- `none`: use only the context passed in the prompt.

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `proposal`.
- `openspec`: read `_shared/openspec-convention.md`. Save `proposal.md`. Never force `openspec/` creation.
- `hybrid`: follow both conventions; write both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return the proposal inline only.

## Optional Research Evidence

When external facts materially affect the proposal, record the optional
source-backed handoff in `_shared/research-evidence.md`. It is optional, persists
through the resolved backend (`none` stays inline with no writes), keeps confirmed
product choices separate from researched claims, and never infers user consent
from a source. Use `impact-analysis`/`bug-diagnosis` for the evidence itself
instead of a separate research lifecycle.

## What to Do

### Step 1: Read Existing Context and Specs

Load project context and any prior exploration or specs relevant to this change. See `rules/execution-read-context.md`.

### Step 2: Write Structured Proposal

Draft the proposal with intent, scope, approach, rollback plan, and success criteria. See `rules/execution-write-proposal.md`.

### Step 3: Return Proposal Summary

Compile the proposal into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- Every proposal MUST have a rollback plan and success criteria
- Use concrete file paths — never abstract references
- Never force openspec creation; apply `rules.proposal` from config.yaml
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
