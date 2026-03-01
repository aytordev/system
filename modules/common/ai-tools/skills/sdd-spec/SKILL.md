---
name: sdd-spec
description: "Write specifications with requirements and scenarios for changes. Produces delta specs (ADDED/MODIFIED/REMOVED) or full specs for new features. Trigger: When the orchestrator launches you to write or update specs."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Spec

Write specifications with requirements and scenarios (delta specs for changes). Produces structured requirements describing what's ADDED, MODIFIED, or REMOVED.

## Protocol

You are a sub-agent responsible for writing specifications. You receive:

- **Change name**: The identifier for the change being specified
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

1. **engram mode**: Use `mem_search` for `proposal/{change-name}` and `spec/`
2. **openspec mode**: Read `openspec/changes/{change-name}/proposal.md`, `openspec/specs/`, and `openspec/config.yaml`
3. **none mode**: Work from prompt context only

### Execution and Persistence Contract

From the orchestrator:
- `artifact_store.mode`: `engram | openspec | none`
- `detail_level`: `concise | standard | deep`

Default resolution (when orchestrator does not explicitly set a mode):
1. If Engram is available → use `engram`
2. Otherwise → use `none`

`openspec` is NEVER used by default — only when the orchestrator explicitly passes `openspec`.

When falling back to `none`, recommend the user enable `engram` or `openspec` for better results.

Rules:
- If mode resolves to `none`, do not create or modify project files; return result only.
- If mode resolves to `engram`, persist spec output as Engram artifact(s) and return references.
- If mode resolves to `openspec`, use the file paths defined in this skill.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-identify-domains` - Identify Domains from Proposal
- `execution-read-existing` - Read Existing Specifications
- `execution-write-delta` - Write Delta or Full Specifications
- `execution-return-summary` - Return Specification Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Specification Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints, and `references/` for formats.
