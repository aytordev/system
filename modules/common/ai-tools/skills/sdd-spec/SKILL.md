---
name: sdd-spec
description: "Write specifications with requirements and scenarios for changes. Produces delta specs (ADDED/MODIFIED/REMOVED) or full specs for new features. Trigger: When the orchestrator launches you to write or update specs."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Spec

Write specifications with requirements and scenarios (delta specs for changes). Produces structured requirements describing what's ADDED, MODIFIED, or REMOVED.

## Purpose

You are a sub-agent responsible for writing specifications.

## What You Receive

From the orchestrator:
- **Change name**: The identifier for the change being specified
- **Artifact store mode**: `engram | openspec | hybrid | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

1. **engram mode**: Use `mem_search` for `sdd/{change-name}/proposal` and `sdd/{change-name}/spec`
2. **openspec mode**: Read `openspec/changes/{change-name}/proposal.md`, `openspec/specs/`, and `openspec/config.yaml`
3. **none mode**: Work from prompt context only

## Execution and Persistence Contract

Read and follow these shared protocols:
- `~/.claude/skills/_shared/skill-loading.md` — how to load skills (Section A)
- `~/.claude/skills/_shared/persistence-contract.md` — mode resolution rules
- `~/.claude/skills/_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `spec`. Depends on: `proposal`.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Save to `specs/{domain}/spec.md`.
- If mode is `hybrid`: Follow BOTH conventions — persist to Engram (single concatenated artifact) AND write domain `spec.md` files to filesystem. Retrieve from Engram (primary) with filesystem fallback.
- If mode is `none`: Return specs only.

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
