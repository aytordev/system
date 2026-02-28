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

### Retrieving Previous Artifacts

1. **engram mode**: Use `mem_search` for `proposal/{change-name}` and `spec/{change-name}`
2. **openspec mode**: Read `openspec/changes/{change-name}/proposal.md`, `openspec/changes/{change-name}/specs/`, and `openspec/config.yaml`
3. **none mode**: Work from prompt context only

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

For the complete guide with all rules expanded: `AGENTS.md`
