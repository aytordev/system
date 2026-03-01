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
