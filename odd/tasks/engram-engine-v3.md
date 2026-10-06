# Engram engine v3 alignment

## Goal and authority

Target: move the Nix `packages/engram` pin from **`2.0.0-rc.11`** to **`3.1.0`**, so the pinned engine satisfies the floors the current Pi plugin `gentle-engram@0.2.0` already declares, and so the store's one doctor error becomes repairable. The plugin is current and is not changed by this feature; the engine is the mismatched half.

Authorized so far: creating this feature record, the feature branch and its worktree, the documentation commit `708a9d15`, and an isolated capability probe of the published 3.1.0 binary. **Not authorized yet:** the pin bump, Nix activation, cloud configuration, store repairs, further commits, branch push, or a pull request. The operator supplies the cloud server URL and any token in their own terminal, never in chat.

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
- [ ] **EN-1 — Version guard as the failing test, observed RED.** Add the missing engram version assertion mirroring `checks/gentle-ai-engine/default.nix`. Run the exact runner against the pinned `2.0.0-rc.11`, record the RED output verbatim, and keep overrides and option namespaces untouched.
- [ ] **EN-2 — Pin bump to 3.1.0, observed GREEN.** `packages/engram/package.nix`: `version = "3.1.0"`, `rev = "v${version}"` unchanged, refresh `fetchFromGitHub.hash` and `vendorHash`. Re-examine the `doCheck = false` workaround and its recorded reason. Confirm the upstream `/v2` to `/v3` Go module path move is transparent for `subPackages = ["cmd/engram"]`, and record why if it is not.
- [ ] **EN-3 — Focused build and checks.** Build the package and run the engram check plus `integration-gentle-ai-engine` and `integration-ai-tools-docs-links` with fixture secrets. An independent verifier confirms the binary reports `engram 3.1.0` and that the wrapper still resolves `ENGRAM_DATA_DIR`.
- [ ] **EN-4 — Store backup and doctor baseline.** Owner-only backup of `engram.db` plus `-shm`/`-wal` and the relevant configuration, on a local filesystem, with a manifest recording the pre-upgrade engine version, the full `engram doctor` output and byte counts. Independent stat-only permission audit. No credential contents inspected or logged. This must precede every store mutation, including the cloud configuration in EN-7.
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

## Next action

EN-1 is the next authorized step and it is a source write: add the missing engram version guard and observe it fail against the still-pinned `2.0.0-rc.11`. EN-0 no longer blocks it, because the decision is recorded and the repair dependency runs the other way. EN-7 and EN-9 additionally wait on the operator: the cloud server URL, entered in their own terminal, and the project name that owns session `manual-save`.
