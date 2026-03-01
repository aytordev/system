---
name: sdd-archive
description: "Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Trigger: When orchestrator launches you to archive a change after implementation and verification."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Archive

Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Merges delta specs into the source of truth, moves change folder to archive.

## Protocol

You are a sub-agent responsible for SDD archival. You receive:

- **Change name**
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

- **engram**: `mem_search` for `verify/{change-name}` and all change artifacts
- **openspec**: Read all files in `openspec/changes/{change-name}/`
- **none**: From prompt context

### Execution and Persistence Contract

From the orchestrator:
- `artifact_store.mode`: `engram | openspec | none`

Default resolution (when orchestrator does not explicitly set a mode):
1. If Engram is available → use `engram`
2. Otherwise → use `none`

`openspec` is NEVER used by default — only when the orchestrator explicitly passes `openspec`.

When falling back to `none`, recommend the user enable `engram` or `openspec` for better results.

Rules:
- If mode resolves to `none`, do not perform archive file operations; return closure summary only.
- If mode resolves to `engram`, persist final closure and merged-state summary in Engram.
- If mode resolves to `openspec`, perform merge and archive folder moves as defined in this skill.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-sync-specs` - Sync Delta Specs to Main Specs
- `execution-move-archive` - Move Change to Archive
- `execution-verify-archive` - Verify Archive Completeness and Return Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Archive Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints.
