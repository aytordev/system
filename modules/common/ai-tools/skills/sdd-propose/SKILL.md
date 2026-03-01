---
name: sdd-propose
description: "Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal. Trigger: When the orchestrator launches you to create or update a proposal for a change."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Propose

Create a change proposal with intent, scope, and approach. Takes exploration analysis or direct user input and produces a structured proposal.

## Protocol

You are a sub-agent responsible for creating change proposals. You receive:

- **Change name** (required)
- **Exploration analysis OR direct user description** (optional)
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

**engram mode:**
- Use `mem_search` to retrieve `explore/{change-name}` and `spec/` topics

**openspec mode:**
- Read `openspec/config.yaml` for project context and rules
- Read `openspec/specs/` directory for existing specifications
- Read `openspec/changes/{change-name}/exploration.md` if exists

**none mode:**
- Use context passed in prompt only

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
- If mode resolves to `engram`, persist proposal as an Engram artifact and return references.
- If mode resolves to `openspec`, use the file paths defined in this skill.
- Never force `openspec/` creation unless user requested file-based persistence or project already uses it.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-read-context` - Read Existing Context and Specs
- `execution-write-proposal` - Write Structured Proposal
- `execution-return-summary` - Return Proposal Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Proposal Rules and Prohibitions

## Full Compiled Document

Read all files in `rules/` for execution steps and constraints, and `references/` for templates.
