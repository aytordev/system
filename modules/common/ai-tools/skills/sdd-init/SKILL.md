---
name: sdd-init
description: "Initialize Spec-Driven Development context in any project. Detects stack, conventions, and bootstraps the active persistence backend. Trigger: When user wants to initialize SDD in a project."
---

# SDD Init

Initialize Spec-Driven Development (SDD) context in any project by detecting the tech stack, conventions, and bootstrapping the active persistence backend.

## Purpose

You are a sub-agent responsible for initializing the Spec-Driven Development (SDD) context in a project.

## What You Receive

From the orchestrator:
- **Project path** and working directory
- **Resolved backend**: `engram | openspec | hybrid | none`, plus its source
  (`explicit` | `available-selected` | `recorded`)
- **Artifact Locators**: the project-context locator for the resolved backend
- **Detail level**: `concise | standard | deep` — controls output depth

## Execution and Persistence Contract

Shared-protocol paths below are relative to the configured skills root (the
directory that contains this skill package).

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

Initialize only the **resolved** backend. If the orchestrator did not resolve one,
resolve it per `persistence-contract.md`; if it remains unusable, ask before
creating anything.

- `engram`: Read `_shared/engram-convention.md`. Artifact type: project context (uses `sdd-init/{project-name}` as topic_key).
- `openspec`: Read `_shared/openspec-convention.md`. Create `openspec/` bootstrap (config.yaml, specs/, changes/, changes/archive/).
- `hybrid`: Read and follow BOTH convention files. Run the full openspec bootstrap AND save project context to Engram. A one-sided write is `partial`, not success; retry per the contract.
- `none`: Return detected context only; write nothing and promise no recovery.

## What to Do

### Step 1: Detect Project Context

Scan the project to identify tech stack, conventions, and structure. See `rules/execution-detect-context.md`.

### Step 2: Detect Testing Capabilities

Discover the in-scope project roots and associate each runner or check command
with its working directory, covered targets, and surface (runtime vs Nix
evaluation vs derivation build). Persist results for downstream use. See
`rules/execution-detect-testing.md`.

### Step 3: Resolve Strict TDD Mode

Resolve the requested policy separately from executable capability and produce
`enabled`/`disabled`/`blocked`, reporting a blocker for an explicit request with
missing prerequisites. See `rules/execution-strict-tdd-resolution.md`.

### Step 4: Initialize Persistence Backend

Bootstrap the directory structure for the selected persistence mode. See `rules/execution-bootstrap.md`.

### Step 5: Generate Configuration

Create the config.yaml with detected context and project rules. See `rules/execution-generate-config.md`.

### Step 6: Build Skill Registry Index

Discover available skills and project conventions, then produce the index
(`name`, full `description`, `scope`, exact `SKILL.md` path, `freshness`) by
following the same logic as the `skill-registry` skill. Persist it according to
the active mode: session-only in `none`, to Engram in `engram`, and to
`.atl/skill-registry.md` in `openspec`/`hybrid`. Never generate compact rules.

### Step 7: Persist Context to Engram

For `engram` and `hybrid` modes: save the full project context snapshot to Engram after the skill registry is built. See `rules/execution-persist-context.md`.

### Step 8: Return Initialization Summary

Compile results into the structured result envelope. See `rules/execution-return-summary.md`.

Consult `references/` for templates and formats.

## Rules

- NEVER create placeholder specs during initialization
- ALWAYS detect real tech stack from actual project files
- Keep config.yaml context concise (10 lines or fewer)
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, `risks`

See `rules/constraints-rules.md` for complete rules.
