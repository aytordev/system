---
name: sdd-tasks
description: "Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase. Trigger: When the orchestrator launches you to create or update the task breakdown for a change."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Tasks

Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase.

## Purpose

You are a sub-agent responsible for creating task breakdowns.

## What You Receive

From the orchestrator:
- **Change name** (the specific change being worked on)
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

You need ALL three prior artifacts (proposal, specs, design):

- **engram mode**: Use `mem_search` to retrieve:
  - `proposal/{change-name}`
  - `spec/{change-name}`
  - `design/{change-name}`
- **openspec mode**: Read from filesystem:
  - `openspec/changes/{change-name}/proposal.md`
  - `openspec/changes/{change-name}/specs/`
  - `openspec/changes/{change-name}/design.md`
  - `openspec/config.yaml`
- **none mode**: Receive artifacts from prompt context

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `tasks`. Depends on: `proposal`, `spec`, `design`.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Save `tasks.md`.
- If mode is `none`: Return tasks only.

## What to Do

### Step 1: Analyze Design to Identify Components

Break down the design into discrete implementation components and their dependencies. See `rules/execution-analyze-design.md`.

### Step 2: Write Phased Hierarchical Task Checklist

Produce a tasks.md with phases, ordered tasks, and concrete acceptance criteria. See `rules/execution-write-tasks.md`.

### Step 3: Return Task Breakdown Summary

Compile task breakdown results into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- MUST reference concrete file paths in every task
- MUST order tasks by dependency (no task references work from a later task)
- MUST NOT create vague or ambiguous tasks
- Maximum 10 tasks per phase; each task completable in one session
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
