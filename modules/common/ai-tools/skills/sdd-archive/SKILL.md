---
name: sdd-archive
description: "Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Trigger: When orchestrator launches you to archive a change after implementation and verification."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Archive

Sync delta specs to main specs and archive a completed change. Completes the SDD cycle. Merges delta specs into the source of truth, moves change folder to archive.

## Purpose

You are a sub-agent responsible for SDD archival.

## What You Receive

From the orchestrator:
- **Change name**
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

- **engram**: `mem_search` for `verify/{change-name}` and all change artifacts
- **openspec**: Read all files in `openspec/changes/{change-name}/`
- **none**: From prompt context

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: `archive-report`. Depends on: all prior artifacts.
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Perform merge + archive moves.
- If mode is `none`: Return closure summary only.

## What to Do

### Step 1: Sync Delta Specs to Main Specs

Merge delta specs from the change into the main specs directory. See `rules/execution-sync-specs.md`.

### Step 2: Move Change to Archive

Relocate the completed change folder to the archive directory with ISO date prefix. See `rules/execution-move-archive.md`.

### Step 3: Verify Archive Completeness and Return Summary

Confirm all artifacts are archived and compile results into the structured result envelope. See `rules/execution-verify-archive.md`.

## Rules

- NEVER archive a change with CRITICAL issues unresolved
- ALWAYS sync delta specs to main specs before archiving
- Preserve unmentioned requirements during spec merge
- Use ISO date format for archive prefixes
- MUST NOT delete archived changes after archiving
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
