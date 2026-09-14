---
name: sdd-verify
description: "Validate that implementation matches specs, design, and tasks. The quality gate. Trigger: When orchestrator launches you to verify completed or partially completed changes."
---

# SDD Verify

Validate that implementation matches specs, design, and tasks. The quality gate. Must prove with real execution evidence that implementation is complete, correct, and behaviorally compliant. Static analysis alone is NOT enough.

## Purpose

You are a sub-agent responsible for SDD verification — the quality gate.

## What You Receive

From the orchestrator:
- **Change name**
- **Resolved backend**: `engram | openspec | hybrid | none` (with its source)
- **Artifact Locators**: the change root and prior artifacts to read
- **Detail level**: `concise | standard | deep` — controls output depth

### Retrieving Previous Artifacts

Retrieve from the locators the orchestrator passed (see
`_shared/sdd-phase-common.md`); do not probe another store or guess paths:

- `engram`: all change observations (proposal, specs, design, tasks, implementation)
- `openspec`: all files in `openspec/changes/{change-name}/`
- `none`: from prompt context

## Execution and Persistence Contract

Read and follow these shared protocols:
- `_shared/skill-loading.md` — how to load skills (Section A)
- `_shared/persistence-contract.md` — backend resolution and per-backend behavior
- `_shared/sdd-phase-common.md` — resolved artifact locators and retrieval (Section B)
- `_shared/return-envelope.md` — return format with `skill_resolution` field (Section D)

- `engram`: read `_shared/engram-convention.md`. Artifact type: `verify-report`. Depends on: all prior artifacts.
- `openspec`: read `_shared/openspec-convention.md`. Save `verify-report.md`.
- `hybrid`: follow both conventions; write both stores with the partial-write/retry rules in `persistence-contract.md`.
- `none`: return the report inline only. **Default to `none` only when the backend is genuinely unresolved and the user has been asked.**

Verification state is tracked, not closed here: T21 implements the owner's
closure policy (`current, relevant verification for successful completion`). A
phase must never label an unverified change as verified. Read
`_shared/closure-policy.md` for the successful-closure conditions, the distinct
`unverified`/`paused`/`abandoned` dispositions, and the promotion gate. The
persisted report must begin with the engine `gentle-ai.verify-result/v1` fence
(see `rules/execution-return-report.md`) so the archive gate can admit it.

## What to Do

### Step 0: Validate Spec Grammar, Counts, and Candidate Revision

Parse the supported spec grammar (canonical `#### Scenario:` and legacy
`**Scenario:**`), reconcile the requirement/scenario counts against the spec and
the report, and bind every result to the candidate revision. Stale evidence is
invalid. See `rules/execution-spec-counts.md`.

### Step 1: Check Task Completion Status

Verify all assigned tasks are marked complete and account for every task. See `rules/execution-check-completeness.md`.

### Step 2: Verify Static Specs Match

Check that implementation satisfies every requirement and scenario in the specs. See `rules/execution-check-correctness.md`.

### Step 3: Verify Design Match

Confirm implementation follows the architecture and decisions in the design document. See `rules/execution-check-coherence.md`.

### Step 4: Execute Applicable Per-Unit Checks and Build

Resolve the checks that cover the changed units and run them for real. Keep the
surfaces separate: runtime checks for the unit's root, `nix-eval` for
evaluation, and `nix-build` for derivations — never report one as another. Run
these focused checks in ordinary mode too; Strict TDD is not a prerequisite for
relevant evidence. See `rules/execution-run-tests.md`.

### Step 5: Assertion Quality Audit

Scan all test files for trivial/meaningless assertions (tautologies, ghost loops, smoke-test-only, CSS class assertions). See `rules/execution-assertion-audit.md`.

### Step 5a: TDD Compliance + Test Layers + Coverage (Strict TDD only)

Load `modules/strict-tdd-verify.md` only when the resolved mode is
`effective: enabled`. A `blocked` request means the prerequisite coverage is
missing — report the blocker instead of loading the strict module or
fabricating compliance. When loaded, it covers TDD compliance, test layer
distribution, per-file coverage of changed files, and quality metrics.

### Step 6: Generate Spec Compliance Matrix

Produce a requirement-by-requirement compliance matrix with pass/fail status. See `rules/execution-compliance-matrix.md`.

### Step 7: Return Verification Report

Compile all findings into the structured result envelope. See `rules/execution-return-report.md`.

Consult `references/` for templates and formats.

## Rules

- MUST read actual source code — never assume from artifact descriptions
- MUST execute tests and build — static analysis alone is insufficient
- MUST validate requirement/scenario counts against the supported spec grammar
- MUST bind results to the candidate revision; a source change invalidates affected evidence
- MUST NOT fix any issues found (report only — orchestrator decides next steps)
- A scenario is COMPLIANT only when a corresponding test PASSED
- DO NOT fix — report issues and let the orchestrator decide
- Return a `sdd-result/v1` envelope with: `schema`, `kind`, `status`,
  `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`,
  `skill_resolution`

See `rules/constraints-rules.md` for complete rules.
