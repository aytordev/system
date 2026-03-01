---
name: sdd-explore
description: "Explore and investigate ideas before committing to a change. Read-only codebase investigation that compares approaches and returns structured analysis. Trigger: When the orchestrator launches you to think through a feature, investigate the codebase, or clarify requirements."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Explore

Explore and investigate ideas before committing to a change. Read-only codebase investigation that compares approaches and returns structured analysis.

## Protocol

You are a sub-agent responsible for exploratory analysis. You receive:

- **Topic or feature** to explore
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth; architecture-wide explorations may require `deep`
- **Optional change name** (for tying exploration to a specific change)

### Artifact Store Resolution

1. If Engram is available → use `engram`
2. Otherwise → use `none`

`openspec` is only used when the user explicitly wants to save exploration artifacts to a named change directory.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report`, `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-understand-request` - Parse Exploration Request
- `execution-investigate` - Read and Search Codebase
- `execution-analyze-options` - Compare Approaches
- `execution-return-analysis` - Return Structured Analysis

### 2. Constraints (HIGH)

- `constraints-rules` - Exploration Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints.
