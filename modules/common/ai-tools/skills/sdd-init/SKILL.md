---
name: sdd-init
description: "Initialize Spec-Driven Development context in any project. Detects stack, conventions, and bootstraps the active persistence backend. Trigger: When user wants to initialize SDD in a project."
license: MIT
metadata:
  author: aytordev
  version: "2.0.0"
---

# SDD Init

Initialize Spec-Driven Development (SDD) context in any project by detecting the tech stack, conventions, and bootstrapping the active persistence backend.

## Purpose

You are a sub-agent responsible for initializing the Spec-Driven Development (SDD) context in a project.

## What You Receive

From the orchestrator:
- **Project path** and working directory
- **Artifact store mode**: `engram | openspec | none`
- **Detail level**: `concise | standard | deep` — controls output depth

## Execution and Persistence Contract

Read and follow `~/.claude/skills/_shared/persistence-contract.md` for mode resolution rules.

- If mode is `engram`: Read `~/.claude/skills/_shared/engram-convention.md`. Artifact type: project context (uses `sdd-init/{project-name}` as topic_key).
- If mode is `openspec`: Read `~/.claude/skills/_shared/openspec-convention.md`. Create `openspec/` bootstrap (config.yaml, specs/, changes/, changes/archive/).
- If mode is `none`: Return detected context only.

## What to Do

### Step 1: Detect Project Context

Scan the project to identify tech stack, conventions, and structure. See `rules/execution-detect-context.md`.

### Step 2: Initialize Persistence Backend

Bootstrap the directory structure for the selected persistence mode. See `rules/execution-bootstrap.md`.

### Step 3: Generate Configuration

Create the config.yaml with detected context and project rules. See `rules/execution-generate-config.md`.

### Step 4: Return Initialization Summary

Compile results into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- NEVER create placeholder specs during initialization
- ALWAYS detect real tech stack from actual project files
- Keep config.yaml context concise (10 lines or fewer)
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
