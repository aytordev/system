# Deliver Reliable AI Workflows in OpenCode and Pi

Status: Proposed; implementation has not started.
Decision: [ADR 0015](../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md).
Skill contract: [ADR 0016](../../docs/decisions/0016-keep-skills-canonical-and-registry-derived.md).
Migration policy: [ADR 0017](../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md).
Value and delivery summary: [proposal](proposal.md).

Make `system` deploy workflows that actually run in both clients, with explicit
home policy, effective model routing, recoverable SDD state, and focused evidence
of correctness. The ADR preserves the audit, rationale, alternatives, and agreed
tradeoffs. This plan translates them into dependency-ordered work.

## Agreed delivery

- Full workflow support in **both OpenCode and Pi** is a release criterion.
- Reusable MCP selection defaults to empty. Both current homes explicitly select
  Engram, filesystem, and nixos for each client.
- Prefer Engram when selected and available; ask before choosing another backend
  or creating file artifacts. An existing change keeps its recorded backend.
- Models are configured by role with home overrides. Preserve existing SDD
  defaults where defined; use native client identifiers rather than prompt-only
  model instructions.
- Own a minimal Pi integration. Use supported APIs/SDKs and pinned dependencies;
  do not build a replacement agent runtime or reimplement the MCP protocol.
- Preserve SDD and add Nix operations, diagnosis, impact analysis, and a lightweight
  workflow. Evaluate those additions against representative tasks.
- Keep creator and registry: creator owns the canonical skill contract; registry
  becomes an index of original content, not a compact-rules compiler.
- Compare the gentle-ai CLI with a local SDD engine before selecting either.
  Engram remains a persistence backend, not the workflow engine itself.
- Use current gentle-ai skills as the migration baseline, frozen at a reviewed
  commit. Update compatible bundles, record local adaptations, and prove existing
  artifact compatibility before deploying the changed workflow.

The choices above are agreed; the ADRs remain Proposed pending architectural
acceptance. Both open decisions are now resolved: successful-close verification
(C11) and the engine (C12 — adopt the pinned gentle-ai CLI behind an adapter).
Accepting an ADR records direction, not implementation completion.

## Traceability and sequencing

`C*` references agreed policies and `F*` references findings in ADR 0015; `K*`
references skill-contract findings in ADR 0016. Task IDs remain stable as the
proposal expands; dependencies, not numeric order, determine execution order.
Priorities express delivery order, not vulnerability severity. Each implementation
task includes its regression evidence; verification is not deferred to the end.

| Task | Priority | Depends on | Traces to |
| --- | --- | --- | --- |
| T01: Pin and prove client interfaces | P0 | T24 | C1, C5, C10; F2, F8 |
| T02: Define the shared contract | P0 | T01, T03, T17 | C1, C4, C8; F5, F10 |
| T03: Repair OpenCode rendering | P0 | T01 | C1, C7; F3, F4, F5 |
| T04: Materialize role/model routing | P0 | T02, T03 | C4; F2 |
| T05: Implement Pi workflow/delegation adapter | P0 | T01, T02, T04, T19, T27 | C1, C5, C9; F2, F6, F8 |
| T06: Add explicit MCP selection and OpenCode projection | P0 | T02 | C2; F1 |
| T07: Implement Pi MCP bridge | P0 | T01, T02, T06 | C1, C2, C5; F1, F8 |
| T08: Migrate both homes | P1 | T03, T04, T05, T06, T07, T26 | C1, C2, C4, C10; F1, F8 |
| T09: Normalize SDD persistence and execution modes | P1 | T04, T05, T06, T07, T18, T19, T23, T27 | C3, C9, C11; F6, F14 |
| T10: Enforce permissions and native independent review | P1 | T04, T05, T07 | C1, C7; F5, F6, F10 |
| T11: Validate inventory and skill dependencies | P1 | T02, T17 | C7, C8; F7, F10; K1, K7 |
| T12: Correct knowledge and context loading | P1 | T02, T09, T17, T18 | C6, C8; F8, F9; K3 |
| T13: Add operational Nix methods | P2 | T11, T12 | C6; F9 |
| T14: Add diagnosis and impact methods | P2 | T10, T11 | C6; F7 |
| T15: Add the lightweight workflow | P2 | T09, T12, T13, T14 | C6; F6 |
| T16: Exercise and evaluate the complete delivery | P2 | T08–T28 | C1, C7, C8, C9, C10; F1–F18; K1–K7 |
| T17: Formalize the existing skill authoring contract | P0 | T01 | C8; K1, K2, K4, K7 |
| T18: Migrate registry and loading to canonical paths | P1 | T02, T17 | C1, C3, C8; K3, K4, K5, K6, K7 |
| T19: Compare and prototype SDD engine alternatives | P0 | T01, T02 | C3, C5, C9; F14, F15, F18 |
| T20: Validate phase, task, and evidence handoffs | P1 | T09, T11, T23, T27 | C7, C9; F11, F12, F13, F15 |
| T21: Implement lossless archive and chosen closure policy | P1 | T19, T20, T27 | C3, C7, C9, C11; F15 |
| T22: Add optional SDD research/evidence handoff | P2 | T09, T14, T18, T20 | C6; F17 |
| T23: Scope testing capability to projects and work units | P1 | T01, T17, T19 | C7, C9; F16 |
| T24: Freeze upstream sources and map local adaptations | P0 | Scope confirmed | C8, C9, C10; F18; K7 |
| T25: Prove legacy artifact compatibility and migration | P1 | T19, T20, T24, T28 | C3, C7, C10; F13, F14, F15; K5 |
| T26: Assemble and verify compatible migration bundles | P1 | T10, T12, T18, T20, T21, T23, T25, T27 | C1, C5, C8, C10; F2, F5, F8; K3 |
| T27: Package the adopted engine and define the adapter boundary | P0 | T19 | C9, C12; F18 |
| T28: Prove Engram integration for the adopted engine | P0 | T27 | C3, C12; F18 |

Tasks with satisfied dependencies can proceed independently. This table describes
work ordering, not permission to spawn agents, commit, switch generations, or
invoke paid model services. A Pi blocker is a delivery blocker, not grounds to
label an OpenCode-only result complete.

Wave 1 (T24, T01) is complete; see the evidence lines in those tasks. Rendering
repair (T03) now precedes contract consolidation (T02): the reproduced rendering
defects are local and must not be re-encoded into a new registry. Preserve the
existing task IDs; dependencies, not numeric order, determine execution order.
T26 verifies a deployable core bundle before T08 migrates the homes. Optional
growth tasks can follow without delaying that first coherent bundle; T16 remains
the complete-proposal verification exercise.

## Foundation and client integration

### T01: Pin and prove client interfaces

- [x] Record the pinned OpenCode/Pi versions, supported entry points, and a small
  capability matrix covering commands, model override, delegation, cancellation,
  permissions, MCP, and session recovery.
- [x] Prove the Pi extension/API paths needed for a local adapter using disposable
  fixtures. Record any SDK dependencies and their versions/licenses.
- [x] Define native model ID translation for Pi for the T04 role policy. Resolved
  by T05's session-level role mapping (`pi.setModel`); OpenCode contracts were
  validated against the shipped 1.18.30 binary and the T24 baseline is recorded.

**Why/value:** prevents a second implementation based on nonexistent APIs.
**Tradeoff:** an early compatibility exercise adds work but bounds the maintenance
promise of a custom Pi integration.
**Acceptance:** every required capability has a supported API and executable probe,
or a named blocker that keeps dependent implementation work open. No unsupported
capability is replaced by a prompt assertion.
**Surface:** OpenCode/Pi package definitions, adapters, and focused test fixtures.
**Evidence:** `client-capabilities.md` (OpenCode 1.18.30, Pi 0.85.1, 8 named
blockers). All bullets done; Pi role models resolve at session level (T05).

### T02: Define the shared contract

- [x] Specify identifiers, descriptions, content, roles, command arguments,
  dependency requirements, and permission intent as validated pure data.
- [x] Expose one registry consumed by both clients. Keep deployable paths and
  client syntax in adapters; remove reliance on OpenCode-specific skill paths.
- [x] Reject duplicate identifiers within each resource kind and unresolved
  references. Make defaults explicit; a non-SDD command must not silently select
  `sdd-orchestrator`.

**Why/value:** resolves fragmented definitions and makes consumers inspectable.
**Tradeoff:** adds a small contract to maintain; avoid a general plugin framework.
**Acceptance:** malformed definitions fail with resource names, same-kind duplicates
fail, and a skill and command may intentionally share a name without masking each
other. All consumed fields are represented or explicitly rejected.
**Surface:** `default.nix`, `agents.nix`, `commands.nix`, contained contract helpers.
Duplicate handling should be scoped here unless another caller needs a library change.
**Evidence (partial):** `modules/common/ai-tools/registry.nix` now exposes one
client-neutral, validated registry (`commands`, `agents`, declared names, reference
and key-parity checks) and `default.nix` derives the OpenCode adapter from it.
`checks/ai-tools-contract/default.nix` passes. Duplicate rejection was proved with a
temporary duplicate file: `tryEval` returned `{"success":true,"value":9}` without it
and `{"success":false}` with it. The implicit `sdd-orchestrator` command default was
removed (all 9 SDD commands already declare it); a same-name skill/command collision
is still T11's inventory concern. Remaining: Pi consuming the registry and removing
OpenCode-specific skill paths are owned by T05/T18; dependency requirements by T11.

### T03: Repair OpenCode rendering

- [x] Translate arguments to native placeholders and test empty/optional arguments,
  quoted text, spaces, and literal braces without interpreting them as shell code.
- [x] Quote YAML correctly or use the supported structured representation. Preserve
  entire command bodies, including Markdown separators.
- [x] Publish each agent through one effective representation, including mode and
  modern permissions. Resolve the legacy string-command contract explicitly;
  document migration before retiring any supported format or unused fields.

**Why/value:** fixes reproduced input/content defects and removes merge ambiguity.
**Tradeoff:** simplifying the format can require a small compatibility migration.
**Acceptance:** fixtures for `Review: focused checks`, quotes, Unicode, and body
`---` parse and round-trip; command arguments reach their intended positions.
**Surface:** shared renderers and `modules/home/programs/terminal/tools/opencode/`.
**Evidence:** `checks/ai-tools-renderers/default.nix` passes (`nix build
.#checks.aarch64-darwin.integration-ai-tools-renderers`). Canonical argument marker
is `$ARGUMENTS`; `{argument}` is kept as a normalized legacy alias. The string
parser is non-lossy. Agents now render one structured `permission`-based
representation with `mode`; `allowedTools`/`argumentHint` are surfaced through
`opencode.commandUnsupportedFields` and an eval warning instead of being dropped.
`modules/common/ai-tools/agents/sdd/sdd-orchestrator.nix` still carries a now-unused
`tools` list (dead data) for T02/T10. OpenCode settings and `settings.agent` were
re-evaluated successfully.

### T04: Materialize role/model routing

- [x] Define the smallest phase-to-role mapping justified by differing models,
  permissions, or execution responsibilities; do not create an agent per skill.
- [x] Generate registered OpenCode agents and Pi-consumable role settings from the
  same policy. Add typed `aytordev.*` home overrides.
- [x] Preserve current Sonnet defaults, Opus for design, and Haiku for archive
  where already specified. Define and document inheritance for previously
  unspecified roles; do not invent a new provider preference.

**Why/value:** makes the SDD model table control actual execution.
**Tradeoff:** model identifiers and availability need maintenance across clients.
**Acceptance:** overriding one role changes that child's effective model in both
clients, leaves other roles unchanged, and requires no prompt edit. Unavailable
models produce a named error rather than silent substitution.
**Surface:** role policy, SDD agent definitions, OpenCode/Pi option boundaries.
**Evidence:** `roles.nix` is the pure policy (`models`, explicit `defaults.model`
inheritance, four roles, ordered phase routing). `opencode.agents` is generated
from it; `aytordev.programs.terminal.tools.opencode.agentModels` overrides one role
and rejects unknown role/model ids. `checks/ai-tools-roles` proves design=opus,
archive=haiku, others=sonnet and override isolation. The evaluated home gives
`design=opus-4-7`, `archive=haiku-4-5`, `orchestrator/standard=sonnet-4-6`. The
orchestrator prompt's model table and the `Task(model=…)` template were replaced by
a role router; its dead `tools` list was removed. Pi consumes the same policy as
data in T05 (Pi has no per-agent model).

### T05: Implement Pi workflow/delegation adapter

- [x] Implement local command entry points and a bounded child-worker adapter
  using T01's supported APIs and T19's selected engine boundary. Load role
  settings from T04; do not implement a second state engine inside Pi.
- [x] Pass task scope, relevant skills, write policy, evidence requirements, and
  return envelopes into isolated child contexts; keep lifecycle ownership in the
  parent. Do not depend on an undeployed gentle-pi routing consumer.
- [x] Implement cancellation, error reporting, and native session identifiers.
  Keep active session state separate from immutable Nix-managed configuration.

**Why/value:** delivers actual Pi workflows rather than copying OpenCode prompts.
**Tradeoff:** local TypeScript/runtime code needs ongoing client compatibility tests.
**Acceptance:** a Pi command dispatches the expected worker/model, receives its
result, and cancels it without an orphan process. Failure is reported without
claiming phase success; disabled Pi emits no adapter outputs.
**Surface:** contained Pi extension/config files and runtime tests; aesthetic vendor
assets are not the owner of workflow behavior.
**Evidence:** `pi/workflow/` implements phase commands, a bounded worker pool on
`pi.exec`, role resolution at session level (`pi.setModel`), cancellation, native
session ids, and `pi.appendEntry` state; `pi/default.nix` generates the config from
`aiTools.roles` and adds `workflow.{enable,commands,roleModels,timeoutMs}`. A 30
assertion scripted proof (fake worker, no model calls) covers dispatch, resolved
role/model, envelope parsing, honest failure, and cancellation with no orphan;
`integration-ai-tools-pi-workflow` passes. The evaluated Pi home deploys
`~/.pi/agent/extensions/sdd-workflow` with 9 commands and maps design→opus,
archive→haiku, standard/orchestrator→sonnet. Real-model smoke and engine status
await the T08 home migration; Pi write enforcement stays the unverified third-party
gate.

### T06: Add explicit MCP selection and OpenCode projection

- [x] Keep server definitions shared and introduce explicit per-home, per-client
  selection with an empty reusable default.
- [x] Project selected definitions into OpenCode using Home Manager's supported
  integration or a filtered adapter. The unfiltered integration flag alone must
  not override a home's chosen subset.
- [x] Validate unknown server names and preserve command/argument/environment
  semantics, including runtime credential references.

**Why/value:** repairs the confirmed MCP disconnect and implements owner policy.
**Tradeoff:** selection adds configuration but avoids hidden server enablement.
**Acceptance:** empty, subset, and all-server fixtures emit exactly the selected
set. A disabled client emits nothing. Existing disabled GitHub/Socket entries
are handled explicitly and cannot expand the selected active set.
**Surface:** MCP declarations, OpenCode adapter, typed options, integration fixtures.
**Evidence:** `mcp/default.nix` is now a catalog plus empty-by-default
`selection.opencode`/`selection.pi`; unknown names fail an assertion. Only the
OpenCode selection is declared into `programs.mcp.servers` and `opencode/mcp.nix`
enables the integration (`opencode/default.nix` untouched; stale `github`/`socket`
removed). `checks/ai-tools-mcp` proves empty/subset/all, disabled-client emptiness,
Pi selection non-leakage, and arg/env preservation. Both homes evaluate to exactly
`["engram","filesystem","nixos"]`. Pi projection remains T07.

### T07: Implement Pi MCP bridge

- [x] Build the minimal local bridge over a supported MCP SDK, using the same
  selected definitions as OpenCode and pinned dependency versions.
- [x] Map tool names/schemas, calls, results, and errors into Pi's native tools.
  Define subprocess lifecycle, timeout, cancellation, and reconnect behavior.
- [x] Ensure MCP calls traverse the chosen permission path rather than bypassing
  role restrictions. Preserve Engram's configured data directory.

**Why/value:** makes Engram and the selected tools available inside Pi workflows.
**Tradeoff:** process management and SDK upgrades become local responsibilities.
**Acceptance:** a fake stdio MCP server proves discovery, call/result conversion,
failure, cancellation, and cleanup. Unselected servers never start. Smoke-check
the three actual selected servers when T08 connects the homes.
**Surface:** Pi-owned bridge, MCP projection, SDK packaging, fake-server tests.
**Evidence:** `modules/home/programs/terminal/tools/pi/mcp-bridge/` implements the
bridge; `@modelcontextprotocol/sdk` is pinned to 1.29.0 via `buildNpmPackage`. The
modules are generated from `selection.pi` and deployed only when Pi+MCP are enabled
and the selection is non-empty (unselected/disabled emits nothing). A 19-assertion
fake-server proof covers discovery, schema preservation, conversions, `isError`,
reconnect, cancellation, and cleanup; an RPC end-to-end run reported the four fake
tools and clean server exit. `checks/ai-tools-pi-mcp-bridge` passes; the evaluated
Pi home deploys `~/.pi/agent/extensions/mcp-bridge` with Engram's `ENGRAM_DATA_DIR`
preserved. Calls go through `pi.registerTool` (Pi's permission path). Real server
smoke-check remains T08; Pi permission enforcement is still the unverified
third-party extension.

### T08: Migrate both homes

- [x] In `homes/aarch64-darwin/aytordev@wang-lin/default.nix` and
  `homes/aarch64-darwin/avicente@civislend/default.nix`, explicitly select Engram,
  filesystem, and nixos for **both** clients.
- [x] Wire the shared workflows, native adapters, and role policy. Preserve
  home overrides and make the policy discoverable at the home boundary. Deploy
  only bundles admitted by T26, applying T25's explicit state-migration procedure
  when needed; do not replace an active legacy workflow by assumption.
- [x] Compare generated configurations with fixture secrets. Document the
  generation rollback and backend-state preservation procedure before rollout.

**Why/value:** turns reusable capability into an explicit, verified `system` setup.
**Tradeoff:** both homes gain active integrations and require startup checks.
**Acceptance:** both evaluated homes select exactly the three active servers per
client; runtime checks confirm discovery and an Engram write/read cycle in
isolated test memory. Rollback does not delete user memory or SDD artifacts.
**Surface:** both home entry points, integration checks, component README.
**Evidence:** both home entry points now set
`aytordev.programs.terminal.tools.gentle-ai.enable = true` as the home-boundary
policy (T27/C12); the reusable capability default stays `false`, and the existing
explicit MCP selection (`opencode`/`pi` = Engram, filesystem, nixos) and the role
model defaults are unchanged. Evaluated with
`--override-input secrets path:./checks/fixtures/secrets`, both
`homeConfigurations.{aytordev@wang-lin,avicente@civislend}` report
`gentle-ai.enable = true`; `programs.opencode.settings.mcp` keys
`["engram","filesystem","nixos"]`; the unchanged agent map (`sdd-orchestrator`,
`sdd-standard`, `sdd-review` = `anthropic/claude-sonnet-4-6`, `sdd-design` =
`anthropic/claude-opus-4-7`, `sdd-archive` = `anthropic/claude-haiku-4-5-20251001`);
and `home.packages` containing `gentle-ai-2.9.0` and `aytordev-sdd`. Both deploy
`~/.pi/agent/extensions/{mcp-bridge,sdd-workflow}`, and each
`sdd-workflow/config.ts` resolves `engine` to the `aytordev-sdd` adapter
(`/nix/store/…-aytordev-sdd/bin/aytordev-sdd`), so `workflow.engine` is no longer
null. No `aytordev.*` option was added or moved, so the docs golden is unchanged.

Rollback and backend-state preservation (documented at each home boundary and in
`legacy-compatibility.md`): restoring a previous Home Manager generation swaps
the engine, adapter, and skills back, but leaves runtime state untouched. Engram
memory lives outside the store (`$XDG_DATA_HOME/engram`) and SDD artifacts live
under each project's `openspec/` tree, so a generation rollback never deletes
user memory or project artifacts. Data rollback is "do not adopt the derived
output"; migrations preserve originals byte-identical, resolve an existing
change's recorded backend, and never fabricate a PASS.

Verification (exact command, exit 0):

```sh
nix build \
  .#checks.aarch64-darwin.integration-ai-tools-mcp \
  .#checks.aarch64-darwin.integration-ai-tools-pi-workflow \
  .#checks.aarch64-darwin.integration-gentle-ai-engine \
  .#checks.aarch64-darwin.integration-ai-tools-bundles \
  .#checks.aarch64-darwin.unit-nix-unit \
  .#checks.aarch64-darwin.integration-docs-generation \
  --no-link --override-input secrets path:./checks/fixtures/secrets
```

`nix fmt` (0 files changed) and `git diff --check` clean. Deferred: no real
`home-manager switch`/activation and no live-model smoke (no activation
authority here); the Engram write/read cycle is proved by
`integration-gentle-ai-engine` on an isolated data dir, and the real-server smoke
of the three selected MCP servers remains a runtime follow-up.

## Workflow reliability

### T09: Normalize SDD persistence and execution modes

- [x] For new changes, honor an explicit backend choice, otherwise prefer available
  selected Engram. Reuse an existing change's stored choice; an explicit request
  to change it requires a deliberate migration, not silent cross-store fallback.
  If no backend is usable, ask before choosing another or creating artifacts.
- [x] Make initialization, strict-TDD lookup, progress merge, and recovery use
  that backend. In `none`, remain session-local and perform no persistence writes.
- [x] Define one policy for interactive/automatic pauses and coordinator inline
  work. Preserve existing authority boundaries. Track verification state without
  selecting the close policy; T21 implements the owner's decided rule (current,
  relevant verification for successful completion). Never label an unverified
  change verified.
- [x] Define hybrid partial-write/retry behavior and separate durable knowledge
  from change progress with stable project/change identities. Pass resolved artifact
  locators/readiness to phases using the engine selected in T19. Limit artifact
  persistence restrictions to artifact writes, not authorized implementation edits.

**Why/value:** removes conflicting instructions and repeated Engram-only guards.
**Tradeoff:** four backend modes require explicit state and scenario coverage.
**Acceptance:** both clients handle each mode, missing Engram, resumed changes,
two concurrent changes, and partial hybrid writes without cross-contamination,
silent data loss, or false success. No-persistence mode promises no recovery.
**Surface:** SDD agent/commands/skills, `_shared/` protocols, adapter state tests.
**Evidence:** a canonical backend/mode table (new vs existing change, no cross-store
fallback) plus a new `_shared/execution-modes.md` for interactive/automatic and
mandatory pauses; `_shared/sdd-phase-common.md` now consumes locators/readiness;
all ten `sdd-*` skills, several rules, and the three SDD commands were aligned.
The persistence ban was narrowed to **artifact** writes, so authorized code edits
remain allowed in every backend. Engine operations route only through
`aytordev-sdd`; `none` is never sent to the engine. `unit-ai-tools-sdd-persistence`
fails on a re-injected contradictory rule (proved) and passes otherwise. T21's
closure gate is deliberately not implemented here.

### T10: Enforce permissions and native independent review

- [x] Map role permission intent to each client's actual enforcement boundary,
  including MCP and shell operations. Fix mutating Git commands classified as
  read-only; avoid assuming `edit: deny` constrains all shell writes.
- [x] Adapt `judgment-day` to supported parallel execution in each client, with
  blind judge contexts and a separate correction lane.
- [x] Define bounded failure/cancellation handling and verify both judges finish
  before synthesis. Preserve their target revision and review evidence.

**Why/value:** makes review independence and write boundaries more than prose.
**Tradeoff:** clients have different enforcement mechanisms; test observable
outcomes rather than forcing identical permission syntax or adding blanket prompts.
**Acceptance:** disposable write probes cover file, shell, and MCP routes; an
unauthorized write is blocked. Two judges receive identical targets without each
other's findings; correction occurs only in the authorized lane.
**Surface:** agent permissions, both adapters, `judgment-day`, runtime fixtures.
**Evidence:** broad `git branch*/remote*/config*` allows were replaced by per-subcommand
rules (read-only forms stay `allow`; `git branch -D`, `git remote add`, `git config
user.name x`, `git add`, `mkdir`, `chmod`, … now `ask`) after verifying the pinned
1.18.30 ruleset is `defaults ++ global ++ agent` with `findLast` and alphabetical
keys. A read-only `sdd-review` role (`edit`/`bash` denied) is added. OpenCode
enforces it at execution; **Pi cannot enforce it** (third-party gate, blocker 1) and
judges there are advisory. `judgment-day` now launches two blind judges in parallel
(OpenCode `Task`; Pi T05 adapter with `allSettled`) with revision pinning, a
separate correction lane, and bounded failure. `integration-ai-tools-permissions`
runs 20 disposable probes. Residual: MCP arbitrary tool calls lack a dedicated
reviewer deny; the shell map is a filter, not a sandbox (combined short flags can
slip a carve-out).

### T11: Validate inventory and skill dependencies

- [x] Compare inventory separately for agents, commands, and skills. Detect a
  missing skill even when a command has the same name.
- [x] Validate required metadata, local references, command/agent links, declared
  skill dependencies, and the dependency closure of each client's selected skills.
- [x] Register pure checks under the unit allow-list and consumer compositions as
  integration checks. Add provenance to selectively imported content without
  introducing a marketplace or copied payload tree.

**Why/value:** detects unsupported or incomplete installations before activation.
**Tradeoff:** dependency declarations need maintenance; do not pretend arbitrary
skill mentions in prose can be extracted as a complete dependency graph.
**Acceptance:** fixtures with missing, duplicate, invalid, and unresolved resources
fail for the correct reason; disabled clients and valid subsets pass.
**Surface:** `checks/ai-tools-inventory/`, focused checks, metadata, check loader.
**Evidence:** `ai-tools-inventory` now diffs each kind independently; a missing
skill masked by a same-named command fails (proved by temporarily removing
`sdd-onboard`). An optional `dependencies` field in `metadata.json` (12 skills) is
validated by the new `unit-ai-tools-dependencies` check (resolution, acyclicity,
client closure); unresolved-reference and cycle failures were proved. Both checks
are registered under `unitCheckNames`. Per-skill provenance was deferred to
`upstream-sources.md` rather than duplicating it without a consumer.

### T12: Correct knowledge and context loading

- [x] Correct build-time versus runtime closure claims with official sources and
  representative Nix examples. Audit high-impact semantic guidance before style.
- [x] Remove mandatory full-guide loading where a task-specific reference is
  sufficient; keep `dotfiles-coder` responsible for repository conventions.
- [x] Audit remaining SDD/skill instructions after T18's canonical-loading migration;
  do not reintroduce compact-rule authority or hardcoded client paths. Correct
  claims that filesystem session recovery requires Git; Git supplies history and
  sharing, not basic file persistence. Update docs to match implemented behavior.

**Why/value:** prevents reusable misinformation and contradictory context.
**Tradeoff:** focused references need accurate routing and link validation.
**Acceptance:** representative examples validate their claim; a closure example
distinguishes derivation dependencies from output references. Both clients can
resolve referenced skills from their configured directories, independently.
**Surface:** `skills/nix/`, `skills/dotfiles-coder/`, shared protocols, `base.md`, docs.
**Evidence:** `performance-closure.md` now uses the official reference-based
definition (a `buildInputs` entry is build-time; it enters the runtime closure only
if the output references it) with a correct example. Additional real errors were
fixed in `module-darwin.md`, `validation-errors.md`, `overlays-overrides.md`,
`flakes-follows.md`, `performance-build.md`, and in `dotfiles-coder` rules
(builder names, `hosts/`→`systems/`, invalid `cfg.package`). `README.md`/`base.md`
were corrected and `checks/ai-tools-docs-links` (new) fails on broken local links
(proved). The `needs git` cross-session-recovery claim in `persistence-contract.md`
was corrected separately. The persistence-contract Git claim and the closure
example are now consistent.

## Selective capability growth

### T13: Add operational Nix methods

- [x] Extend the existing Nix skill with build diagnosis, package/output diffing,
  closure/dependency analysis, evaluation measurement, IFD diagnosis, and
  activation/runtime verification.
- [x] Port only justified references/helpers from the pinned upstream toolkit;
  record provenance and adapt platform assumptions and command quoting.
- [x] Keep scripts optional for tasks that existing Nix commands already resolve.

**Why/value:** directly supports the repository's recurring operational work.
**Tradeoff:** helpers need Darwin/Linux compatibility and meaningful fixtures.
**Acceptance:** known package/closure changes produce accurate bounded reports;
an evaluation measurement is reproducible. Activation is distinguished from build
success and follows the existing explicit activation authority.
**Surface:** `skills/nix/` references/scripts, skill metadata, helper tests.
**Evidence:** six references (build diagnosis, package diffing, closure/dependency,
evaluation cost, IFD, activation) plus a routing table in `SKILL.md` (v1.1.0,
metadata synced). `scripts/package-diff-report.py` was run on real installables
(`hello→hello` no drift; `hello→cowsay` +65/-5 files, +16/-1 closure, multi-output)
and needs no third-party deps. Provenance corrected: the toolkit is **khanelinix**
`8f0ca0d…/modules/common/ai-tools/skills/nix-toolkit/`, not gentle-ai. Because that
upstream declares **no license** (`nix-toolkit` is unlicensed; only some other
khanelinix skills carry individual licenses). The script was **rewritten
independently** (own schema v2 and structure) and the six references were then
**re-authored as original `system` documentation** with a heading/structure audit
and the provenance note updated, removing the derivative risk.

### T14: Add diagnosis and impact methods

- [x] Add bounded bug diagnosis: exact symptom, minimized reproduction,
  falsifiable hypotheses, and evidence distinguishing the supported cause.
- [x] Add impact analysis: follow consumers and cross-component contracts beyond
  the diff, then prove the material compatibility assumption.
- [x] Make both methods usable directly and from SDD; adapt upstream dependencies
  rather than pulling in its complete lifecycle. Include primary-source evidence
  guidance where external APIs determine correctness.

**Why/value:** improves regressions and investigations that do not need full SDD.
**Tradeoff:** methods can overlap exploration/review; their entry conditions and
return-to-caller rules must be explicit.
**Acceptance:** a diagnosis-only scenario makes no persistent source change;
an impact fixture identifies a real affected consumer and a discriminating check.
Both clients return evidence and uncertainty without taking over the workflow.
**Surface:** selected skill content, provenance/dependency metadata, scenario corpus.
**Evidence:** new `bug-diagnosis` and `impact-analysis` skills with explicit
entry/exit contracts (read-only default; nested calls return to the caller) and
`_shared` dependencies. `checks/ai-tools-method-routing` asserts routing, that
non-mutating cases set `mutates_source: false`, and a real discriminating check on
the impact fixture (matches `widgetSchema` in the consumer, not in the unrelated
file). The inventory check fails if either skill is removed from `AGENTS.md`
(proved). License note: khanelinix **does** license `diagnosing-bugs`/`blast-radius`
(MIT); both were independently authored anyway to keep provenance clean.

### T15: Add the lightweight workflow

- [x] Define a bounded understand/change/verify path for routine work, composing
  T13/T14 when useful. Keep SDD for structured multi-phase requirements/design.
- [x] Define explicit routing examples for questions, diagnosis, small changes,
  architecture-only analysis, and substantial implementation.
- [x] Preserve user-requested workflows, authority, review practices, and focused
  verification. Avoid mandatory planning artifacts or delegation for simple work.

**Why/value:** reduces process overhead while keeping a verifiable completion rule.
**Tradeoff:** adds a lifecycle choice, so one owner must retain control per task.
**Acceptance:** routing scenarios select exactly one lifecycle owner; a small edit
does not create SDD artifacts, while an explicitly requested SDD task stays in SDD.
**Surface:** workflow skill, descriptions/base routing, scenario corpus.

### T16: Exercise and evaluate the complete delivery

- [x] Run the deterministic suite and a dual-client runtime matrix using disposable
  projects, fake services where appropriate, and isolated memory directories.
- [x] Add a scripted loopback model/provider fixture where each client's API permits
  it. Exercise real command/delegation/transport paths without paid API calls;
  assert received inputs/results, including malformed and asynchronous responses.
- [ ] Run a bounded live-model evaluation when credentials and invocation authority
  are available. Record client/model versions, input, result, interventions,
  unsupported tool calls, elapsed time, and usage/cost when exposed.
- [x] Compare baseline and candidate under the same conditions where runnable;
  record baseline failures and unavailable measurements instead of inventing
  scores. Repeat only ambiguous cases and explain remaining variability.
- [x] Update the README support matrix and each task's evidence; review the ADR
  for implementation deviations and resolve any change to the agreed contract.
- [x] Record the final upstream/local revision map and exercise the deployed
  candidate with both newly initialized changes and supported migrated changes.
  Report explicitly adapted/deferred upstream behavior alongside support claims.

**Why/value:** verifies user-visible value and catches prompt/runtime mismatches.
**Tradeoff:** model runs cost time and are variable; they are a release exercise,
not a mandatory paid step in every commit's CI. Scripted-provider tests establish
transport/runtime behavior, not real-model selection or reasoning quality.
**Acceptance:** every delivery criterion below has evidence for both clients.
Missing access or a failed Pi integration keeps the affected criterion open.
**Surface:** focused checks, evaluation fixtures/results, README, task evidence.

**Evidence:** [verification-report.md](verification-report.md) is the T16 record
(matrix, commands, results, gaps). The focused 25-check suite from T26 (plus
`module-contract`, `docs-generation`, `unit-nix-unit`) ran with exit 0 on
`aarch64-darwin` at `9ec0ec2`. Baseline: not runnable without credentials, recorded
as unavailable (no score invented). The scripted-provider harness
(`eval/scripted-provider/`) passed three scenarios with the real clients
(`pi-direct`, `pi-workflow-delegation` through a real child `pi`, `opencode-direct`;
OpenCode 1.18.30, Pi 0.85.1) but **cannot be a `nix flake check`**: the darwin Nix
sandbox denies `listen` with `EPERM`, so it stays a developer-run harness and the
blocker is recorded. Live-model execution is **not run** (no credentials/authority);
the exact inputs to capture are listed in the report §5. Per-criterion residual
gaps remain for live-model execution (C4/C5/C10), activation rollback (C8), and Pi
permission enforcement (C2/C3/C6); no criterion is claimed beyond its evidence.
Deviations recorded: T15 is implemented (`lightweight-change` +
`integration-ai-tools-workflow-routing`) but its plan checkboxes were unticked, and
the ADRs remain `Proposed` by design.

## Skill contracts and SDD evolution

### T17: Formalize the existing skill authoring contract

- [x] Make creator's contract describe the actual supported layout: `SKILL.md`
  entry point, optional `rules/`, `references/`, `scripts/`, `assets/`, and
  conditional `modules/`. Preserve existing useful files rather than reorganizing
  everything to match an upstream tree.
- [x] Define canonical frontmatter and how consumed `metadata.json` values are
  derived or checked. Preserve real provenance/license data. Descriptions must
  remain usable without a literal `Trigger:` substring.
- [x] Replace unavailable creator script instructions with a real supported
  workflow, or supply and test those helpers only if they earn their maintenance.
  Keep audit/update guidance here before considering a separate skill-improver.

**Why/value:** makes the contract authoritative for the 21 skills already deployed.
**Tradeoff:** stricter validation needs an explicit legacy migration rather than
declaring every existing package invalid at once.
**Acceptance:** all existing layout variants are classified; malformed metadata
and missing required resources fail meaningfully. Creator can create/update a
valid fixture without invoking nonexistent files. Exported client metadata agrees
with the selected canonical source.
**Surface:** `skills/skill-creator/`, skill metadata, focused contract checks.
**Evidence:** `checks/ai-tools-skill-contract/default.nix` passes on all 21 skills
and was proved to fail on malformed fixtures. Frontmatter is canonical for
`name`/`description`; `metadata.json` is a validated projection. The nonexistent
`init_skill.py`/`package_skill.py` step was removed and replaced by manual
authoring plus the check; `rules/anatomy-metadata.md` documents the authority.
Two metadata descriptions were realigned (`dotfiles-coder`, `skill-creator`).

### T18: Migrate registry and loading to canonical paths

- [x] Replace generated compact rules with a deterministic index of name, complete
  description, source scope, exact path, and freshness identity. Use configured
  OpenCode/Pi roots, native discovery where sufficient, and Nix symlink support.
- [x] Distinguish all-resource inventory from invocation eligibility. Resolve
  project/global shadowing deliberately, expose ambiguous duplicates, and avoid
  silently excluding user skills merely by name prefix. Preserve scoped AGENTS
  rules instead of flattening every referenced subtree into global standards.
- [x] Migrate registry, resolver, loading protocol, `skill_resolution`, orchestrator,
  judgment-day, and init together. Executors read the selected entry points and
  relevant references; stale compact-rule caches cannot satisfy the new contract.
- [x] Provide read-only listing. Refresh follows the selected persistence policy:
  session-only in `none`, no automatic project writes in Engram mode, and explicit
  file persistence otherwise. Do not silently edit `.gitignore`.

**Why/value:** preserves original skill meaning and fixes stale/incomplete discovery.
**Tradeoff:** selected full-contract reads can cost more tokens; progressive loading
and cacheable original content mitigate this without inventing another authority.
**Acceptance:** fixtures cover custom Pi roots, symlinks, full/multiline descriptions,
project precedence, same-size content changes, and refresh after adding/removing a
skill. A rule in a selected reference remains available to the executor; `none`
and read-only listing leave project files and Engram untouched.
**Surface:** `skills/skill-registry/`, `_shared/`, SDD/review consumers, both adapters.
**Evidence:** the registry is now index-first (Name/Description/Scope/Path/Freshness,
project>global precedence, content-hash freshness, surfaced duplicates) with a
read-only list and persistence-aware refresh; `skill_resolution` is
`paths-injected | fallback-registry | fallback-path | none`; `execution-generate-compact.md`
was deleted. Hardcoded `~/.config/opencode` paths are gone (verified: 0 files) and
compact-rule authority is absent from `_shared` (verified: 0 files).
`checks/ai-tools-loading` (unit) fails if either regresses and was proved to fail on
a temporary marker. Native discovery reuse and a runtime content-hash cache are
specified in-protocol, not implemented (no local indexer exists).

### T19: Compare and prototype SDD engine alternatives

- [x] Compare three candidates against the same acceptance matrix: pinned gentle-ai
  CLI, a locally owned bounded engine, and current prompt coordination plus
  isolated helpers as the baseline. Use T24's frozen source and document any
  required source reselection. Clearly distinguish engine and persistence.
- [x] Audit CLI/MCP contracts against the actual Engram 1.7.0 package, including
  discovery, export/update semantics, identity, and optional newer fields. Record
  any required upgrade and migration separately instead of assuming compatibility.
- [x] Build a disposable vertical slice for the credible engine alternatives:
  select an exact change, resolve status/artifact locators, accept a worker result,
  update and reread task completion, validate candidate evidence, and evaluate
  archive readiness. Exercise a minimal Pi/OpenCode adapter handoff for each.
- [x] Inject missing artifacts, malformed results, stale verification, cancellation,
  duplicate requests, concurrent work, and partial hybrid writes. Include selected
  Engram without OpenSpec bootstrap and true no-persistence behavior.
- [x] Produce a decision comparison with measured prototype results, dependencies,
  packaging/platform costs, migration/rollback, code ownership, and implementation
  work units. Obtain the owner's engine choice before production implementation.

**What a local engine would require:**

| Subsystem | Work to implement and maintain locally |
| --- | --- |
| Change identity and context | Stable project/change/worktree identity, explicit active-change selection, scoped paths, and versioned state. |
| Persistence adapters | Engram observation access/update, OpenSpec file access, hybrid reconciliation, and session-only `none`; no new memory database. |
| Workflow state | Required artifacts, pending tasks, phase eligibility, blockers versus informational notes, and explicit backend resolution. |
| Dispatch boundary | One shared phase protocol for both clients, worker result types, cancellation/interruption, and bounded retries. |
| Evidence | Task/spec-to-check mapping, actual command/results, candidate freshness, and separation of verification from review. |
| Completion and archive | Persisted task readback, deterministic delta composition, lossless moves, collision handling, and terminal-state records. |
| Concurrency and migration | Write ownership, idempotency, atomic publication where possible, partial-write recovery, state/schema upgrades, and rollback. |
| Distribution and tests | Nix package/SDK dependencies, Darwin/Linux coverage, client compatibility fixtures, and a long-term maintenance owner. |

Do not preselect a language, full event-sourcing system, or a replacement Engram
database. Measure what the minimal core needs. If isolated upstream components
can be reused, record their actual dependency closure, attribution, and tests.
If the chosen approach splits responsibilities, identify one owner for each state
transition so Pi and OpenCode never maintain competing readiness calculations.

**Why/value:** tests whether reuse or local ownership best fits `system`, instead of
mistaking a memory service or copied prompt set for an engine.
**Tradeoff:** costs prototype work; skips a premature production commitment whose
maintenance and compatibility burden is currently unmeasured.
**Acceptance:** evidence-backed recommendation for every agreed mode and client,
explicit unsupported cases, and a concrete local-engine implementation breakdown.
A blocked prototype is a documented limitation, not a completed parity claim.
The owner selection is recorded before dependent production work begins.
**Surface:** disposable prototypes, dependency/package assessment, ADR 0015 engine
decision, shared-runtime design, and the affected task dependencies.
**Evidence so far (incomplete):** `engine-feasibility.md`, `engine-prototype-results.md`,
`engine-local-prototype-results.md`. The pinned v2.9.0 CLI built in isolation on
aarch64-darwin and `sdd-status` returned the v2 envelope for OpenSpec and Engram.
A Python local slice (305 LOC, 0 third-party deps) matched the CLI's OpenSpec status
across 5 states and the Engram positive case, and reproduced task-completion readback;
it emits none of the CLI's `blockedReasons` and lacks the validator/envelope, the
Git-common-dir attempt ledger, concurrency/migration, and archive composition. That
is ~2.8% of upstream `internal/sddstatus` LOC, anchoring a 7k–15k production-LOC
estimate (unverified). Engram 1.7.0 has no observation update path (`import`
duplicates). `ENGRAM_DATA_DIR` is inherited by the spawned `engram export` but no
component exports it for gentle-ai. Real-writer project-name agreement is unverified.
Decision (owner, 2026-09-14): adopt the pinned CLI behind an adapter (C12); the
local slice is kept as a documented fallback. Packaging the engine and closing the
Engram integration are T27/T28.

### T20: Validate phase, task, and evidence handoffs

- [x] Implement one versioned result schema through T19's selected engine. Reject
  empty/malformed terminal output without advancing; distinguish background launch
  acknowledgements, progress, cancellation, and final phase results.
- [x] Connect `sdd-tasks` to the workload forecast actually consumed by the
  orchestrator. Each work unit names its relevant focused check, applicable runtime
  scenario or justified N/A, and rollback boundary; tests stay with that unit.
- [x] Make apply update and reread the selected store's tasks artifact before
  reporting completion. Keep cumulative apply-progress, persisted checkboxes, and
  reported evidence consistent across resumed batches.
- [x] Validate requirement/scenario counts against the supported spec grammar and
  tie verification results to the relevant candidate/artifact revisions. A source
  change invalidates affected evidence; a hash alone does not prove test relevance.

**Why/value:** closes producer/consumer gaps in progress, review budgets, and results.
**Tradeoff:** schemas and evidence references require migration and readback logic.
**Acceptance:** an oversized forecast reaches the existing delivery decision, a
missing forecast is detected, and incomplete units never become completed merely
from prose. Invalid terminal envelopes, stale PASS, and interrupted writes cannot
advance the flow. Cover both legacy scenario formats and the chosen canonical one.
**Surface:** `sdd-tasks`, `sdd-apply`, `sdd-verify`, shared envelopes, selected engine,
native adapters, and contract/runtime fixtures.
**Evidence:** the shared envelope is now a versioned schema (`sdd-result/v1`,
`kind ∈ launch-ack|progress|cancelled|final`, only `final` terminal; evidence rows
carry `check/exit/result/revision/relevant`; stale revision invalidates). `sdd-tasks`
emits the exact `## Review Workload Forecast` block the orchestrator consumes plus
per-unit `check:`/`scenario:`/`rollback:` lines; `sdd-apply` writes then re-reads and
merges cumulative progress; `sdd-verify` recounts both `#### Scenario:` and
`**Scenario:**` grammars and binds rows to a candidate revision.
`unit-ai-tools-sdd-handoffs` proves missing forecast, oversized forecast routing,
stale PASS/incomplete unit rejection, and malformed-envelope rejection (one
assertion was temporarily broken to confirm it throws). Deferred: `sdd-propose` and
`sdd-archive` envelope examples still show the legacy shape; T21 owns archive.

### T21: Implement lossless archive and chosen closure policy

- [x] Implement the owner's decided closure policy (ADR 0015, C11): current,
  relevant verification is required for successful completion and canonical spec
  promotion. Any administrative pause/abandon/unverified disposition stays
  distinct and never fabricates PASS.
- [x] Use T19's selected engine to compose deltas deterministically, preserving
  unrelated bytes. Validate supported requirement IDs/headings and rename semantics
  explicitly; refuse unknown or ambiguous operations before publishing output.
- [x] Archive mechanically with a pre-move snapshot/readback, collision handling,
  and a documented interrupted-operation recovery path. Preserve the prior report
  and artifacts when validation fails. Engram-only closure uses references and
  final evidence rather than unnecessary filesystem copies.

**Why/value:** gives the terminal record a truthful meaning and protects canonical
specs against model-regenerated or partially applied content.
**Tradeoff:** stricter successful-close gates can expose unavailable checks; native
composition needs grammar fixtures and state migration. Administrative closure,
if chosen, adds a distinct state every consumer must honor.
**Acceptance:** unrelated requirements survive, malformed deltas write nothing,
renames are correctly applied or explicitly rejected, and destination collisions
never overwrite archives. Fresh/stale/failed verification and incomplete tasks
follow the chosen policy; no outcome fabricates PASS or silently promotes specs.
**Surface:** `sdd-archive`, spec templates, selected engine/composition helpers,
backend-specific closure tests, and the ADR's resolved policy.
**Evidence:** C11 lives in `skills/_shared/closure-policy.md` (successful-closure
conditions, distinct `unverified`/`paused`/`abandoned` dispositions, promotion
gate, no-fabricated-PASS) and is enforced by the adapter's `closure` subcommand:
`aytordev-sdd closure <change> --revision <rev>` translates the engine's
`sdd-status` readiness into `aytordev-sdd.closure/v1` and exits non-zero for
`incomplete-tasks`, `unverified`, or `stale-verification`. The adapter now also
exposes `compose` (pass-through to the engine's `sdd-archive-compose`, not
reimplemented) and `archive` (mechanical move: pre-move snapshot, `diff -r`
readback, collision refusal, recovery path). `sdd-archive` and its rules were
rewritten for the gate, staged composition, lossless move, and an `sdd-result/v1`
envelope; `sdd-verify` now mandates the engine `gentle-ai.verify-result/v1` fence
as the report's first non-empty line so the gate is reachable (envelope
mid-file/missing stays blocked). `checks/ai-tools-archive` proves unrelated
requirements survive, a malformed delta writes nothing (sentinel preserved), a
rename is applied and a malformed one refused, an archive collision never
overwrites, the move is lossless, and the gate blocks incomplete/unverified/stale
changes while promoting a verified one; the marker and executable negatives were
confirmed to fail when broken. Deferred/unverified: live-model execution of the
archive skill; the Engram/hybrid closure path is specified (references + final
evidence) but exercised only structurally; `paused`/`abandoned` are
operator-directed dispositions (modeled, not engine-produced).


### T22: Add optional SDD research/evidence handoff

- [x] Define a source-backed evidence handoff when external facts materially affect
  exploration/proposal/design: questions, pinned/accessed sources, mapped claims,
  contradictions, unresolved gaps, and freshness.
- [x] Keep confirmed product choices separate from researched facts. The
  orchestrator retains decision ownership; evidence collection does not infer
  user consent or turn itself into another lifecycle owner.
- [x] Make the method optional and pass its result through the selected backend;
  `none` retains inline evidence. Integrate with T14 rather than duplicating the
  general research method or requiring a new skill for every phase.

**Why/value:** preserves the justification for API/version/architecture choices
instead of leaving it only in an exploration conversation.
**Tradeoff:** evidence collection adds latency; use it for material unknowns, not as
a compulsory research ceremony after every exploration.
**Acceptance:** a changing external API claim retains its source/version and gaps;
unsupported claims cannot masquerade as confirmed product choices. In `none`,
the same handoff works without creating files or observations.
**Surface:** SDD exploration/proposal/design contracts, optional evidence artifact,
shared source guidance, backend and routing scenarios.
**Evidence:** `skills/_shared/research-evidence.md` defines the optional handoff
(`questions`; `sources` with class/title/url + `accessed` **or** `revision`;
`claims` mapped to source IDs; `contradictions`; `unresolved gaps`; `freshness`;
and a separate `confirmed product choices` section). It never infers consent: a
source is evidence, never a choice. Engram uses topic key
`sdd/{change-name}/research-evidence` (artifact-type row added to
`engram-convention.md`), OpenSpec uses
`openspec/changes/{change-name}/research-evidence.md`, hybrid writes both, and
`none` stays inline. Concise entry points were added to `sdd-explore`,
`sdd-propose`, and `sdd-design` (SKILL.md plus one rule each); evidence gathering
defers to T14's `bug-diagnosis`/`impact-analysis` rather than a new skill.
`unit-ai-tools-sdd-research` proves (pure Nix) that a changing claim loses
validity without an `accessed`/`revision` anchor or without a retained gap, a
`supported` claim needs a real source, an `unsupported` claim is allowed as a gap
but rejected as a product choice, a choice without `decided_by` is rejected, and
`none` writes nothing while `engram`/`openspec` never cross stores (an unknown
backend throws).

### T23: Scope testing capability to projects and work units

- [x] Discover the in-scope project roots and associate each runner/check command
  with its working directory and covered targets. Distinguish Nix evaluation,
  derivation builds, and runtime checks rather than calling any runner a unit suite.
- [x] Track requested Strict TDD separately from executable capability. Honor an
  explicit disabled setting; report missing coverage for an explicit enabled
  setting rather than silently downgrading it or using another package's runner.
- [x] Resolve applicable per-unit checks and load strict modules only where the
  resolved mode requires them. Preserve focused verification outside Strict TDD.

**Why/value:** prevents monorepo or mixed-stack work from claiming coverage using
an unrelated command, while preserving user testing intent.
**Tradeoff:** discovery and cached capability records become more structured.
**Acceptance:** mixed Nix/TypeScript fixtures retain separate roots/commands; a
workspace-wide command is recognized only when its coverage is evidenced.
Explicit strict-mode requests with unavailable prerequisites report a clear
blocker; ordinary mode still requires the unit's relevant evidence.
**Surface:** `sdd-init`, apply/verify mode resolution, testing-capability metadata,
and mixed-project fixtures.
**Evidence:** detection now walks project roots by manifest and records
`{root, working_dir, surface, command, runner, covers, covers_workspace}`; surfaces
separate `nix-eval`/`nix-build`/`runtime`/`quality` (only `runtime` backs a layer or
Strict TDD). Requested vs effective Strict TDD is split: explicit `false` →
`disabled`; explicit `true` without workspace-wide runtime → `blocked` (never
downgraded); `unset` auto-enables only from evidenced coverage. Per-unit checks are
resolved by covered-target prefix and run in their working directory.
`integration-ai-tools-testing-scope` proves separate `packages/core`→vitest and
`packages/web`→jest roots, distinct Nix surfaces, and the blocked/disabled outcomes.

## Upstream migration and maintenance

### T24: Freeze upstream sources and map local adaptations

- [x] Review gentle-ai changes since the audited
  `be49554794917ae92a6dc9dbfa2eb3db5cf70084` and freeze the current candidate commit
  for the migration, including a release tag when applicable. Keep the independently
  selected khanelinix methods pinned to their own source.
- [x] Inventory inherited and approved new skills with original/local paths,
  license/attribution, resources, `_shared` dependencies, model-tier projections,
  client invocation fields, and native engine/validator requirements.
- [x] Group compatible bundles and compare upstream behavior with local adaptations.
  Record each behavior as preserved, adapted with rationale, or explicitly deferred.
  Cover inherited auxiliary workflows as well as SDD; preserve local home policy
  and authority rather than overwriting them from upstream defaults.

**Evidence:** `upstream-sources.md`. The audited pin is still the latest stable
release, so the frozen source is `v2.9.0` = `be49554794917ae92a6dc9dbfa2eb3db5cf70084`
(also `main` HEAD, verified with `git describe --tags --exact-match`). Classification
totals: 19 local skills `adapted`, 2 `preserved` (`nix`, `dotfiles-coder`), 7
upstream-only methods `deferred`.

**Why/value:** turns "use the latest skills" into a reproducible, reviewable source
baseline and gives every content migration an explicit scope.
**Tradeoff:** a source/adaptation map takes maintenance; avoid a second mirrored
upstream tree or general sync framework when the catalog and Git history suffice.
**Acceptance:** every selected item has exact provenance and a complete dependency
bundle. The chosen revision is fixed; future upstream changes do not alter the
candidate silently. Any incompatible source reselection records why and invalidates
the affected comparison/check results.
**Surface:** source/provenance records beside the AI catalog, adaptation inventory,
and engine/client compatibility inputs for T01/T19.

### T25: Prove legacy artifact compatibility and migration

- [x] Inventory representative old registry caches, task/progress envelopes, spec
  scenario formats, backend identities/locators, and verification reports. Use
  isolated or redacted fixtures, preserving source bytes and observation references.
- [x] Classify each supported input as directly readable, requiring conversion, or
  requiring a retained legacy reader/manual decision. Specify the chosen target
  schema and behavior before implementing any converter.
- [x] Implement only required conversions with a preview, preserved originals,
  interruption/retry behavior, and readback. Unknown formats must not trigger
  automatic reinitialization, memory deletion, or fabricated verification.
- [x] Document code rollback separately from data rollback, including what happens
  when an older generation reads migrated artifacts and how an active change can
  resume in either client after migration.

**Why/value:** makes updating the workflow compatible with work already in progress.
**Tradeoff:** backward compatibility and conversion cost more than replacing files;
support only inventoried formats and explain unsupported ones explicitly.
**Acceptance:** supported legacy changes retain task identity, progress, source
content, and historical evidence. They resume correctly in Pi/OpenCode or stop
with a documented compatibility reason. A migrated old PASS never becomes evidence
for new code; failed/partial conversions retain a recoverable original.
**Surface:** state/registry migration fixtures, selected engine adapters, narrowly
required conversion helpers, and rollout/rollback instructions.
**Evidence:** `legacy-compatibility.md` is the compatibility table and rollback
procedure. Five surfaces are classified: registry cache and phase envelope
**require conversion**; bold spec scenarios are **directly readable** by verify
but convertible before promotion; verification reports and backend
identity/locators **require a retained reader / manual decision**. The adapter
now exposes `aytordev-sdd migrate <registry|envelope|scenarios|verify-report>`
(`modules/home/programs/terminal/tools/gentle-ai/migrate.sh`) with preview,
preserved originals, atomic publish, and readback; skills and `_shared`
protocols reference it (`return-envelope.md`, `skill-loading.md`,
`skill-resolver.md`, `execution-persist.md`, `execution-return-report.md`,
`execution-spec-counts.md`, `execution-closure-gate.md`,
`persistence-contract.md`). `integration-ai-tools-legacy-compat` proves each
supported input is read/converted with a readback, an unknown format stops
(exit 4) with a reason and leaves the original intact, a migrated old `ok`/PASS
becomes a non-advancing `partial` envelope, a partial failure keeps a
recoverable original, and the C11 gate returns `unverified` for a legacy
`Verdict: PASS` report. Code rollback (Home Manager generation) and data
rollback (not adopting the derived file; originals are byte-identical) are
documented separately, including what an older generation reads and how an
active change resumes in either client. Deferred to T26: `sdd-propose`'s
return-summary example still shows the legacy envelope shape (T20 deferred it);
the reader means it is never silently accepted.

### T26: Assemble and verify compatible migration bundles

- [x] Adopt the selected newer content from T24, including required references,
  strict-mode resources, and shared protocols. Apply T17's authoring structure
  without preserving obsolete instructions solely to keep the old file layout.
- [x] With an upstream engine, match skill assets to its exact CLI/schema contract.
  With a local engine, translate native calls to proven local equivalents and keep
  the semantic adaptation map explicit. Resolve model-tier sections and client
  metadata rather than deploying raw source assets blindly.
- [x] Assemble each bundle's producers, consumers, commands/agents, and dependencies
  into a coherent candidate for both clients. Reject mixed legacy/new loading and
  envelope contracts. Keep new optional methods in their own verified bundles.
- [x] Run structural checks and relevant native runtime smoke scenarios on the
  candidate, including T25's supported legacy fixtures, before T08 deploys it.
  Record bundle revisions, effective client outputs, and rollback boundaries.
- [x] Document future updates as a comparison of previous upstream, new upstream,
  and local adaptations. Revalidate affected bundles before advancing the pin;
  remove obsolete local patches only with evidence and within the update's scope.

**Why/value:** completes an actual migration to current selected upstream behavior,
rather than a set of unrelated local fixes or top-level Markdown replacements.
**Tradeoff:** coordinated deployment requires candidate assembly and compatibility
checks even when implementation is split into small reviewable units.
**Acceptance:** each deployed capability has a complete, compatible bundle, exact
source/local provenance, valid resource references, and passing Pi/OpenCode checks.
No unimplemented/deferred upstream behavior is advertised as supported. Core
bundles can be admitted independently of optional growth, and the previous
generation/state recovery procedure is known before rollout.
**Surface:** selected skills/resources, shared protocols, client projections,
bundle compatibility checks, source records, and the support/update documentation.
**Evidence:** the five ADR 0017 bundles are mapped in
[bundle-verification.md](bundle-verification.md) — concrete files, source
revision(s) (`gentle-ai v2.9.0` `be4955…`, khanelinix `8f0ca0…` for methods),
effective OpenCode outputs (`programs.opencode.{skills,commands,agents,context}`
— orchestrator + generated `sdd-standard`/`sdd-design`/`sdd-archive`/`sdd-review`
roles and the nine `sdd-*` commands), effective Pi outputs (`pi.skills`, generated
phase commands), dependency closure (`_shared` + the locator/`sdd-result/v1`
contract + `aytordev-sdd`), rollback boundary (code vs data, per
`legacy-compatibility.md`), and the update procedure (three-way previous/new/local
comparison, revalidate affected bundles, then advance the pin). The deferred
upstream methods (`sdd-research`, `skill-improver`, `go-testing`,
`rdd-defect-workflow`, `systemic-issue-triage`, `hermes-ephemeral-delegation`,
`gentle-ai-bench`) are listed as unsupported.
The remaining legacy producer shapes are reconciled: `sdd-init`, `sdd-explore`,
`sdd-propose`, `sdd-spec`, `sdd-design`, and `sdd-onboard` now document the
`sdd-result/v1` field set (`schema`, `kind`, `status`, `executive_summary`,
`artifacts`, `evidence`, `next_recommended`, `risks`, `skill_resolution`) in
`SKILL.md` and `rules/constraints-rules.md`, and `sdd-propose`'s return-summary
example no longer emits `{status: "ok", artifacts: [...]}`/`detailed_report`.
New check `checks/ai-tools-bundles/` (published as
`integration-ai-tools-bundles`, the default level for an unlisted check dir; no
loader edit) asserts in pure Nix that every SDD phase documents the locator model
and `sdd-result/v1`, no producer emits the legacy envelope, archive is gated by
C11 and calls `aytordev-sdd closure`, research is optional, the registry is
index-first, no skill/agent presents compact-rule authority or hardcodes
`~/.config/opencode`, every bundle file exists, the deferred methods are absent,
the T25 legacy fixtures stay distinct from the current schema, and
`bundle-verification.md` names the pin and all five bundles. It was confirmed to
fail (exit 1, "still emits legacy envelope marker '\"status\": \"ok\"'") when a
legacy marker was injected, then reverted.
Verification (exact command, exit 0):

```sh
nix build \
  .#checks.aarch64-darwin.integration-ai-tools-bundles \
  .#checks.aarch64-darwin.unit-ai-tools-sdd-persistence \
  .#checks.aarch64-darwin.unit-ai-tools-sdd-handoffs \
  .#checks.aarch64-darwin.unit-ai-tools-sdd-research \
  .#checks.aarch64-darwin.unit-ai-tools-dependencies \
  .#checks.aarch64-darwin.unit-ai-tools-loading \
  .#checks.aarch64-darwin.unit-ai-tools-inventory \
  .#checks.aarch64-darwin.integration-ai-tools-skill-contract \
  .#checks.aarch64-darwin.integration-ai-tools-contract \
  .#checks.aarch64-darwin.integration-ai-tools-renderers \
  .#checks.aarch64-darwin.integration-ai-tools-roles \
  .#checks.aarch64-darwin.integration-ai-tools-mcp \
  .#checks.aarch64-darwin.integration-ai-tools-pi-mcp-bridge \
  .#checks.aarch64-darwin.integration-ai-tools-pi-workflow \
  .#checks.aarch64-darwin.integration-ai-tools-permissions \
  .#checks.aarch64-darwin.integration-ai-tools-testing-scope \
  .#checks.aarch64-darwin.integration-ai-tools-method-routing \
  .#checks.aarch64-darwin.integration-ai-tools-workflow-routing \
  .#checks.aarch64-darwin.integration-ai-tools-archive \
  .#checks.aarch64-darwin.integration-ai-tools-legacy-compat \
  .#checks.aarch64-darwin.integration-ai-tools-docs-links \
  .#checks.aarch64-darwin.integration-gentle-ai-engine \
  .#checks.aarch64-darwin.integration-module-contract \
  .#checks.aarch64-darwin.integration-docs-generation \
  .#checks.aarch64-darwin.unit-nix-unit \
  --no-link --override-input secrets path:./checks/fixtures/secrets
```

`nix fmt` (1 file changed) and `git diff --check` clean. Deferred/unverified:
live-model execution of the migrated phases; `integration-gentle-ai-engine`
exercises the adapter/engine, not a real model run.

### T27: Package the adopted engine and define the adapter boundary

- [x] Package the pinned `gentle-ai` v2.9.0 as `packages/gentle-ai/` (exposed as
  `pkgs.aytordev.gentle-ai`). Prefer the simplest reproducible form; the pinned
  signed archive with its verified SHA-256 is proved to work on aarch64-darwin, and
  source build is a documented alternative. Record the chosen form and the
  unresolved minisign trust-anchor question.
- [x] Define a thin adapter boundary so skills/clients never call the CLI's schemas
  directly: a small wrapper or documented command surface that owns the engine
  invocation and the environment it needs (data dir, project, cwd). Both OpenCode
  and Pi consume the adapter, not raw `gentle-ai` subcommands.
- [x] Explicitly exclude the surface we do not consume (consent, review ledger,
  telemetry, model routing). Reuse the validators and archive composer.
- [x] New check: the engine builds and reports its version, and the adapter wrapper
  runs with the expected environment on a disposable fixture.

**Why/value:** turns the C12 decision into a real, callable engine without leaking
its schemas into every skill.
**Tradeoff:** a wrapper is one more layer to maintain; the alternative (calling the
CLI everywhere) couples every skill to its version.
**Acceptance:** `pkgs.aytordev.gentle-ai` builds; the adapter is the single call
surface; no skill references a raw `gentle-ai` schema. Engine choice stays
reversible behind the adapter.
**Surface:** `packages/gentle-ai/`, adapter wrapper, skills/adapters consumers,
focused check.
**Evidence:** `packages/gentle-ai/package.nix` (pinned archive, SRI per platform,
minisign caveat recorded) builds and reports `gentle-ai 2.9.0`. The adapter is the
`aytordev.programs.terminal.tools.gentle-ai` capability installing an `aytordev-sdd`
wrapper that owns `ENGRAM_DATA_DIR`/`ENGRAM_PROJECT`/cwd and exposes
`status|continue|attempt|verify`; consent/review/telemetry/update are excluded. No
skill references a raw `gentle-ai` schema (verified: 0). `integration-gentle-ai-engine`
proves build, version, and adapter environment.

### T28: Prove Engram integration for the adopted engine

- [x] Own `ENGRAM_DATA_DIR` in the adapter so the engine's spawned `engram export`
  reads the same database as the MCP server that writes artifacts. Prove it with an
  isolated data dir (no `~/.engram` fallback).
- [x] Prove real-writer project-name agreement: write an artifact the way the SDD
  skills do (MCP `mem_save`/`mem_update`), then have the engine resolve the change
  for that project. If they disagree, fix the contract (single project name source)
  or document the required override.
- [x] Record the Engram 1.7.0 gaps (`capture_prompt`, `mem_review`, project merge,
  git-remote auto-detection) and how the contract degrades; decide upgrade vs
  accept explicitly rather than assuming.

**Why/value:** the two unverified risks (data dir, project name) are exactly what
could make the adopted engine report the wrong change or nothing at all.
**Tradeoff:** an Engram upgrade would need its own migration; accepting the gaps
means the newer optional surfaces stay unavailable.
**Acceptance:** an isolated write→read cycle through the adapter resolves the same
change, with `ENGRAM_DATA_DIR` owned by the adapter and no fallback to a default
database. The missing 1.7.0 surfaces have an explicit decision, not an assumption.
**Surface:** adapter environment, MCP write path, isolated Engram fixture, recorded
decision on the Engram version.
**Evidence:** `engram-integration-results.md` and the engine check record three
proved fixtures: isolated data dir resolves the change; a data dir with only
`$HOME/.engram` data resolves nothing (no fallback); project agreement holds when
the writer stamps the git-remote basename, and a mismatch requires the documented
`ENGRAM_PROJECT` override. Decision: accept Engram 1.7.0 (the consumed `engram
export` path is compatible; the missing surfaces are optional/non-gating or out of
consumed scope); revisit only if a required surface emerges. Live-model `mem_save`
project choice remains unverified.

## Verification and completion

New checks use the repository's [verification levels](../../checks/AGENTS.md).
Pure contracts and renderer cases are unit checks; actual Home Manager
compositions are integration checks. Exercise `aarch64-darwin` and
`x86_64-linux` through their available local/CI runners; there is no concrete
NixOS host to activate.

Use focused checks while implementing. For the completed implementation, run:

```sh
nix fmt
nix flake check --override-input secrets path:./checks/fixtures/secrets
```

The flake check command targets the current platform; obtain evidence from the
other supported runner as well. A flake evaluation or build is not a substitute
for native client smoke tests. Documentation-only edits require document/link
validation, not the future implementation's runtime suite.

| Delivery criterion | Required evidence in OpenCode and Pi |
| --- | --- |
| Commands preserve user intent | Named/optional arguments, spaces, quotes, and Markdown bodies reach the intended worker. |
| Roles control execution | Reported child model and permissions match the configured role and home override. |
| Home selection controls MCP | Both homes expose Engram/filesystem/nixos; empty/subset fixtures never start unselected servers. |
| Memory supports the selected mode | Isolated Engram save/recall, OpenSpec recovery, hybrid failure/retry, and no persistence writes in `none`. |
| SDD can complete and resume | Minimal end-to-end change plus continuation, cancellation, missing capability, and concurrent-change cases. |
| Independent review is real | Two isolated judge runs, unchanged review target, separate correction lane, and tested write boundaries. |
| Added skills improve task fit | Nix operation, diagnosis, impact, and lightweight/SDD routing scenarios with recorded results. |
| Deployment is reversible | Restore a previous generation without deleting user memory or project artifacts. |
| Skills remain canonical | Creator validates supported packages; both clients load original selected skills through a fresh, scope-aware index without authoritative generated summaries. |
| SDD state and closure are explicit | Recorded engine/closure decisions, consistent persisted task state, typed terminal results, current evidence, and lossless archive under the selected policy. |
| Upstream migration is maintainable | Frozen source/local adaptation map, coherent bundles, supported old-state continuation, and separate code/data rollback evidence. |

Record evidence with task ID, revision, platform, client/model version, exact check,
observed result, and remaining gap. Keep implementation checkboxes open until
their required evidence exists; update current-state documentation at each landing.
