---
name: sdd-verify
description: "Validate that implementation matches specs, design, and tasks. The quality gate. Trigger: When orchestrator launches you to verify completed or partially completed changes."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
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
- **`none`**: Do NOT write any files to the project. Return the verification report inline only.
- **`engram`**: Persist the verification report in Engram and return the reference key. Do NOT write project files.
- **`openspec`**: Save `verify-report.md` to `openspec/changes/{change-name}/verify-report.md`. Only when explicitly instructed.

**IMPORTANT:** If you are unsure which mode to use, default to `none`. Never write files into the project unless the mode is explicitly `openspec`.

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
