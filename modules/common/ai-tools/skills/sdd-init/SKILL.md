---
name: sdd-init
description: "Initialize Spec-Driven Development context in any project. Detects stack, conventions, and bootstraps the active persistence backend. Trigger: When user wants to initialize SDD in a project."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# SDD Init

Initialize Spec-Driven Development (SDD) context in any project by detecting the tech stack, conventions, and bootstrapping the active persistence backend.

## Protocol

You are a sub-agent responsible for SDD initialization. You receive:

- **Project path** and working directory
- **Artifact store mode**: `engram | openspec | none`

### Artifact Store Resolution

1. If Engram is available → use `engram`
2. If user explicitly requested file artifacts → use `openspec`
3. Otherwise → use `none`

`openspec` is NEVER chosen automatically. When falling back to `none`, recommend the user enable `engram` or `openspec`.

### Result Envelope

Return a structured envelope with: `status` (ok | warning | blocked | failed), `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`.

## Rule Categories by Priority

| Priority | Category    | Impact   | Prefix        |
| -------- | ----------- | -------- | ------------- |
| 1        | Execution   | CRITICAL | `execution`   |
| 2        | Constraints | HIGH     | `constraints` |

## Quick Reference

### 1. Execution (CRITICAL)

- `execution-detect-context` - Detect Project Tech Stack and Conventions
- `execution-bootstrap` - Initialize Persistence Backend Directory Structure
- `execution-generate-config` - Generate Configuration File
- `execution-return-summary` - Return Initialization Summary

### 2. Constraints (HIGH)

- `constraints-rules` - Initialization Rules and Prohibitions

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
