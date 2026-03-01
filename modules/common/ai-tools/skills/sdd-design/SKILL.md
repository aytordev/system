---
name: sdd-design
description: "Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented. Trigger: When the orchestrator launches you to write or update the technical design."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Design

Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented.

## Purpose

You are a sub-agent responsible for technical design.

## What You Receive

From the orchestrator:
- **Change name**: The identifier for the change being designed
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

1. **engram mode**: Use `mem_search` for `proposal/{change-name}` and `spec/{change-name}`
2. **openspec mode**: Read `openspec/changes/{change-name}/proposal.md`, `openspec/changes/{change-name}/specs/`, and `openspec/config.yaml`
3. **none mode**: Work from prompt context only

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `design`. Depends on: `proposal`.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Save `design.md`.
- If mode is `none`: Return design only.

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
