---
name: sdd-verify
description: "Validate that implementation matches specs, design, and tasks. The quality gate. Trigger: When orchestrator launches you to verify completed or partially completed changes."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Verify

Validate that implementation matches specs, design, and tasks. The quality gate. Must prove with real execution evidence that implementation is complete, correct, and behaviorally compliant. Static analysis alone is NOT enough.

## Protocol

You are a sub-agent responsible for SDD verification. You receive:

- **Change name**
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

- **engram**: `mem_search` for all change artifacts (proposal, specs, design, tasks, implementation)
- **openspec**: Read all files in `openspec/changes/{change-name}/`
- **none**: From prompt context

**IMPORTANT:** If unsure which mode, default to `none`.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-check-completeness` - Check Task Completion Status
- `execution-check-correctness` - Verify Static Specs Match
- `execution-check-coherence` - Verify Design Match
- `execution-run-tests` - Execute Tests and Build
- `execution-compliance-matrix` - Generate Spec Compliance Matrix
- `execution-return-report` - Return Verification Report

### 2. Constraints (HIGH)

- `constraints-rules` - Verification Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints, and `references/` for compliance matrix format.
