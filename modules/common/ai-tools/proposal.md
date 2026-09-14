# Make AI Workflows Reliable, Portable, and Maintainable in System

Status: Proposed; agreed scope, implementation pending.

Deliver the same supported workflows in **OpenCode and Pi**, preserve the original
meaning of skills, and make state, model routing, and completion verifiable.
Use current gentle-ai assets through a pinned, compatible migration and take
selected operational methods from khanelinix. The value is usable, maintainable
capability in `system`, not a larger skill inventory.

## Read the proposal

| Document | Purpose |
| --- | --- |
| [ADR 0015](../../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md) | Audit evidence, shared workflow architecture, and comparison of engine/closure alternatives. |
| [ADR 0016](../../../docs/decisions/0016-keep-skills-canonical-and-registry-derived.md) | Canonical skill authorship and a derived, index-first registry. |
| [ADR 0017](../../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md) | Current upstream baseline, compatible bundles, provenance, state migration, and rollback. |
| [Implementation plan](implementation-plan.md) | Prioritized tasks, dependencies, affected surfaces, tradeoffs, and acceptance evidence. |

The ADRs preserve the reasoning. This proposal summarizes expected outcomes; the
plan is the single place to track implementation progress.

## Value to the owner and maintainer

| Outcome | Current friction | Proposed improvement | Evidence of value |
| --- | --- | --- | --- |
| Use either client confidently | Shared files do not guarantee working commands, delegation, or memory. | Native adapters over one explicit workflow contract. | The same representative workflow completes and resumes in both clients. |
| Control home behavior | Declared MCP servers do not reach OpenCode; selection is implicit in the catalog. | Empty reusable selection; both homes explicitly choose Engram/filesystem/nixos for both clients. | Effective configuration and runtime discovery match the selected set. |
| Preserve skill intent | Generated compact rules replace originals and can omit conditions. | Keep creator and registry, index exact paths, load selected original contracts. | Required referenced rules remain available; discovery/freshness tests pass. |
| Trust reported progress | Task state, envelopes, workload forecasts, and verification can disagree. | Typed handoffs, persisted completion readback, relevant current evidence. | Stale, malformed, incomplete, and interrupted cases cannot report false success. |
| Update without losing local value | Upstream has evolved beyond the inherited prompts. | Pinned compatible bundles with explicit adaptations and legacy-state handling. | Every adopted item has provenance and a verified consumer; rollback preserves user artifacts. |
| Match process to the task | SDD is well represented; lighter diagnosis and operational methods are less complete. | Preserve SDD and add focused Nix operations, diagnosis, impact, and a lightweight path. | Representative tasks select the appropriate method without unnecessary SDD artifacts. |

These are acceptance targets, not measured productivity or cost claims. Capture
baseline/candidate results before claiming faster execution, fewer interventions,
or lower token usage.

## Agreed scope

- Full support in both clients, with a locally owned minimal Pi integration.
- Explicit per-home MCP selection; Engram is preferred when selected and available.
  OpenSpec, hybrid, and no-persistence remain explicit supported choices.
- Configurable role models with home overrides and native client ID translation.
- Separate canonical authoring from derived indexing; preserve scoped conventions
  and use progressive loading.
- Use current upstream skills as the reviewed starting point. Freeze a coherent
  source revision, migrate its dependency bundles, and retain a traceable local
  derivation where `system` policy or client integration differs.
- Add the selected domain/workflow methods, with relevant verification and
  dependency/provenance records.

## Migration path

1. **Freeze the source and compatibility baseline** (T24, T01). Review newer
   gentle-ai changes since the audit and inventory local adaptations/dependencies.
2. **Establish the skill and shared contracts** (T17, T02, T18). Migrate authoring
   and loading as coordinated changes, including old registry caches.
3. **Choose the engine using prototypes** (T19). Compare the CLI and a local
   engine against the same client, persistence, failure, and recovery scenarios.
4. **Implement contracts and prove old-state compatibility** (client/workflow
   tasks, T25). Preserve memory, active changes, and historical reports; separate
   code and data rollback.
5. **Assemble and deploy compatible bundles** (T26, T08). Adopt the selected newer
   content with tested adapters and old-state handling, rather than updating only
   top-level `SKILL.md` files.
6. **Validate the complete delivery** (T16). Cover both clients/platforms,
   structural checks, runtime transport, and bounded real-model evaluations.

Each bundle can be implemented in reviewable units; its complete dependency
contract must work before it is deployed. New optional methods do not postpone
the first coherent core repair bundle.

## Decisions still open

| Decision | Analysis and recommendation | Resolution point |
| --- | --- | --- |
| Workflow engine | **Decided (2026-09-14):** adopt the pinned `gentle-ai` CLI behind a thin adapter, reusing its validators and archive composer. Chosen after measuring a 305-LOC local slice that reproduced status/readback but not validators, the attempt ledger, concurrency, or archive composition. | T27/T28: package the engine, define the adapter, and close the Engram 1.7.0 integration. |
| Successful SDD closure | **Decided (2026-09-14):** successful completion and canonical spec promotion require current, relevant verification; a pause/abandon/unverified disposition stays distinct and never fabricates PASS. | T21: implement the decided policy. |

Selecting the latest skill baseline does not settle the engine or closure
decisions, both now made. Compatibility with Engram 1.7.0, existing artifacts, and
all selected modes is part of the engine assessment; an upgrade requires its own
justification and migration evidence.

## Costs and tradeoffs

- **Two clients:** parity requires two native integration surfaces and tests.
  Share the contract and engine boundary; avoid duplicate readiness calculations.
- **Original skill loading:** selected full contracts can cost more tokens than
  summaries. Use concise entry points and relevant references; measure the result.
- **A local engine:** we would own state, persistence adapters, concurrency,
  evidence, archive, migration, and tests. Reusing Engram avoids writing a memory
  database, not the workflow engine. T19 makes that work explicit.
- **An upstream engine:** we reuse existing behavior and regression coverage but
  inherit schema, runtime, and upgrade coupling. Prove local policy compatibility.
- **Current upstream bundles:** provenance and state compatibility add maintenance
  work, but make later updates and rollback substantially more inspectable.

Additional clients, a gateway, marketplace publication, and unrelated domain
skills remain future candidates. Their inclusion needs a concrete local benefit.

## Completion

The proposal is implemented when the plan's delivery criteria have evidence for
both clients, the engine/closure decisions are recorded, and the selected bundles
can be deployed or rolled back without losing user state. A documented design,
passing Nix evaluation, or an OpenCode-only result does not by itself establish
that outcome.
