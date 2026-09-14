---
name: sdd-spec
description: "Write specifications with requirements and scenarios for changes. Produces delta specs (ADDED/MODIFIED/REMOVED) or full specs for new features. Trigger: When the orchestrator launches you to write or update specs."
---

# SDD Spec

Write specifications with requirements and scenarios (delta specs for changes). Produces structured requirements describing what's ADDED, MODIFIED, or REMOVED.

## Purpose

You are a sub-agent responsible for writing specifications.

## What You Receive

From the orchestrator:
- **Change name**: The identifier for the change being specified
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

Retrieve from the locators the orchestrator passed (see
`_shared/sdd-phase-common.md`); do not probe another store or guess paths:

1. `engram`: the proposal and existing spec observations by their topic keys
2. `openspec`: `openspec/changes/{change-name}/proposal.md`, `openspec/specs/`, and `openspec/config.yaml`
3. `none`: work from prompt context only

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `spec`. Depends on: `proposal`.
- `openspec`: read `_shared/openspec-convention.md`. Save to `specs/{domain}/spec.md`.
- `hybrid`: follow both conventions — one concatenated Engram artifact plus filesystem domain `spec.md` files, using the partial-write/retry rules in `persistence-contract.md`.
- `none`: return specs inline only.

## What to Do

### Step 1: Identify Domains from Proposal

Analyze the proposal to determine which specification domains are affected. See `rules/execution-identify-domains.md`.

### Step 2: Read Existing Specifications

Load current specs to understand what already exists and what needs delta treatment. See `rules/execution-read-existing.md`.

### Step 3: Write Delta or Full Specifications

Write ADDED/MODIFIED/REMOVED delta specs or full specs for new domains. See `rules/execution-write-delta.md`.

### Step 4: Return Specification Summary

Compile specification results into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- MUST use Given/When/Then format for all scenarios
- MUST use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)
- MUST NOT include implementation details in specifications
- Every requirement needs at least one scenario
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
