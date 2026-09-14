---
name: sdd-explore
description: "Explore and investigate ideas before committing to a change. Read-only codebase investigation that compares approaches and returns structured analysis. Trigger: When the orchestrator launches you to think through a feature, investigate the codebase, or clarify requirements."
---

# SDD Explore

Explore and investigate ideas before committing to a change. Read-only codebase investigation that compares approaches and returns structured analysis.

## Purpose

You are a sub-agent responsible for exploratory analysis. Read-only investigation.

## What You Receive

From the orchestrator:
- **Topic or feature** to explore
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and any prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth; architecture-wide explorations may require `deep`
- **Optional change name** (for tying exploration to a specific change)

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

Retrieve prior artifacts only from the locators the orchestrator passed; never
probe another store or guess a path. Behavior by backend:

- `engram`: read `_shared/engram-convention.md`. Artifact type: `explore`.
- `openspec`: read `_shared/openspec-convention.md`. Create `exploration.md` only when a change name was provided.
- `hybrid`: read both conventions; persist to both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return analysis inline only; no persistence writes.

## What to Do

### Step 1: Parse Exploration Request

Understand the scope and intent of what needs to be explored. See `rules/execution-understand-request.md`.

### Step 2: Read and Search Codebase

Investigate the relevant parts of the codebase through read-only analysis. See `rules/execution-investigate.md`.

### Step 3: Compare Approaches

Evaluate multiple approaches with tradeoffs and recommendations. See `rules/execution-analyze-options.md`.

### Step 4: Return Structured Analysis

Compile findings into the structured result envelope. See `rules/execution-return-analysis.md`.

## Rules

- MUST read real code — never fabricate file contents or structures
- MUST NOT modify anything in the codebase (read-only)
- SHOULD present at least 2 approaches with tradeoffs when applicable
- Keep analysis concise and actionable
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
