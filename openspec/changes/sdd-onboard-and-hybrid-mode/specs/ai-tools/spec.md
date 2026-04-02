# Delta Spec: ai-tools — sdd-onboard-and-hybrid-mode

**Delta type**: ADDED (new capabilities)
**Version**: 1.0.0
**Date**: 2026-04-02

---

## Capability: sdd-onboard

### REQ-ONBOARD-01: Skill existence and structure

The `sdd-onboard` skill MUST exist at `modules/common/ai-tools/skills/sdd-onboard/` following the local modular architecture.

**Scenario 1 — Skill file present**
- **Given** the ai-tools module is built
- **When** an agent looks up `~/.claude/skills/sdd-onboard/SKILL.md`
- **Then** the file exists and contains a valid SKILL.md with `name: sdd-onboard`, a trigger, and references to its rules

**Scenario 2 — Rules directory present**
- **Given** the skill is installed
- **When** an agent reads `~/.claude/skills/sdd-onboard/rules/`
- **Then** the directory contains at least: `execution-phases.md`, `execution-phase-selection.md`, `constraints-rules.md`

### REQ-ONBOARD-02: Guided cycle behavior

The skill MUST guide users through all 8 SDD phases in order: explore → propose → spec → design → tasks → apply → verify → archive.

**Scenario 3 — Phase narration**
- **Given** the sdd-onboard sub-agent is launched
- **When** it executes each phase
- **Then** it narrates what is happening and why before executing each phase

**Scenario 4 — Pause at proposal**
- **Given** the sdd-onboard sub-agent is running
- **When** the proposal phase completes
- **Then** it presents the proposal to the user and asks for review/confirmation before continuing

**Scenario 5 — Real codebase change**
- **Given** the sdd-onboard sub-agent scans the codebase
- **When** selecting a change to demonstrate
- **Then** it selects a real, small improvement (not a toy example) that meets the criteria: small scope, low risk, real value, spec-worthy

### REQ-ONBOARD-03: Command availability

The `/sdd-onboard` command MUST be available to the AI agent.

**Scenario 6 — Command file present**
- **Given** the ai-tools module is built
- **When** an agent receives a `/sdd-onboard` command
- **Then** it is dispatched to the `sdd-orchestrator` agent with the `sdd-onboard` subtask

---

## Capability: hybrid-persistence

### REQ-HYBRID-01: Mode definition

The `persistence-contract.md` MUST define `hybrid` as a valid artifact store mode.

**Scenario 7 — Mode mentioned in contract**
- **Given** a sub-agent reads `~/.claude/skills/_shared/persistence-contract.md`
- **When** it looks up valid modes
- **Then** it finds `engram | openspec | hybrid | none` as the complete set

**Scenario 8 — Hybrid behavior defined**
- **Given** an artifact store mode of `hybrid` is passed
- **When** a sub-agent persists an artifact
- **Then** it MUST write to BOTH Engram (via `mem_save`) AND the filesystem (per openspec-convention)

### REQ-HYBRID-02: Read priority in hybrid mode

**Scenario 9 — Read fallback order**
- **Given** mode is `hybrid`
- **When** a sub-agent retrieves a prior artifact
- **Then** it reads from Engram first; falls back to filesystem if Engram returns no results

### REQ-HYBRID-03: Bootstrap in sdd-init

The `sdd-init` skill MUST handle hybrid bootstrap correctly.

**Scenario 10 — Hybrid init**
- **Given** sdd-init is launched with mode `hybrid`
- **When** it completes initialization
- **Then** it creates the openspec/ directory structure AND saves context to Engram
- **And** the return summary shows both backends as active
