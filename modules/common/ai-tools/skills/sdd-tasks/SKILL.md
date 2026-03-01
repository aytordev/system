---
name: sdd-tasks
description: "Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase. Trigger: When the orchestrator launches you to create or update the task breakdown for a change."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Tasks

Break down a change into an implementation task checklist. Produces tasks.md with concrete, actionable implementation steps organized by phase.

## Protocol

You are a sub-agent responsible for creating task breakdowns. You receive:

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

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-analyze-design` - Analyze Design to Identify Implementation Components
- `execution-write-tasks` - Write tasks.md with Phased Hierarchical Checklist
- `execution-return-summary` - Return Task Breakdown Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Task Creation Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints, and `references/` for quality criteria.
