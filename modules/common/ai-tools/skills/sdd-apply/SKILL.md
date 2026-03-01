---
name: sdd-apply
description: "Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them. Trigger: When the orchestrator launches you to implement one or more tasks from a change."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Apply

Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them.

## Purpose

You are a sub-agent responsible for implementing tasks.

## What You Receive

From the orchestrator:
- **Change name** (the specific change being worked on)
- **Specific task(s)** to implement (e.g., "Phase 1, tasks 1.1-1.3")
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

You need ALL previous artifacts (proposal, specs, design, tasks):

- **engram mode**: Use `mem_search` to retrieve:
  - `proposal/{change-name}`
  - `spec/{change-name}`
  - `design/{change-name}`
  - `tasks/{change-name}`
- **openspec mode**: Read from filesystem:
  - `openspec/changes/{change-name}/proposal.md`
  - `openspec/changes/{change-name}/specs/`
  - `openspec/changes/{change-name}/design.md`
  - `openspec/changes/{change-name}/tasks.md`
  - `openspec/config.yaml`
- **none mode**: Receive artifacts from prompt context

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `apply-progress`. Depends on: `spec`, `design`, `tasks`.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Update `tasks.md` with completion marks.
- If mode is `none`: Return progress only.

## What to Do

### Step 1: Read Specs, Design, Tasks, and Existing Code

Load all prior artifacts and understand the current codebase state. See `rules/execution-read-context.md`.

### Step 2: Detect Implementation Mode (TDD vs Standard)

Determine whether the project uses TDD or standard implementation workflow. See `rules/execution-detect-mode.md`.

### Step 3: TDD Workflow (RED -> GREEN -> REFACTOR)

If TDD detected, follow the red-green-refactor cycle for each task. See `rules/execution-tdd-workflow.md`.

### Step 4: Standard Implementation Workflow

If no TDD framework detected, implement tasks following standard workflow. See `rules/execution-standard-workflow.md`.

### Step 5: Mark Tasks Complete and Return Summary

Update task status and compile results into the structured result envelope. See `rules/execution-mark-complete.md`.

## Rules

- MUST read specs and design before writing any code
- MUST follow design decisions — never silently deviate
- MUST NOT implement tasks not assigned to this invocation
- If TDD detected, never skip the RED phase (write failing test first)
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
