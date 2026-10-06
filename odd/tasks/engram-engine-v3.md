# Engram engine v3 alignment

## Goal and authority

Target: move the Nix `packages/engram` pin from **`2.0.0-rc.11`** to **`3.1.0`**, so the pinned engine satisfies the floors the current Pi plugin `gentle-engram@0.2.0` already declares, and so the store's one doctor error becomes repairable. The plugin is current and is not changed by this feature; the engine is the mismatched half.

Authorized so far: creating this feature record, the feature branch and its worktree, the documentation commits `708a9d15` and `2e4b7e5f`, and an isolated capability probe of the published 3.1.0 binary. The EN-1 source edit was then made in the working tree and its RED observed; that edit is **uncommitted, pending explicit commit authorization**. **Not authorized yet:** the pin bump, Nix activation, cloud configuration, store repairs, further commits, branch push, or a pull request. The operator supplies the cloud server URL and any token in their own terminal, never in chat.

Worktree `../system-engram-engine-v3`, branch `feat/engram-engine-v3`, base `e537e7bf45b1873b3708163e8d582aab3bbf8c96` (`main`, merge of PR #232). Pi/Pen restart and any interactive `sudo` remain manual.

Base-state caveat recorded at open time: this branch's committed `flake.lock` carries nixpkgs `494ce7fd23ff6a5dff39e1fb11e9b6f2ac74bf25` (Pi 1.0.2), while the live generation 45 depends on an **uncommitted** `flake.lock` nixpkgs `151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4` (Pi 1.0.3). That divergence predates this feature, must not be silently adopted here, and needs its own resolution. It does not affect the engram derivation, which does not depend on the Pi version.

## Problem

`Gentleman-Programming/engram` is one repository with two independent release lines: the Go engine tagged `v*` (v2.1.0, v2.2.0, v2.2.1, v3.0.0, v3.1.0) and the Pi plugin tagged `pi-v*` (newest `pi-v0.2.0`, published to npm as `gentle-engram@0.2.0`). The plugin's `0.x` numbering is its own line; it is not a stale engine release.

The pinned engine is behind **two published floors**:

| Floor | Recorded in | Pinned engine |
| --- | --- | --- |
| >= **2.1.0** for "Pi project listing" | v2.1.0 notes | `2.0.0-rc.11` fails |
| >= **3.0.0** for `expected_project`, `resume` registration and isolated cross-project saves | `pi-v0.2.0` notes | `2.0.0-rc.11` fails |

Measured against the live profile on 2026-10-06, not inferred:

| Operation | Engine `2.0.0-rc.11` | Evidence |
| --- | --- | --- |
| `mem_save`, `mem_search`, `mem_context`, `mem_session_summary` | works | used across the session |
| `mem_update`, `mem_delete` | works | scratch observation reached `revision_count: 2`, then hard-deleted |
| `mem_stats` (383 sessions / 555 observations / 708 prompts / 10 projects) | works | live call |
| `mem_current_project`, `mem_review`, `mem_doctor` | works | live call; `available_projects` degrades to `null` |
| `mem_list_projects` | **fails, HTTP 404** | live call |
| save to another project ("satellite") | fails closed | `GET /health` carries no `capabilities` object |
| `resume` registration of ended sessions | unverified | declared v3 requirement |

`GET http://127.0.0.1:7437/health` returns `{"instance_id":"…","service":"engram","status":"ok","version":"2.0.0-rc.11"}` with no `capabilities` object at all. The plugin requires `capabilities.isolated_session_registration === true` on every satellite registration flight and fails closed with explicit upgrade guidance otherwise, writing nothing.

Identity and ownership are sound: `2.0.0-rc.11` is exactly the release where instance identity first shipped, and the plugin's `isPreIdentityEngramVersion` treats it as identity-capable rather than legacy.

Rolling the plugin back to `0.1.16` is explicitly **not** the fix. Release note and code agree that an old server "may ignore isolated and normalize omitted directory to its cwd", so `0.1.16` could write cross-project data to the wrong project silently, while `0.2.0` refuses loudly. `0.2.0` is the safer state; the engine is what moves.

## EN-0 decision: cloud sync is wanted (recorded 2026-10-06)

The operator decided **Engram cloud replication is intended**, and the nine `cloud:*` projects should be enrolled rather than abandoned.

Two consequences fixed in this record:

1. **The 9402 pending mutations must not be cleared.** If a pipeline is enrolled, they may be deliverable writes rather than garbage. Clearing them first would discard data. The earlier "clear or re-acknowledge" framing is withdrawn.
2. **The engine bump is a prerequisite for resolving the store findings, not a consequence of them.** Only `3.1.0` can repair `sync_target_closed_space`; `2.0.0-rc.11` cannot.

### Isolated capability probe (authorized, read-only for the live store)

The published `engram_3.1.0_darwin_arm64.tar.gz` was downloaded and run with `ENGRAM_DATA_DIR` pointed at an empty temporary directory, so the live store was never opened.

- Archive SHA-256 `2501e971e84f8c5875efb7fa300522169bd7d2784f30593778c6a73c12e01fc4` matched the publisher's `checksums.txt` exactly.
- The binary reports `engram 3.1.0`.
- `engram doctor repair --project probe --check sync_target_closed_space --plan` returns a structured plan with `status: "noop"` and `actions: []`. On `2.0.0-rc.11` the same command fails with `unsupported repair check sync_target_closed_space`. **The repair exists only in 3.1.0.**
- 3.1.0 advertises ten doctor checks against the pinned engine's eight. New: `ambiguous_active_runtime_sessions` and `orphaned_pending_relations`. Expect the post-upgrade doctor to surface checks this store has never been evaluated against; report them, do not assume they are regressions.

### Store baseline at decision time

`engram doctor` on the pinned engine reports 8 checks with 6 ok, 1 warning and 1 error.

Error `sync_target_closed_space`, 9 findings, **9402 unacknowledged mutations**: `cloud:system` 3199, `cloud:brain` 2521, `cloud:harness-civislend-analisis` 2491, `cloud:anonymizer` 620, `cloud:platform` 543, `cloud:documentation` 19, `cloud:secrets` 4, `cloud:downloads` 3, `cloud:avicente` 2. `engram cloud status` reports no effective server URL and every project as `not enrolled`, which is why no configured pipeline can advance them.

This item is inherited, not new: `engram-single-store` recorded it as a deliberate non-goal — "Not touching the `cloud:system` sync target with its 180 unacknowledged mutations … that is a separate decision." It has grown from 180 to 3199 for that target while deferred.

Warning `unowned_session_project`: session `manual-save` carries unclassified ownership metadata, with empty `directory` and `session_project`. Its safe next step requires confirmation and, importantly, a project name the operator must supply: `engram projects rescue-ownership --project <name> --session manual-save`.

`engram doctor` is diagnostic by default and **exits 0 while reporting `error`**, so it must be read rather than exit-checked. Repairs are separate and default to dry-run: `engram doctor repair --project <project> --check <code> (--plan|--dry-run|--apply)`.

## Execution contract

- ODD delegated direct, one sequential writer; the parent owns this file, its Engram mirror `odd/engram-engine-v3/tasks`, decisions and commits.
- TDD **on**, source **explicit user choice**. Observe RED before the pin changes, then GREEN and refactor.
- The RED only exists if a guard exists. `main` has **no Nix assertion on the engram version**, unlike `checks/gentle-ai-engine/default.nix:105` (`packageVersion = tools.gentle-ai.package.version == "4.0.0"`). EN-1 therefore adds the missing assertion as the failing test, mirroring the gentle-ai pattern and its `AI ownership failures: packageVersion` shape.
- Exact runner: `nix build path:.#checks.aarch64-darwin.integration-gentle-ai-engine --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`, plus the engram check introduced by EN-1.
- Full evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`.
- Format: `just fmt-check`.
- Source surfaces: `packages/engram/package.nix`, a new `checks/engram-engine/default.nix` (candidate location, confirm in EN-1), and `docs/ai-tools/` only if a documented contract changes.
- Fixture secrets apply to checks only. Production build and switch use real host inputs. Never print credentials and never activate fixtures.
- Interactive `sudo` is required for activation. The operator runs `just darwin-switch civislend` in their own terminal and enters any password there, never in chat. No askpass, no privilege bypass.
- The cloud server URL and any token are entered by the operator in their own terminal. No credential value is ever pasted into this session, written to this file, or committed.
- RDD enabled; provider-owned bindings and consent; exact work-unit commits only, with a Conventional Commit message per task. Checkboxes never grant review or delivery.
- Commit the store backup path and observed doctor output as evidence; never commit credential bodies.

## Ownership decision (no plugin change, no second store)

The engine stays Nix-owned through `packages/engram/package.nix`, matching the rule that Nix-owned executables are updated through their Nix pins and that native self-update paths must not touch them. The plugin stays native-owned through the versioned npm spec. This feature adds no second writer over `~/.pi/agent/settings.json`.

`modules/home/programs/terminal/tools/engram/default.nix` wraps the binary with `makeWrapper` and pins `ENGRAM_DATA_DIR` to `$XDG_DATA_HOME/engram`, so the store stays at `~/.local/share/engram` and no second `~/.engram` store is created by the bump. The wrapper must not be removed or relaxed.

Cloud configuration is now in scope, but only as the operator's own enrollment of the nine intended projects. This feature must not unenroll anything, and must not delete local or remote data.

## Tasks

- [ ] **EN-0 — Cloud intent recorded; no clear.** Record, as done above, that cloud replication is wanted and that the 9402 pending mutations must not be cleared. Remaining operator input: the cloud server URL, entered in their own terminal. Closes when EN-7 runs; it does not block EN-1 to EN-6.
- [x] **EN-1 — Version guard as the failing test, observed RED.** Added `engramPackageVersion = pkgs.aytordev.engram.version == "3.1.0";` to the `checks` set in `checks/gentle-ai-engine/default.nix`, nine inserted lines, no other attribute, option namespace or override touched. Observed RED verbatim: `error: AI ownership failures: engramPackageVersion`, exit 1, with `packages/engram/package.nix` still at `version = "2.0.0-rc.11"`. Evidence and the corrected guard location are in "Verified evidence" below.
- [x] **EN-2 — Pin bump to 3.1.0, observed GREEN.** `packages/engram/package.nix`: `version = "3.1.0"`, `rev = "v${version}"` unchanged, `hash` and `vendorHash` refreshed by discovery rather than guessed. Source `hash = "sha256-Dyzi/OH0XwT3Z1QfDM/Tvd6bYcXvQux/jff86st5t30="` independently reproduced with `nix store prefetch-file --json --unpack` against the `v3.1.0` archive, whose tag resolves to `e5c2277f856a5ee8739f297a006cabf6432ba77d`; `vendorHash = "sha256-roVQ+K9Hsz0qi61f+zzb+JvgleOmBHSMcKfhwhI0snQ="`. The package builds to `/nix/store/vzj537fc2pbd8pnbf4y5nk6vvfp0wb90-engram-3.1.0` and that binary reports `engram 3.1.0`; the guard runner exits 0. The `/v2` to `/v3` module path move is confirmed real (`go.mod` declares `module github.com/Gentleman-Programming/engram/v3`) and transparent for `subPackages = ["cmd/engram"]`, which needed no change.

  `doCheck = false` re-examined by observation, not by argument. It was temporarily set to `true` and the build failed exactly as the inherited comment predicted but had never demonstrated for 3.1.0: `net/http/httptest.newLocalListener` panics from `cmd/engram/autosync_e2e_test.go` in `TestMutationTransportAdapterForwardsPromptAuthority`, and `cmd/engram` fails. The workaround is therefore still required, and the comment was updated to record the observed failure and its exact test instead of an inherited claim. Reverting to `false` reproduced the identical store path `/nix/store/vzj537fc…`, confirming the revert was exact.
- [ ] **EN-3 — Focused build and checks. BLOCKED on the subagent defect below.** The focused work is done: `packages.aarch64-darwin.engram` builds, `integration-gentle-ai-engine` exits 0, and `integration-ai-tools-docs-links` exits 0, all with fixture secrets. What remains unmeetable is the independent verifier: `subagent_run` cannot start any child Pi on this host right now, so the required independent confirmation of `engram 3.1.0` and of the wrapper's `ENGRAM_DATA_DIR` resolution has NOT been obtained and must not be reported as if it had.
- [x] **EN-4 — Store backup and doctor baseline.** Snapshot at `$HOME/Library/Application Support/aytordev-system/migrations/engram-engine-v3-2026-10-06T11-20-25Z-DAAtaa`, owner-only, 17 files / 34386529 bytes. Copied the live store `~/.local/share/engram` (`engram.db`, `-wal`, `-shm`, instance id), the stray store `~/.engram` that `engram-single-store` preserved as evidence, and `~/.pi/gentle-ai`; `~/.config/engram` does not exist. The manifest records `preUpgradeEngineVersion = engram 2.0.0-rc.11` and the full baseline in `doctor-before.txt` / `doctor-before.json`: 8 checks, 6 ok, 1 warning, 1 error, 9 `foreign_sync_target` findings, 9402 unacknowledged mutations. No credential or memory contents were inspected, printed or hashed.

  Two corrections to this task as originally written. First, the required independent audit was **not** achieved: a second method was used across 23 entries and found 0 anomalies (no directory outside 700, no file outside 600/700, no symlink, no foreign owner), but it ran in the same process, because `subagent_run` is blocked by the quiet-tools defect above. That is disclosed rather than smoothed over. Second, per-file hashing was rejected as an integrity gate after it appeared to fail: the live `engram.db` produced three distinct hashes during this session, because a WAL-mode store mutates on ordinary access including reader-triggered checkpointing. Validity was established at the SQLite level instead, on a disposable copy so the backup stays pristine: with `ENGRAM_DATA_DIR` pointed at that copy, `engram doctor` reproduces the identical diagnosis (8 checks, the same 9 findings). The copy-time hash remains in the manifest for provenance only.
- [ ] **EN-5 — Activation and readback (interactive sudo handoff).** The operator runs `just darwin-switch civislend`. Then independently read back the live generation, Pi and both engram binaries, and confirm the store path is unchanged and the old generation remains as rollback.
- [ ] **EN-6 — Restart and live capability verification.** Restart the long-running `engram serve` daemon and Pi. Verify `GET /health` advertises `capabilities.isolated_session_registration: true` and version `3.1.0`, that `mem_list_projects` no longer returns HTTP 404, and that `engram doctor repair --check sync_target_closed_space --plan` is now supported rather than rejected.
- [ ] **EN-7 — Cloud configuration and enrollment (operator handoff).** The operator sets the server with `engram cloud config --server <url>` in their own terminal and enrolls the nine intended projects with `engram cloud enroll <project>`. Then measure, honestly: do the 9402 pending mutations deliver, and do the nine `foreign_sync_target` findings close because the targets became legitimate? Record delivered, still-pending and newly-failed counts. Do not clear anything at this step.
- [ ] **EN-8 — Clear or re-acknowledge only what remains undeliverable.** For any target that EN-7 proves cannot be delivered, use the repair now available in 3.1.0: `engram doctor repair --project <project> --check sync_target_closed_space --plan`, review the plan, then `--apply` only with explicit approval. Never as a first resort, and never for a target that produced deliveries.
- [ ] **EN-9 — Resolve session `manual-save` ownership.** The operator names the project that session belongs to, then `engram projects rescue-ownership --project <name> --session manual-save`. Requires confirmation; do not guess the project from the session name alone.
- [ ] **EN-10 — Post-upgrade doctor comparison.** Run `engram doctor` and compare against the EN-4 baseline, including the two checks new in 3.1.0 (`ambiguous_active_runtime_sessions`, `orphaned_pending_relations`). Report every remaining finding honestly rather than declaring the store clean.
- [ ] **EN-11 — Full repository validation and publication.** `just fmt-check`, Darwin `nix flake check` with fixture secrets, all-systems evaluation and the civislend production build. Then the issue, branch push and pull request with one `type:*` label. Records every failed, skipped or pending check. No activation inside this task.

## Verification approach

The load-bearing evidence is behavioural, not declarative: a version string in a Nix file proves nothing about the running engine, and the plugin deliberately guesses no version floor. Acceptance therefore requires the live `/health` capability advertisement, a working `mem_list_projects`, and a 3.1.0 doctor that answers the repair check, measured after the restart, in addition to the Nix build and check results. Where a check cannot run, record it as pending rather than passing.

Two failures observed in the GU-4 cycle must not be repeated here: a verify step that claimed a passing formatter exit for an unsupported flag, and any capture or verdict that was never actually admitted. Report unresolved outcomes as unresolved.

## Risks

- **Store migration.** A 2.x to 3.x engine move may alter SQLite schema or session identity semantics. Mitigated by EN-4 before EN-5, and by keeping the old generation for rollback.
- **Cloud enrollment mutates the store.** Enrolling writes sync state. EN-4 must run before EN-7, not after.
- **Clearing deliverable data.** The strongest risk in this feature. If EN-8 runs before EN-7 has proven a target undeliverable, real pending writes are discarded irrecoverably. EN-8 is deliberately last and approval-gated.
- **`/v2` to `/v3` module path.** A build break is the likely failure mode; it is caught by EN-3 before any activation.
- **Daemon staleness.** `engram serve` has been running since before the change. An old daemon left alive after an upgrade is the failure upstream names explicitly, so EN-6 restarts it rather than assuming.
- **New doctor checks.** 3.1.0 evaluates two checks the pinned engine never ran. Reporting them as fresh discoveries, not regressions, is part of EN-10.
- **Misattributed findings.** The store's pre-existing doctor error could be blamed on this change, or vice versa. The EN-4 baseline exists to keep that distinction honest.

## Non-goals

- Changing the Pi plugin version, the plugin's capability logic, or `~/.pi/agent/settings.json`.
- Unenrolling projects, or deleting local or remote cloud data.
- Bumping Pi, Gentle AI or Gentle Shell, or adopting the uncommitted `flake.lock` divergence.
- Adding a second engram store, removing the wrapper, or moving the data directory.
- Repairing store findings this feature did not cause, beyond the EN-7 to EN-9 items explicitly decided here. `engram-single-store` retains its own deferred items.

## Verified evidence

EN-1 RED, captured with the exact runner from the execution contract:

```
error: AI ownership failures: engramPackageVersion
```

Exit 1, with `packages/engram/package.nix` still at `version = "2.0.0-rc.11"`. This matches the GU-1 shape (`AI ownership failures: packageVersion` while the gentle-ai pin was 3.7.0).

The guard is proven well-formed rather than merely failing: `nix eval --raw path:.#packages.aarch64-darwin.engram.version` returns `2.0.0-rc.11` and `.name` returns `engram-2.0.0-rc.11`, and evaluation reaches the `throw` instead of an attribute error. The only reason it fails is the pin value; EN-2 should turn it GREEN.

Corrected guard location. My first attempt asserted `tools.engram.package.version` and produced `error: attribute 'version' missing` — a broken-guard error, not a RED, and it was not reported as EN-1 evidence. The module option asymmetry is real and deliberate:

- `gentle-ai` uses `mkPackageOption pkgs "gentle-ai" { default = ["aytordev" "gentle-ai"]; }`, so `tools.gentle-ai.package` is the derivation and `.version` exists. That is why the neighbouring `packageVersion` guard works.
- `engram` declares `package = lib.mkOption { type = lib.types.package; default = engramWrapped; }`, where `engramWrapped = pkgs.runCommand "engram-wrapped" ...` wraps `pkgs.aytordev.engram` and has no `version` attribute. The module comment records why: `mkPackageOption` cannot express a derivation-valued default.

The pin is therefore asserted on `pkgs.aytordev.engram`, the derivation the wrapper execs. The wrapper's linkage is already covered by the check's existing `engramEnvironment` assertion (`ENGRAM_BIN == lib.getExe tools.engram.package`).

Placement decision, correcting the candidate recorded when this feature was opened. The original plan named a new `checks/engram-engine/default.nix`. `checks/gentle-ai-engine/default.nix` already owns the AI package-ownership assertions and already references `engram` in `packagesEnabled`, `packagesDisabled`, `packageOverrides` and `engramEnvironment`, so a new directory would have duplicated surface and split one regression suite. `checks/AGENTS.md` also directs naming a check by the behavior it tests and notes that new directories default to the `integration-*` prefix. The guard was added to the existing check instead.

## Blocking defect found during EN-3: subagents cannot start (2026-10-06)

Every `subagent_run` fails before the agent settles:

```
Failed to load extension "~/.pi/agent/npm/node_modules/gentle-pi/extensions/quiet-tools.ts":
  Failed to load extension: (0, _piCodingAgent.createCodemodeExtension) is not a function
Hint: Start without extensions using "pi -ne".
```

Established by reading, not by guessing:

- `gentle-pi/lib/codemode-renderer.ts:2` imports `createCodemodeExtension`, and line 177 uses it as a default parameter: `factory: ExtensionFactory = createCodemodeExtension()`. The failure is that call.
- Pi `1.0.3` **does** export it: `dist/index.d.ts:29` re-exports it and `dist/index.js` re-exports it from `./extensions/codemode/…`. So this is a resolution or interop defect in the Pi `1.0.3` plus `gentle-pi@4.0.0` combination on the child-process path, not a missing host API.
- `gentle-pi@4.0.0` declares `@earendil-works/pi-coding-agent >=0.99.1` as its peer, which `1.0.3` satisfies, so the peer range did not warn about this.
- A non-interactive parent-side run (`pi -p --no-session`) only emits the cosmetic `builtin:codemode` warning, while the child-process path fails hard. The two paths differ, which is why an in-session smoke test did not catch this.

Impact on this feature: EN-3's independent verifier cannot run, and every other delegation in the ODD ladder is degraded to inline work. This is reported as blocked, never as verified.

Options, none taken yet, and the choice is the operator's:

1. Disable the renderer with its own supported switch. `lib/quiet-tools-config.ts:1` defines `QUIET_TOOLS_ENV = "GENTLE_PI_QUIET_TOOLS"` and line 5 reads `env[QUIET_TOOLS_ENV] !== "0"`, so `GENTLE_PI_QUIET_TOOLS=0` turns it off. `extensions/quiet-tools.ts:793` then returns early. Cost: the compact codemode cards and the `pi-pretty` suppression of `read`/`bash`/`ls`/`find`/`grep` are lost. This cannot be tested from inside the current session, whose environment is already fixed; it needs a relaunch by the operator.
2. Filter the extension out in `~/.pi/agent/settings.json` by extending the existing filter to `["!startup-banner.ts", "!quiet-tools.ts"]`. The mechanism is already proven in place by `!startup-banner.ts`. Trade-off: `settings.json` is native-owned, and `gentle-ai sync` is documented to normalise managed entries. Testable in-session because both parent and child read that file.
3. Bump Pi to upstream `1.0.4`, which is above the nixpkgs pin, and see whether the interop is fixed. Unproven, and it collides with the unresolved uncommitted `flake.lock` divergence.
4. Report upstream and accept degraded delegation until a fixed pairing ships.

## Next action

**EN-5 is the next step and it belongs to the operator.** The rebuilt engine cannot reach the live system without an activation, and that activation needs interactive `sudo`. In your own terminal:

```sh
cd /Users/avicente/Developer/aytordev/system-engram-engine-v3
just darwin-switch civislend
```

Enter any password only there, never in chat. Everything downstream depends on it: EN-6 (restart the `engram serve` daemon and Pi, then verify `capabilities.isolated_session_registration` and that `mem_list_projects` stops returning HTTP 404), EN-7 (cloud configuration and enrollment, which also needs the server URL), EN-8, EN-9 (which needs the project that owns session `manual-save`) and EN-10.

Two items stay open and must not be reported as done: EN-3's independent verifier, blocked by the quiet-tools defect, and EN-11's publication, which needs explicit authorization for the branch push and the pull request.
