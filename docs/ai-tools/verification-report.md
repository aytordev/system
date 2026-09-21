# Delivery Verification Report (T16)

> **Historical / superseded:** this records the retired local dual-client workflow.
> Current ownership and onboarding: [native adoption guide](../../modules/common/ai-tools/README.md).
> Past verification and procedures below do not validate or operate the current native Shell.

Final exercise and evaluation of the dual-client AI workflow delivery promised by
[ADR 0015](../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md)
and the [implementation plan](implementation-plan.md). This file records what was
**actually run**, what each delivery criterion has evidence for, and every gap that
stays open. It does not claim a criterion the evidence does not support.

- Date: 2026-09-14
- Repository revision: `9ec0ec2749bb3c2ab928ee1a5fde4d85350c7e47` (`9ec0ec2`)
- Platform: `aarch64-darwin` (macOS 26.6.2), Nix 2.35.2, `sandbox = relaxed`
- Engine: `gentle-ai` v2.9.0 (`be49554794917ae92a6dc9dbfa2eb3db5cf70084`) behind `aytordev-sdd`
- Clients: OpenCode `1.18.30`, Pi `0.85.1`
- Persistence: Engram 1.7.0 (accepted), OpenSpec/hybrid/none
- Scope: deterministic verification + scripted-provider evaluation. No real
  activation/switch, no paid API call, no live-model run.

## 1. What was exercised

| Layer | Method | Evidence |
| --- | --- | --- |
| Pure contracts and architecture policy | pure-Nix checks (throw/`touch` only) | `nix build` of the focused suite (exit 0) |
| Rendered artifacts and effective config | runtime `runCommand` checks using `yq`/`jq`/`grep` over generated output | `ai-tools-renderers`, `ai-tools-mcp`, `ai-tools-pi-workflow`, `ai-tools-permissions` |
| Real adapter/engine fixtures | real `aytordev-sdd` + `gentle-ai` on disposable Engram/OpenSpec workspaces | `gentle-ai-engine`, `ai-tools-archive`, `ai-tools-legacy-compat` |
| Real client command/delegation/model transport | scripted loopback OpenAI-compatible fixture + real `pi`/`opencode` binaries | `eval/scripted-provider/` (this report, §4) |
| Live model quality/selection | not available here | not run (§5) |

## 2. Deterministic suite

### 2.1 Focused suite (plan T26 verification command)

Exact command (25 installables: 21 `ai-tools-*`, `gentle-ai-engine`,
`module-contract`, `docs-generation`, `unit-nix-unit`):

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

Result: **exit 0**. All 25 installables built; no error in the build log. This
covers every `ai-tools-*` check (21), `gentle-ai-engine`, `module-contract`,
`docs-generation` (which also builds `packages.docs-html` on darwin) and the
`nix-unit` suite. Re-run against the final tree (after the README/plan edits
below): **exit 0**.

### 2.2 Repository-wide `nix flake check`

- `nix build` of the full check set (`nix flake check` without `--no-build`) was
  **not run**: it builds every package (`package-builds`), both `production-home-*`
  and `production-darwin-*` outputs, and the mdbook, i.e. unbounded for this
  exercise. The focused suite above is the plan's own verification command and
  covers the full AI-workflow surface.
- `nix flake check --override-input secrets path:./checks/fixtures/secrets --no-build`
  (evaluation-only over the whole flake) was started; result recorded in §9.

### 2.3 Formatting

`nix fmt` and `git diff --check` are run after the documentation edits; result in
§9.

## 3. Dual-client runtime matrix

The delivery criteria are the eleven rows of the plan's
[Delivery criteria](implementation-plan.md#L1094) table. `Evidence` names the
deterministic check(s) (or the scripted-provider scenario, §4). `Residual gap`
lists what is **not** proven, even where a check passes. Where the Pi column says
"same shared", the check exercises the shared engine/adapter/skills that both
clients consume rather than a Pi-only runtime path.

| # | Delivery criterion | OpenCode evidence | Pi evidence | Residual gap |
| - | --- | --- | --- | --- |
| C1 | Commands preserve user intent | `integration-ai-tools-renderers` (runtime: valid YAML, `$ARGUMENTS`, legacy `{argument}` gone, Markdown `---` preserved, quotes/Unicode, unsupported fields surfaced); `integration-ai-tools-contract` (registry key parity); scripted-provider `opencode-direct` (prompt reached fixture) | `integration-ai-tools-pi-workflow` (30-assertion dispatch proof: phase command → injected envelope); scripted-provider `pi-workflow-delegation` (`# SDD phase: sdd-design` reached fixture) | Live-model invocation of a real command; Pi extension-command argument expansion is adapter-level only |
| C2 | Roles control execution | `integration-ai-tools-roles` (pure: design=opus, archive=haiku, standard/orchestrator=sonnet, override isolation, unknown role/model rejected, effective OpenCode agent models); `integration-ai-tools-permissions` (runtime probe applies OpenCode's real `findLast` matching; `sdd-review` denies edit+bash) | `integration-ai-tools-pi-workflow` (session-level `pi.setModel` binding from role policy; unknown model rejected); scripted-provider `pi-workflow-delegation` (child resolved `scripted/scripted-role`) | **Pi cannot enforce** role permissions (third-party gate not provisioned by Nix — blocker 1); live model selection not run |
| C3 | Home selection controls MCP | `integration-ai-tools-mcp` (runtime: empty/subset/all exact, disabled client/capability emit nothing, unknown name rejected, Engram `ENGRAM_DATA_DIR` and args preserved); both homes evaluate to `["engram","filesystem","nixos"]` (plan T08) | `integration-ai-tools-pi-mcp-bridge` (runtime fake-stdio-server: discovery, schema, call/result, `isError`, reconnect, cancellation, cleanup; selection non-leakage); `integration-ai-tools-mcp` (Pi selection never leaks into OpenCode) | Real smoke of the three selected servers is a runtime follow-up; Pi MCP permission boundary not enforceable |
| C4 | Memory supports the selected mode | `integration-gentle-ai-engine` (runtime: isolated `ENGRAM_DATA_DIR` resolves the change; no `~/.engram` fallback; `ENGRAM_PROJECT` override); `unit-ai-tools-sdd-persistence` (four backends, no silent cross-store fallback, hybrid retry, `none` writes nothing); `unit-ai-tools-sdd-research` (backend-aware writes; `none` inline) | Same shared adapter/engine/skills; Pi consumes the same `aytordev-sdd` and persistence protocol | Engram save/recall was proved through the `engram` CLI on an isolated dir, **not** driven by a live model; hybrid failure/retry exercised structurally, not end-to-end |
| C5 | SDD can complete and resume | `integration-ai-tools-archive` (runtime: C11 gate blocks incomplete/unverified/stale; positive change promotes); `unit-ai-tools-sdd-handoffs` (typed `sdd-result/v1`, stale/incomplete rejection); `integration-ai-tools-legacy-compat` (legacy read/convert + C11 refuses old PASS); `gentle-ai-engine` (change resolution) | `integration-ai-tools-pi-workflow` (dispatch, parsed envelope, honest failure, cancellation with no orphan); scripted-provider `pi-workflow-delegation` (adapter → real child → model → parsed result) | No live minimal end-to-end change; concurrent-change and partial-hybrid are modeled in pure checks, not run as a full runtime scenario; OpenCode TUI cancellation documented (OC-E5) but not exercised |
| C6 | Independent review is real | `integration-ai-tools-permissions` (two judges receive a byte-identical target envelope with pinned revision, distinct native sessions, both settle; correction lane is separate) | `integration-ai-tools-pi-workflow` proof §6 (parallel blind judges, identical target, distinct session ids, one failing judge does not suppress the other) | Pi judges are **advisory** (write enforcement unverified); no live judge run; correction lane not run |
| C7 | Added skills improve task fit | `integration-ai-tools-method-routing` (bug-diagnosis/impact-analysis entry + return-to-caller; discriminating impact fixture matches the real consumer only); `integration-ai-tools-workflow-routing` (question/diagnosis/small-change/architecture/substantial/explicit-SDD single-owner corpus); `integration-ai-tools-testing-scope` (mixed Nix/TS roots; strict TDD blocked vs disabled) | Same shared skills consumed by Pi; routing/scope corpora are client-neutral | "Improve" is asserted by routing/contract correctness, **not measured** on live tasks; no productivity/token comparison (§6) |
| C8 | Deployment is reversible | Rollback documented at the home boundary and in `legacy-compatibility.md` (code vs data rollback); `integration-ai-tools-legacy-compat` (originals byte-identical, partial failure recoverable, no destructive re-init) | Same shared migration/adapter; both homes deploy the same bundles | No real `home-manager switch`/generation rollback was performed (no activation authority); reversibility is documented + migration-safe on fixtures, not exercised live |
| C9 | Skills remain canonical | `integration-ai-tools-skill-contract` (all skills: frontmatter + `metadata.json` projection); `unit-ai-tools-loading` (no compact-rule authority, no hardcoded `~/.config/opencode`, new index fields); `unit-ai-tools-inventory` (per-kind doc parity, masking regression guarded); `unit-ai-tools-dependencies` (closure for both clients); `integration-ai-tools-docs-links` | Pi discovers the same `skills/` tree (PI-E9); `unit-ai-tools-dependencies` models Pi's selected set as the whole tree | Runtime discovery/freshness caching with a live client is specified in-protocol but **not implemented** (no local indexer); no live discovery run |
| C10 | SDD state and closure are explicit | `unit-ai-tools-sdd-persistence` + `unit-ai-tools-sdd-handoffs` + `integration-ai-tools-archive`; decisions C11/C12 recorded in ADR 0015; `gentle-ai-engine` | Same shared adapter/handoff protocol; `integration-ai-tools-pi-workflow` emits/parses the same envelopes | Engram/hybrid closure is exercised only structurally; live terminal results not run; `paused`/`abandoned` are modeled operator dispositions, not engine-produced |
| C11 | Upstream migration is maintainable | `upstream-sources.md` + `bundle-verification.md`; `integration-ai-tools-bundles` (five bundles, deferred methods absent, legacy fixtures distinct, pin named) | Same shared bundles/skills; `integration-ai-tools-dependencies` covers Pi closure | Future update procedure documented, **not exercised** (no second upstream update performed) |

### 3.1 Coverage counts

Every criterion has at least one deterministic check for **both** clients
(shared engine/adapter/skills checks count for both, since both clients consume
them). Beyond shared evidence:

| Client | Criteria with client-executable evidence | Documentation-only | Explicit remaining gap |
| --- | --- | --- | --- |
| OpenCode | 10/11 (all but C8) | C8 | C4/C5/C10 live model; C6 MCP arbitrary-tool permission partial |
| Pi | 10/11 (all but C8) | C8 | C2/C3/C6 permission enforcement; C4/C5/C10 live model |

Residual gaps are concentrated in three categories and are **not** claimed as
verified: (a) live-model execution of commands/roles/persistence/closure (C4, C5,
C10 for both); (b) real activation/rollback (C8 both — documented only); (c) Pi
permission enforcement, which is the unverified third-party gate (C2, C3, C6).
Runtime Engram/hybrid/concurrency scenarios are proved with isolated fixtures or
structurally, not end-to-end through a client (C4, C5, C10).

## 4. Scripted-provider evaluation

Added under `eval/scripted-provider/` (removed with the local workflow):
`fixture-server.mjs` (loopback OpenAI-compatible SSE fixture that logs every
request), `run.mjs` (orchestrator), and a README documenting the sandbox blocker.

Exact command:

```sh
node modules/common/ai-tools/eval/scripted-provider/run.mjs \
  --out /tmp/scripted-provider.json
```

Observed result (`v1.18.30` / `0.85.1`, exit 0):

```json
{
  "schema": "ai-tools-scripted-provider/v1",
  "clients": {"pi": "0.85.1", "opencode": "1.18.30"},
  "ok": true,
  "failures": 0,
  "scenarios": [
    {"scenario": "pi-direct", "ok": true, "requests": 1, "sentPrompt": true, "returnedEnvelope": true},
    {"scenario": "pi-workflow-delegation", "ok": true, "requests": 1, "delegatedInput": true, "status": "success", "parsedEnvelope": true},
    {"scenario": "opencode-direct", "ok": true, "requests": 2, "sentPrompt": true, "returnedEnvelope": true}
  ]
}
```

What this raises above the existing fake-worker proof:

- **Pi command + delegation + transport**: the real Pi SDD workflow extension is
  deployed into a temp agent dir; the real `BoundedWorkers` spawns a **real `pi`
  child worker** that reaches the loopback provider and returns a parsed
  `aytordev.sdd-result/v1` envelope. This is the first deterministic exercise of
  the adapter's delegation against a real client process and a real model
  transport (not a fake worker).
- **OpenCode command + transport**: the real `opencode run` reaches the fixture
  through a custom `@ai-sdk/openai-compatible` provider and returns the scripted
  envelope.

### 4.1 Integration blocker (recorded, not faked)

The harness **cannot be a `nix flake check`** on this platform. The Nix build
sandbox denies binding a loopback socket:

```text
Error: listen EPERM: operation not permitted 127.0.0.1
    at Server.setupListenHandle [as _listen2] (node:net:1919:21)
  code: 'EPERM', syscall: 'listen'
```

Reproduced with a minimal `pkgs.runCommand` that only calls `server.listen(0,
"127.0.0.1")` (`sandbox = relaxed`). A loopback fixture therefore cannot start
inside a derivation here. The transporter is a developer/evaluation harness, and
the deterministic suite covers the same surfaces without sockets
(`integration-ai-tools-pi-workflow` with a fake worker, plus the
`roles`/`contract`/`renderers` checks).

## 5. Bounded live-model evaluation — NOT RUN

Not run: no model credentials and no explicit invocation authority were provided,
and a paid API call is out of scope for this exercise. Run it separately, with
authority, and capture at minimum:

| Field | What to record |
| --- | --- |
| Client/model version | `opencode --version` + provider/model id; `pi --version` + `provider/model` |
| Input | exact command/prompt, project revision, and the injected child envelope |
| Result | terminal envelope (`sdd-result/v1`), exit status, artifacts written |
| Interventions | any manual approval, retry, or correction |
| Unsupported tool calls | tool names the model attempted that the client rejected/ignored |
| Elapsed time | wall-clock per phase and total |
| Usage/cost | token usage and cost when the provider exposes it |

Suggested minimal scenario (same shape for both clients): init a throwaway
project, run one SDD phase through the client, then resume it and archive it,
recording the fields above.

## 6. Baseline comparison — NOT RUN

Not run, and no score invented. Reasons:

- The baseline named by ADR 0015 is the pre-migration local revision
  `3752d5c43840671467487e9805ef867c2816f5b8`. It predates the dual-client
  adapters, the role policy, the engine adapter, and this harness, so there is no
  comparable deterministic evaluation to run against it without re-implementing
  the baseline.
- A live-model baseline/candidate comparison requires the credentials and
  authority of §5, which were not available.
- The engine prototypes compared a local slice with the pinned CLI
  (`engine-prototype-results.md`, `engine-local-prototype-results.md`); that is an
  engine measurement, not a T16 workflow baseline.

No performance, token, or quality claim is made.

## 7. ADR / implementation deviations found

1. **T15 is implemented but its plan checkboxes are unticked.**
   `skills/lightweight-change/` and `integration-ai-tools-workflow-routing` exist
   and pass, and the skill is documented in `AGENTS.md`, but
   [T15](implementation-plan.md#L512) still shows all three bullets unchecked.
   Documentation drift, not a functional gap.
2. **T02/T01 retain unchecked sub-bullets** while their deliverables exist
   (`registry.nix`, client capability matrix, engine). The remaining open T01 item
   (native Pi model-ID translation) was superseded by the T05 session-level
   adapter; the plan still records it as open.
3. **ADRs remain `Status: Proposed`** while the implementation is delivered
   (ADR 0015/0016/0017). This is intentional per the plan ("remain Proposed
   pending architectural acceptance"), but it is a state deviation a reader
   should not miss.
4. **The plan's T16 itself is unchecked** — this report is its evidence; the plan
   T16 section was updated in the same change (see §10).
5. No contradiction was found between ADR 0015 C11/C12 and the implemented state:
   closure requires current verification (`closure-policy.md` + adapter
   `closure`), and the engine is the pinned `gentle-ai` v2.9.0 behind
   `aytordev-sdd`.

## 8. Upstream/local revision map

| Input | Revision |
| --- | --- |
| `system` (this report) | `9ec0ec2749bb3c2ab928ee1a5fde4d85350c7e47` |
| Local baseline (ADR 0015 audit) | `3752d5c43840671467487e9805ef867c2816f5b8` |
| `gentle-ai` engine + SDD skills | `v2.9.0` = `be49554794917ae92a6dc9dbfa2eb3db5cf70084` |
| khanelinix-derived methods | `8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd` |
| Engram | `1.7.0` (accepted; see `engram-integration-results.md`) |
| OpenCode | `1.18.30` |
| Pi (`pi-coding-agent`) | `0.85.1` |

Newly initialized **and** migrated changes were exercised at the adapter/engine
level (`gentle-ai-engine`, `ai-tools-archive`, `ai-tools-legacy-compat`), not by a
live client; see C5/C10.

## 9. Repository-wide checks and formatting

- `nix flake check --override-input secrets path:./checks/fixtures/secrets --no-build`
  (evaluation-only, whole flake): **`all checks passed!`** (warning: omits
  incompatible `x86_64-linux`; use `--all-systems` to evaluate it). This checks
  every flake output, including all discovered checks and both home/darwin
  configurations, without building them.
- `nix fmt`: **0 files changed** (778 traversed, 403 emitted).
- `git diff --check`: **clean** (exit 0).

Not run: the full `nix flake check` *with* builds (see §2.2).

## 10. Remaining gaps and deferred items

- **Pi permission enforcement** stays the unverified third-party gate (blocker 1):
  `sdd-review` on Pi is advisory, and MCP/subagent boundaries are policy, not a
  sandbox.
- **Live-model execution** of commands, roles, persistence, closure, and review is
  not run (§5); the scripted provider proves transport/runtime wiring, not model
  selection or reasoning quality.
- **Real activation/rollback** (`home-manager switch`) is not run (C8); rollback
  is documented and migration preservation is proved on fixtures.
- **Runtime Engram/hybrid/concurrency** scenarios are proved structurally or with
  isolated fixtures, not end-to-end through a client.
- **Runtime skill discovery/freshness** caching is specified but not implemented
  (no local indexer).
- **`integration-gentle-ai-engine`** exercises the adapter/engine, not a real
  model run.
- No throughput/latency/quality baseline exists (§6).
