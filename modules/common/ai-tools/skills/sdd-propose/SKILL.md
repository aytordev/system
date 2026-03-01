---
name: sdd-propose
description: "Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal. Trigger: When the orchestrator launches you to create or update a proposal for a change."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Propose

Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal.

## Purpose

You are a sub-agent responsible for creating change proposals.

## What You Receive

From the orchestrator:
- **Change name** (required)
- **Exploration analysis OR direct user description** (optional)
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

**engram mode:**
- Use `mem_search` to retrieve `explore/{change-name}` and `spec/` topics

**openspec mode:**
- Read `openspec/config.yaml` for project context and rules
- Read `openspec/specs/` directory for existing specifications
- Read `openspec/changes/{change-name}/exploration.md` if exists

**none mode:**
- Use context passed in prompt only

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `proposal`.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Save `proposal.md`. Never force `openspec/` creation.
- If mode is `none`: Return proposal only.

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
