# Engram engine v3 alignment

## Goal and authority

Target: move the Nix `packages/engram` pin from **`2.0.0-rc.11`** to **`3.1.0`**, so the pinned engine satisfies the floors the current Pi plugin `gentle-engram@0.2.0` already declares. The plugin is current and is not changed by this feature; the engine is the mismatched half.

Authorized at open time: creating this feature record, the feature branch and its worktree. **Not authorized yet:** the pin bump, Nix activation, store or cloud changes, commits, branch push, or a pull request. Each needs its own explicit go-ahead. The store-hygiene prerequisite below is a user data decision, not a delegated one.

Worktree `../system-engram-engine-v3`, branch `feat/engram-engine-v3`, base `e537e7bf45b1873b3708163e8d582aab3bbf8c96` (`main`, merge of PR #232). Pi/Pen restart and any interactive `sudo` remain manual.

Base-state caveat recorded at open time: this branch's committed `flake.lock` carries nixpkgs `494ce7fd23ff6a5dff39e1fb11e9b6f2ac74bf25` (Pi 1.0.2), while the live generation 45 depends on an **uncommitted** `flake.lock` nixpkgs `151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4` (Pi 1.0.3). That divergence predates this feature, must not be silently adopted here, and needs its own resolution. It does not affect the engram derivation, which does not depend on the Pi version.

## Problem

`Gentleman-Programming/engram` is one repository with two independent release lines: the Go engine tagged `v*` (v2.1.0, v2.2.0, v2.2.1, v3.0.0, v3.1.0) and the Pi plugin tagged `pi-v*` (newest `pi-v0.2.0`, published to npm as `gentle-engram@0.2.0`). The plugin's `0.x` numbering is its own line; it is not a stale engine release.

The pinned engine is behind **two published floors**:

| Floor | Recorded in | Pinned engine |
| --- | --- | --- |
| ≥ **2.1.0** for "Pi project listing" | v2.1.0 notes | `2.0.0-rc.11` ✗ |
| ≥ **3.0.0** for `expected_project`, `resume` registration and isolated cross-project saves | `pi-v0.2.0` notes | `2.0.0-rc.11` ✗ |

Measured against the live profile on 2026-10-06, not inferred:

| Operation | Engine `2.0.0-rc.11` | Evidence |
| --- | --- | --- |
| `mem_save`, `mem_search`, `mem_context`, `mem_session_summary` | works | used across the session |
| `mem_update`, `mem_delete` | works | scratch observation reached `revision_count: 2`, then hard-deleted |
| `mem_stats` (383 sessions / 555 observations / 708 prompts / 9 projects) | works | live call |
| `mem_current_project`, `mem_review`, `mem_doctor` | works | live call; `available_projects` degrades to `null` |
| `mem_list_projects` | **fails, HTTP 404** | live call |
| save to another project ("satellite") | fails closed | `GET /health` carries no `capabilities` object |
| `resume` registration of ended sessions | unverified | declared v3 requirement |

`GET http://127.0.0.1:7437/health` returns `{"instance_id":"…","service":"engram","status":"ok","version":"2.0.0-rc.11"}` with no `capabilities` object at all. The plugin requires `capabilities.isolated_session_registration === true` on every satellite registration flight and fails closed with explicit upgrade guidance otherwise, writing nothing.

Identity and ownership are sound: `2.0.0-rc.11` is exactly the release where instance identity first shipped, and the plugin's `isPreIdentityEngramVersion` treats it as identity-capable rather than legacy.

Rolling the plugin back to `0.1.16` is explicitly **not** the fix. Release note and code agree that an old server "may ignore isolated and normalize omitted directory to its cwd", so `0.1.16` could write cross-project data to the wrong project silently, while `0.2.0` refuses loudly. `0.2.0` is the safer state; the engine is what moves.

## Execution contract

- ODD delegated direct, one sequential writer; the parent owns this file, its Engram mirror `odd/engram-engine-v3/tasks`, decisions and commits.
- TDD **on**, source **explicit user choice**. Observe RED before the pin changes, then GREEN and refactor.
- The RED only exists if a guard exists. `main` has **no Nix assertion on the engram version**, unlike `checks/gentle-ai-engine/default.nix:105` (`packageVersion = tools.gentle-ai.package.version == "4.0.0"`). EN-1 therefore adds the missing assertion as the failing test, mirroring the gentle-ai pattern and its `AI ownership failures: packageVersion` shape.
- Exact runner: `nix build path:.#checks.aarch64-darwin.integration-gentle-ai-engine --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`, plus the engram check introduced by EN-1.
- Full evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`.
- Format: `just fmt-check`.
- Source surfaces: `packages/engram/package.nix`, a new `checks/engram-engine/default.nix` (candidate location, confirm in EN-1), and `docs/ai-tools/` only if a documented contract changes.
- Fixture secrets apply to checks only. Production build and switch use real host inputs. Never print credentials and never activate fixtures.
- Interactive `sudo` is required for activation. The user runs `just darwin-switch civislend` in their own terminal and enters any password there, never in chat. No askpass, no privilege bypass.
- RDD enabled; provider-owned bindings and consent; exact work-unit commits only, with a Conventional Commit message per task. Checkboxes never grant review or delivery.
- Commit the store backup path and the observed doctor output as evidence; never commit credential bodies.

## Ownership decision (no plugin change, no second store, no cloud change)

The engine stays Nix-owned through `packages/engram/package.nix`, matching the existing rule that Nix-owned executables are updated through their Nix pins and that `GENTLE_AI_NO_SELF_UPDATE`/native self-update paths must not touch them. The plugin stays native-owned through the versioned npm spec. This feature does not add a second writer over `~/.pi/agent/settings.json`.

`modules/home/programs/terminal/tools/engram/default.nix` wraps the binary with `makeWrapper` and pins `ENGRAM_DATA_DIR` to `$XDG_DATA_HOME/engram`, so the store stays at `~/.local/share/engram` and no second `~/.engram` store is created by the bump. The wrapper must not be removed or relaxed.

Cloud enrollment is explicitly out of scope: `engram cloud status` reports cloud as not configured, and this feature must not enroll or unenroll anything.

## Prerequisite: store hygiene (blocking, needs a user decision)

`engram doctor` on the current engine reports 8 checks with 6 ok, 1 warning and 1 error.

**Error `sync_target_closed_space`, 9 findings — 9402 unacknowledged mutations**: `cloud:system` 3199, `cloud:brain` 2521, `cloud:harness-civislend-analisis` 2491, `cloud:anonymizer` 620, `cloud:platform` 543, `cloud:documentation` 19, `cloud:secrets` 4, `cloud:downloads` 3, `cloud:avicente` 2. Upstream's reason: a `sync_state` row for an unknown target records progress no configured pipeline can ever advance, so it rots while appearing live. Because `engram cloud status` reports cloud as not configured, no pipeline can deliver them.

**Warning `unowned_session_project`**: session `manual-save` carries unclassified or invalid ownership metadata. Safe next step, requiring confirmation: `engram projects rescue-ownership --project <name> --session manual-save`.

`engram doctor` is diagnostic by default and **exits 0 while reporting `error`**, so it must be read rather than exit-checked. Repairs are separate and default to dry-run: `engram doctor repair --project <project> --check <code> (--plan|--dry-run|--apply)`.

This must be decided **before** the pin bump, so the bump's verification is not muddied by pre-existing findings and so the migration is not mistaken for their cause. Two coherent branches, for the user: run `engram cloud enroll <project>` where delivery should resume, or clear/re-acknowledge the pending mutations through the supported repair workflow once per target, starting with `--plan`.

## Tasks

- [ ] **EN-0 — Store decision (blocked on the user, no writer).** Obtain the explicit choice for each of the 9 stale `cloud:*` targets (enroll or clear/re-acknowledge) and for session `manual-save`. Record the decision in this file. No repair runs without it. This task closes with a recorded decision, not with an edit.
- [ ] **EN-1 — Version guard as the failing test, observed RED.** Add the missing engram version assertion mirroring `checks/gentle-ai-engine/default.nix`. Run the exact runner against the pinned `2.0.0-rc.11`, record the RED output verbatim, and keep overrides and option namespaces untouched.
- [ ] **EN-2 — Pin bump to 3.1.0, observed GREEN.** `packages/engram/package.nix`: `version = "3.1.0"`, `rev = "v${version}"` unchanged, refresh `fetchFromGitHub.hash` and `vendorHash`. Re-examine the `doCheck = false` workaround and its recorded reason. Confirm the upstream `/v2` to `/v3` Go module path move is transparent for `subPackages = ["cmd/engram"]`, and record why if it is not.
- [ ] **EN-3 — Focused build and checks.** Build the package and run the engram check plus `integration-gentle-ai-engine` and `integration-ai-tools-docs-links` with fixture secrets. An independent verifier confirms the binary reports `engram 3.1.0` and that the wrapper still resolves `ENGRAM_DATA_DIR`.
- [ ] **EN-4 — Store backup.** Owner-only backup of `engram.db` plus `-shm`/`-wal` and the relevant configuration, on a local filesystem, with a manifest recording the pre-upgrade engine version, `engram doctor` output and byte counts. Independent stat-only permission audit. No credential contents inspected or logged.
- [ ] **EN-5 — Activation and readback (interactive sudo handoff).** The user runs `just darwin-switch civislend`. Then independently read back the live generation, Pi and both engram binaries, and confirm the store path is unchanged and the old generation remains as rollback.
- [ ] **EN-6 — Restart and live capability verification.** Restart the long-running `engram serve` daemon and Pi. Verify `GET /health` advertises `capabilities.isolated_session_registration: true` and version `3.1.0`, and that `mem_list_projects` no longer returns HTTP 404. Re-measure the write paths that already worked so the upgrade is proven non-regressive.
- [ ] **EN-7 — Post-upgrade doctor.** Run `engram doctor` and compare against the EN-4 baseline. Follow only the guidance applicable to this store, and report every remaining finding honestly rather than declaring the store clean.
- [ ] **EN-8 — Full repository validation and publication.** `just fmt-check`, Darwin `nix flake check` with fixture secrets, all-systems evaluation and the civislend production build. Then the issue, branch push and pull request with one `type:*` label. Records every failed, skipped or pending check. No activation inside this task.

## Verification approach

The load-bearing evidence is behavioural, not declarative: a version string in a Nix file proves nothing about the running engine, and the plugin deliberately guesses no version floor. Acceptance therefore requires the live `/health` capability advertisement and a working `mem_list_projects`, measured after the restart, in addition to the Nix build and check results. Where a check cannot run, record it as pending rather than passing.

Two failures observed in the GU-4 cycle must not be repeated here: a verify step that claimed a passing formatter exit for an unsupported flag, and any capture or verdict that was never actually admitted. Report unresolved outcomes as unresolved.

## Risks

- **Store migration.** A 2.x to 3.x engine move may alter SQLite schema or session identity semantics. Mitigated by EN-0 before EN-2 and EN-4 before EN-5, and by keeping the old generation for rollback.
- **`/v2` to `/v3` module path.** A build break is the likely failure mode; it is caught by EN-3 before any activation.
- **Daemon staleness.** `engram serve` has been running since before the change. An old daemon left alive after an upgrade is the failure upstream names explicitly, so EN-6 restarts it rather than assuming.
- **Unguarded pin.** With no Nix assertion, a future bump could drift unnoticed; EN-1 closes that gap deliberately.
- **Misattributed findings.** The store's pre-existing doctor error could be blamed on this change, or vice versa. The EN-4 baseline exists to keep that distinction honest.

## Non-goals

- Changing the Pi plugin version, the plugin's capability logic, or `~/.pi/agent/settings.json`.
- Enrolling, unenrolling or reconfiguring cloud sync beyond the explicit EN-0 decision.
- Bumping Pi, Gentle AI or Gentle Shell, or adopting the uncommitted `flake.lock` divergence.
- Adding a second engram store, removing the wrapper, or moving the data directory.
- Repairing store findings that this feature did not cause, without the EN-0 decision.

## Next action

EN-0 is the only unblocked next step and it belongs to the user: decide the 9 stale `cloud:*` targets and session `manual-save`. Nothing else in this feature can start first without risking a muddied migration baseline. Once EN-0 is recorded, EN-1 adds the missing version guard and observes RED against the still-pinned `2.0.0-rc.11`, which is the first authorized source write.
