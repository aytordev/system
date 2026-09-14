# ADR 0015: Adopt Executable AI Workflow Contracts

Status: Proposed
Date: 2026-09-14

## Decision

Evolve `ai-tools` into one validated, client-neutral workflow contract with
native adapters for **both OpenCode and Pi**. A workflow is supported only when
its commands, model selection, delegation, permissions, and persistence work in
the consuming client. Generated prompts alone do not establish support. Preserve
the existing SDD workflow, project-specific Nix knowledge, and review practices;
repair their execution contracts before expanding the skill catalog.

This gives `system` reproducible AI configuration and verifiable workflows across
its two clients, makes home policy explicit, and turns integration failures into
diagnosable checks. Adopt selected ideas from khanelinix rather than its complete
implementation. Under
[Module Contract V1](0008-module-contract-v1.md), the shared registry remains pure
data; Home Manager capabilities own deployment and runtime integrations, while
home entry points choose policy. The [implementation plan] owns task status and
acceptance evidence; this ADR records the architectural rationale. The [proposal]
summarizes the value, delivery path, costs, and remaining decisions.

### Agreed policy

These choices incorporate the owner's clarification that both clients belong in
the delivery, rather than postponing full Pi support.

| ID | Policy | Reason and tradeoff |
| --- | --- | --- |
| C1 | Deliver the same workflow outcomes in OpenCode and Pi through native adapters. | Prevents shared files from being mistaken for working integrations; costs two client-specific validation surfaces. |
| C2 | Reusable modules select no MCP servers by default. Each home selects servers per client; wang-lin and civislend initially select Engram, filesystem, and nixos for both. | Makes enablement intentional and discoverable; requires explicit home configuration and selection tests. |
| C3 | Prefer Engram when selected and available. OpenSpec, hybrid, and no-persistence modes remain explicit choices. If Engram is unavailable, ask for a choice rather than silently creating files. | Preserves the existing memory investment and user control; requires backend-aware initialization and recovery. |
| C4 | Configure models by execution role and allow home overrides. Preserve existing SDD model defaults where roles already have them, with native client ID translation. | Makes routing effective without imposing a new provider stack; model availability and client compatibility still need runtime checks. |
| C5 | Build a minimal, locally owned Pi integration using supported APIs/SDKs and pinned dependencies. | Gives control over the adapter contract; `system` assumes maintenance, cancellation, permission, and compatibility testing. |
| C6 | Add Nix operations, bug diagnosis, impact analysis, and a lightweight workflow alongside SDD. | Fills concrete gaps without requiring SDD for every change; descriptions and routing must avoid overlapping workflow ownership. |
| C7 | Validate rendered artifacts and effective configuration, then exercise runtime behavior and a bounded evaluation corpus. | Measures usable capabilities rather than file presence; live model evaluations cost time and require repeatable evidence. |
| C8 | Keep creator and registry separate; adopt the canonical-skill/index-first contract in [ADR 0016](0016-keep-skills-canonical-and-registry-derived.md). | Preserves authored instructions instead of substituting generated summaries; costs selected full-contract reads. |
| C9 | Compare a pinned gentle-ai engine with a locally owned SDD engine before selecting either. | Avoids conflating Engram with workflow control or committing to an unmeasured maintenance burden. A minimal Pi adapter does not predetermine the engine choice. |
| C10 | Use current upstream skills as a reviewed, pinned baseline and migrate compatible dependency bundles under [ADR 0017](0017-migrate-ai-skills-as-pinned-compatible-bundles.md). | Captures newer behavior without mixing protocols or losing local adaptations; requires provenance, old-artifact compatibility, and deliberate updates. |
| C11 | Require current, relevant verification for successful SDD completion and canonical spec promotion. An administrative pause/abandon/unverified disposition stays distinct and never fabricates PASS. | Owner decision (2026-09-14). Gives "complete" one stable meaning and protects canonical specs; requires checks that address the changed contract, with explicit reasons where a dimension does not apply. |
| C12 | Adopt the pinned `gentle-ai` CLI as the SDD engine, behind a thin local adapter boundary, and reuse its validators and archive composer. | Owner decision (2026-09-14), informed by the measured prototypes. Reuses mature guarantees (validators, Git-common-dir attempt ledger, lossless archive) instead of rebuilding them; costs schema coupling, bounded by the adapter so the engine can be swapped. Engram gaps and unused surface must be handled explicitly. |

## Evidence and value

The audit compared local revision
[`3752d5c43840671467487e9805ef867c2816f5b8`][local-baseline] with khanelinix
[`8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd`][upstream]. Local Nix evaluation found
21 skills, nine commands, and one custom agent. Upstream evaluation found 48
skills and ten native OpenCode roles. These counts describe scope, not quality.

Both local homes were evaluated with fixture secrets and without updating the
lock file. Renderers were exercised with synthetic inputs. OpenCode's documented
interfaces and its Task implementation were inspected. No complete live-model
workflow or comparative quality benchmark was run; Pi's missing capabilities
were identified from its configuration and consumers, not a live Pi session.

| ID | Finding at the audited revision | Value of the proposed change |
| --- | --- | --- |
| F1 | Both homes declare Engram/filesystem/nixos, but `programs.opencode.enableMcpIntegration` evaluates to `false`. Effective OpenCode MCP contains only disabled GitHub/Socket entries. | Connect explicitly selected servers and test the effective consumer configuration. |
| F2 | The SDD prompt uses `Task(model=..., subagent_type=general-purpose)`. OpenCode Task has no model parameter, uses registered agent models or inheritance, and provides `general`. Only `sdd-orchestrator` is locally registered. | Make role/model routing executable instead of an instruction the model must reinterpret. |
| F3 | Seven command templates retain `{argument}` after rendering; OpenCode documents `$ARGUMENTS`/positional markers. | Preserve user input in the intended template position; this finding does not prove arguments are always lost. |
| F4 | A legacy string-command body containing `---` loses its trailing section. Unquoted `description: Review: focused checks` fails YAML parsing. Current commands use attrsets, so truncation is a latent compatibility defect. | Preserve content and reject malformed definitions before deployment. |
| F5 | Agents are emitted as both Markdown and structured config, with mode added separately. Several normalized fields are unused; tool mapping covers only write/edit/bash and uses deprecated OpenCode `tools`. | Give every field one declared meaning and each client one effective agent representation. |
| F6 | SDD unconditionally checks Engram initialization despite supporting other backends; automatic execution conflicts with an always-ask rule. `judgment-day` requires an unavailable `delegate` primitive. | Make backend, pause, and delegation behavior explicit and consistent. |
| F7 | The inventory check compares a union of names across resource kinds, allowing a command to mask a missing same-named skill. Relevant OpenCode tests inspect source substrings rather than execution contracts. | Detect missing resources, unresolved dependencies, and broken generated outputs. |
| F8 | Pi consumes the complete skills tree directly; some shared instructions hardcode OpenCode paths. Its optional routing file requires an extension not connected by the current module. | Complete native Pi support with discovery, model routing, delegation, and MCP tests. |
| F9 | The Nix closure guide treats build inputs as necessarily retained runtime dependencies, contrary to Nix's reference-based closure model. The README also mentions a nonexistent `skills.nix` and omits Pi. | Correct reusable knowledge and distinguish current behavior from proposed capability. |
| F10 | The loader merges definitions with `//` without duplicate rejection. Some shell permission patterns classify mutating Git operations as read-only. | Reject ambiguous identities and verify permission outcomes instead of trusting labels. |

Local evidence is in [renderers], [SDD definitions], [inventory check],
[OpenCode consumer], [MCP declarations], [Pi consumer], [OpenCode tests],
[file loader], and [closure guide]. Client contracts are documented in
[OpenCode commands], [OpenCode agents], [OpenCode Task], and [Nix closures].

### Extension: compare the source SDD workflow

The local SDD skills are strongly inspired by Alan Buscaglia's gentle-ai. The
additional audit fixes its source at
[`be49554794917ae92a6dc9dbfa2eb3db5cf70084`][gentle-skills], rather than assuming
that the current upstream remains a collection of portable prompts.

| ID | Local gap and upstream evolution | Value and limit of adoption |
| --- | --- | --- |
| F11 | Local apply's completion rule returns updated Engram tasks in the envelope; upstream explicitly updates and rereads the persisted tasks artifact. | Prevent divergence between progress prose and authoritative completion. The existing local `mem_update` convention is useful but is not consistently required by apply. |
| F12 | The local orchestrator consumes a Review Workload Forecast that `sdd-tasks` does not specify producing. Task guidance separates tests into a late phase; upstream work units carry focused checks, applicable runtime scenarios, and rollback boundaries. | Connect producer and consumer and keep evidence with each work unit, rather than adding another review skill. |
| F13 | The shared envelope specifies `success/partial/blocked` and an artifact list, while local apply/verify examples use different statuses and shapes. Upstream validates terminal outputs and distinguishes asynchronous acknowledgements. | Validate actual handoffs; empty, malformed, interrupted, and nonterminal results must not advance a phase. |
| F14 | Local phases reconstruct artifact paths/store state independently, and persistence rules broadly prohibit project edits in Engram/none, conflicting with implementation work. Upstream uses structured status and resolved artifact locators. | Separate artifact persistence from authorized code edits and supply explicit change identity/readiness. Avoid silent cross-store fallback. |
| F15 | Local archive merges specs through prose and checks move existence, without a deterministic composition/readback contract. Upstream composes deltas in code and ties closure to current verification evidence. | Preserve unrelated requirements and detect stale verification, invalid deltas, and destination collisions. Primarily relevant to OpenSpec/hybrid filesystem operations. |
| F16 | Local testing discovery resolves a single runner and auto-enables Strict TDD on detection. Upstream inventories multiple project roots and the scope covered by a workspace command. | Separate requested TDD policy from executable capability; do not silently downgrade an explicit request or pretend one package's tests cover the workspace. |
| F17 | Local artifact types have no dedicated research/evidence handoff. Upstream separates optional source-backed research from confirmed product decisions and has real-client tests with a scripted provider. | Add evidence provenance and deterministic transport tests; neither a source citation nor scripted reasoning proves real-model quality. |
| F18 | Local Engram is pinned to 1.7.0, while current upstream guidance uses newer optional tool fields and project behavior. | Prove CLI/MCP compatibility against the deployed version before importing instructions or requiring an upgrade. |

Local sources: [apply completion], [task definition], [task organization],
[return envelope], [verify return], [artifact retrieval], [persistence rules],
[spec composition], [test discovery], [spec format], and [Engram package].
Upstream sources: [gentle apply], [gentle tasks], [gentle phase contract],
[gentle status], [gentle research], and [gentle runtime tests].

The existing local verification already requires real test/build execution, a
compliance matrix, and assertion-quality checks. The missing improvement is
consistent, current, machine-checkable evidence, not adding those concepts again.
The upstream compositor's eight top-level tests (including six refusal subcases)
passed when its implementation and test file were run in isolation. This validates
that isolated component, not the full engine or a live SDD cycle.

### Decision: what does closing SDD mean?

Owner decision (2026-09-14): **require current, relevant verification for successful
SDD completion and canonical spec promotion (C11).** An administrative
pause/abandon/unverified disposition stays distinct and never fabricates PASS. The
analysis below records why, and softens the earlier proposal text: the owner has
now selected the stricter successful-close path, not merely received it as a
recommendation.

| Policy | Advantages | Disadvantages |
| --- | --- | --- |
| Require current verification for successful completion/archive | Gives `complete` a stable meaning, catches stale PASS reports, and prevents unfinished or failed work entering canonical specs. | Can block closure when relevant tooling is unavailable; requires explicit handling for documentation, manual checks, and changes without a build/runtime boundary. |
| Permit explicit closure without verification | Supports experiments, abandoned work, and operator-directed administrative closure with less friction. | Requires durable, distinct `unverified` status and checks in every consumer; an archive can otherwise look indistinguishable from a verified delivery. Canonical spec promotion needs a separate rule. |

**Recommendation:** require relevant, current verification for *successful SDD
completion and canonical spec promotion*. Provide a distinct administrative
pause/abandon/unverified disposition if the owner wants that capability; it must
not fabricate PASS or imply verified delivery. This retains the practical benefit
of an escape path without giving two meanings to successful completion. It does
not require running every possible suite for every change: checks must address
the changed contract, and inapplicable dimensions need explicit reasons.

gentle-ai chose the stricter successful-close path. Its [status contract][gentle status]
requires complete tasks and a strict, current independent verification result
before archive; a passing correction requires fresh verification. Its
[archive skill][gentle archive] blocks unresolved CRITICAL findings, requires
persisted task completion, and describes intentional partial-artifact handling.
An optional adversarial review offer is separate from mandatory SDD verification;
review presence does not control archive readiness.

The documented rationale is to preserve a truthful terminal record and prevent
prose or intermediate snapshots from acting as proof. Its [regression tests]
explicitly cover a failed attempt, remediation, fresh report, and restored archive
readiness. That is the evidenced reason for the design, not a claim about the
author's private intent. Locally the graph says verification is optional while
archive rules already reject CRITICAL reports and recommend PASS: the present
policy is mixed rather than a consistently implemented optional-close alternative.

### Decision: adopt the pinned engine behind an adapter

Owner decision (2026-09-14, C12): adopt the pinned `gentle-ai` CLI as the engine
and reuse its validators and archive composer, behind a thin local adapter so the
choice stays reversible. Both prototypes were built and measured; the local slice
(305 LOC, ~2.8% of upstream `internal/sddstatus`) reproduced status and readback
but lacked the validator/envelope, the attempt ledger, concurrency/idempotency,
migration, and archive composition. The bounded-own-engine path was rejected
because its cost is not the lines but the loss of idempotency under agent retries
and of evidence-freshness guarantees, which are the point of this proposal.

Conditions: keep clients behind an adapter that does not expose the CLI's schemas;
wire `ENGRAM_DATA_DIR` to the spawned `engram export` and prove real-writer
project-name agreement; ignore consent/review/telemetry surface; reuse the
composer and validators rather than reimplementing them. The local slice remains a
documented fallback if the Engram integration proves unreliable or the CLI schemas
block a policy requirement.

Engram is a memory/artifact backend: it stores and retrieves observations. It does
not decide whether SDD tasks are complete or whether verification permits archive.
The `gentle-ai` CLI implements that workflow logic and uses filesystem or Engram
artifacts; its runtime-attempt authority additionally uses an immutable chain in
Git's common directory, separate from Engram observations.

| Layer | Responsibility |
| --- | --- |
| Pi/OpenCode adapter | Commands, model/worker dispatch, native tool calls, cancellation, and results. |
| Workflow engine | Change identity, phase readiness, artifact locations, task/result validation, evidence freshness, and closure transitions. |
| Persistence adapters | Engram observations, OpenSpec files, hybrid coordination, or in-session state for `none`. |
| Optional execution journal | Attempts, idempotency, concurrent ownership, interruption/recovery, and provenance of execution evidence. |

| Engine candidate | Benefits | Costs and feasibility questions |
| --- | --- | --- |
| Pinned `gentle-ai` CLI | Reuses implemented status, validators, composition, and extensive regression cases. | Adds its schemas, journal, invocation/consent rules, packaging and upgrade coupling. Verify all four local persistence modes, old artifacts, both clients, both platforms, and Engram 1.7.0 compatibility. |
| Local bounded engine using Engram/OpenSpec adapters | Fits `aytordev` policy and can expose one small interface to both clients. | We own state transitions, schema/version migration, atomicity, concurrency, cancellation, evidence freshness, archive correctness, and long-term tests. Reusing Engram removes database work, not workflow-engine work. |
| Keep prompt coordination plus isolated helpers | Lowest initial migration cost and a useful prototype baseline. | Cannot promise the same guarantees while readiness and successful completion remain unconstrained model judgments. Any accepted gaps must be explicit. |

The comparison/prototype was completed before committing to the engine; the local
slice anchors the effort estimate rather than assuming a JSON file and a few
prompts. Cloning upstream's complete journal/review machinery is not required, but
neither is rebuilding it: the selected approach reuses it behind the adapter. Keep
Nix evaluation pure and runtime state outside the Nix store. The Pi adapter remains
locally owned.

Do not copy current gentle-ai assets verbatim: apply/verify contain model-tier
sections, client invocation metadata, and calls to native validators. Its strict
scenario counter expects `#### Scenario:` while a local template uses bold
`**Scenario:**`; migration must reconcile the grammar. Some upstream prose still
retains older store-specific steps alongside store-blind retrieval, and its registry
still mandates `.atl/` writes. Source-backed adoption includes checking those gaps.

## Alternatives considered

| Alternative | Advantage | Why it is not the selected approach |
| --- | --- | --- |
| Patch prompts only | Small immediate diff. | Leaves routing, MCP, and client capability mismatches unverifiable. |
| Repair OpenCode and share files with Pi | Lower initial adapter cost. | Does not meet the owner's requirement for complete support in both clients. |
| Import khanelinix wholesale | Broad ready-made catalog, policies, hooks, and tooling. | Adds clients, gateways, domain skills, and operational preferences without demonstrated local value. |
| Adopt a complete third-party Pi workflow extension | Potentially less local runtime code. | The owner chose a minimal local integration; reuse protocol SDKs rather than transferring workflow ownership to another framework. |
| Replace SDD and Engram | Could unify around upstream's workflow and memory tools. | Discards useful local specialization before repairing or measuring it. |

## Consequences

- Keep local strengths: SDD artifacts and phase boundaries, `dotfiles-coder`,
  reviewable work units, and independent review. Add a lightweight path with a
  clear boundary rather than making SDD mandatory.
- Reuse upstream's [validated model routing], [agent rendering], [Nix operations],
  [diagnosis], [impact analysis], and [evaluation corpus] selectively. Record
  source revision, attribution/license, local adaptations, and required skill
  dependencies for imported content.
- Prefer on-demand references to loading whole guides. New skills must justify
  their invocation conditions and avoid duplicating existing project standards.
- Maintain a small Pi adapter, not a replacement Pi runtime or an implementation
  of MCP from scratch. Required APIs and pinned versions must first be proven in
  a bounded compatibility exercise; a blocker keeps the dual-client delivery open.
- Separate durable knowledge from transient task progress even when both use
  Engram. In no-persistence mode, do not promise cross-session recovery.
- Treat permissions as executable rules. Upstream's OpenCode reviewer renders
  `edit: deny` with `bash: allow`; its read-only description is not a sandbox.
  Do not transplant that policy or assume OpenCode and Pi enforce rules equally.
- Add deterministic regression checks with each behavior change. Live-client
  smoke checks and model evaluations supplement them; static green checks alone
  do not establish workflow quality or full support.
- Defer additional clients, a provider gateway, marketplace publication, a
  wholesale memory migration, and unrelated domain skills until a concrete need
  justifies their maintenance. Preserve local commit and activation authority.

[implementation plan]: ../../modules/common/ai-tools/implementation-plan.md
[proposal]: ../../modules/common/ai-tools/proposal.md
[local-baseline]: https://github.com/aytordev/system/tree/3752d5c43840671467487e9805ef867c2816f5b8/modules/common/ai-tools
[upstream]: https://github.com/khaneliman/khanelinix/tree/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools
[renderers]: ../../modules/common/ai-tools/commands.nix
[SDD definitions]: ../../modules/common/ai-tools/agents/sdd/sdd-orchestrator.md
[inventory check]: ../../checks/ai-tools-inventory/default.nix
[OpenCode consumer]: ../../modules/home/programs/terminal/tools/opencode/default.nix
[MCP declarations]: ../../modules/home/programs/terminal/tools/mcp/default.nix
[Pi consumer]: ../../modules/home/programs/terminal/tools/pi/default.nix
[OpenCode tests]: ../../tests/apps/opencode.nix
[file loader]: ../../libraries/file/default.nix
[closure guide]: ../../modules/common/ai-tools/skills/nix/rules/performance-closure.md
[OpenCode commands]: https://opencode.ai/docs/commands/#arguments
[OpenCode agents]: https://opencode.ai/docs/agents/
[OpenCode Task]: https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/tool/task.ts
[Nix closures]: https://nix.dev/manual/nix/2.35/glossary#gloss-closure
[validated model routing]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/model-routing.nix
[agent rendering]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/agents.nix
[Nix operations]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/skills/nix-toolkit/SKILL.md
[diagnosis]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/skills/diagnosing-bugs/SKILL.md
[impact analysis]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/skills/blast-radius/SKILL.md
[evaluation corpus]: https://github.com/khaneliman/khanelinix/blob/8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd/modules/common/ai-tools/eval/workflow-routing-baseline.json
[gentle-skills]: https://github.com/Gentleman-Programming/gentle-ai/tree/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills
[apply completion]: ../../modules/common/ai-tools/skills/sdd-apply/rules/execution-mark-complete.md
[task definition]: ../../modules/common/ai-tools/skills/sdd-tasks/SKILL.md
[task organization]: ../../modules/common/ai-tools/skills/sdd-tasks/references/task-quality-criteria.md
[return envelope]: ../../modules/common/ai-tools/skills/_shared/return-envelope.md
[verify return]: ../../modules/common/ai-tools/skills/sdd-verify/rules/execution-return-report.md
[artifact retrieval]: ../../modules/common/ai-tools/skills/_shared/sdd-phase-common.md
[persistence rules]: ../../modules/common/ai-tools/skills/_shared/persistence-contract.md
[spec composition]: ../../modules/common/ai-tools/skills/sdd-archive/rules/execution-sync-specs.md
[test discovery]: ../../modules/common/ai-tools/skills/sdd-init/rules/execution-detect-testing.md
[spec format]: ../../modules/common/ai-tools/skills/sdd-spec/references/delta-spec-format.md
[Engram package]: ../../packages/engram/package.nix
[gentle apply]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/sdd-apply/SKILL.md
[gentle tasks]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/sdd-tasks/SKILL.md
[gentle phase contract]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/_shared/sdd-phase-common.md
[gentle status]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/_shared/sdd-status-contract.md
[gentle research]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/sdd-research/SKILL.md
[gentle runtime tests]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/docs/testing-agents-deterministically.md
[gentle archive]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/sdd-archive/SKILL.md
[regression tests]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/sddstatus/verify_archive_regression_test.go
