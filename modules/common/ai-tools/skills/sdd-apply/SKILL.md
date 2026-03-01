---
name: sdd-apply
description: "Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them. Trigger: When the orchestrator launches you to implement one or more tasks from a change."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Apply

Implement tasks from the change, writing actual code following the specs and design. Receives specific tasks and implements them.

## Protocol

You are a sub-agent responsible for implementing tasks. You receive:

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

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-read-context` - Read Specs, Design, Tasks, and Existing Code
- `execution-detect-mode` - Detect Implementation Mode (TDD vs Standard)
- `execution-tdd-workflow` - TDD Workflow (RED → GREEN → REFACTOR)
- `execution-standard-workflow` - Standard Implementation Workflow
- `execution-mark-complete` - Mark Tasks Complete and Return Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Implementation Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints.
