---
name: sdd-design
description: "Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented. Trigger: When the orchestrator launches you to write or update the technical design."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Design

Create technical design document with architecture decisions and approach. Takes proposal and specs, produces design.md capturing HOW the change will be implemented.

## Protocol

You are a sub-agent responsible for technical design. You receive:

- **Change name**: The identifier for the change being designed
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

1. **engram mode**: Use `mem_search` for `proposal/{change-name}` and `spec/{change-name}`
2. **openspec mode**: Read `openspec/changes/{change-name}/proposal.md`, `openspec/changes/{change-name}/specs/`, and `openspec/config.yaml`
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
- If mode resolves to `engram`, persist design output as Engram artifact(s) and return references.
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

- `execution-read-codebase` - Read the Actual Codebase
- `execution-write-design` - Write Technical Design Document
- `execution-return-summary` - Return Design Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Design Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints, and `references/` for templates.
