# Feature: gentle-upstream-4-1

## Objective

Advance the two Gentle components to the current upstream line: the Nix-owned
public Gentle AI CLI from **4.0.0** to **4.1.1**, and the native-owned Shell
package (`npm:gentle-pi`) from **4.0.0** to **4.1.0**, and bring the repository's
version statements back in line with the machine.

## Authorization

User authorized this cycle on 2026-10-13, choosing "Repo + máquina (Shell y
switch Nix)". Authorized scope:

- Repository source: the Gentle AI pin, the engine check, the version
  statements, and this task file.
- Runtime: `pi install npm:gentle-pi@4.1.0` and `gentle-ai sync` on this host.
- Nix activation of the new pin: the operator runs the switch command, because
  activation requires an interactive `sudo` that this session cannot supply.

Not authorized: Engram, Pi, flake input bumps, model/provider changes, persona,
secrets, system rollback, and any push, pull request or merge.

Branch: `feat/gentle-upstream-4.1`, based on `origin/main` (`c63e899d`). The
open `feat/pen-dev-1.2.16` work (PR #240) is untouched; this work does not ride
on it, so the review unit stays independent.

The older worktree `../system-gentle-upstream` on `feat/gentle-upstream-v4`
stays untouched. Its blocked GU-3/GU-4 (activate 4.0.0, install Shell 4.0.0) are
**superseded** by this cycle: activating 4.1.1 makes a 4.0.0 activation
pointless, so those tasks are closed as replaced, not resumed.

## Upstream facts (inspected, not assumed)

| Fact | Value | Evidence |
| --- | --- | --- |
| Gentle AI latest release | **v4.1.1**, 2026-10-12T12:19:24Z | GitHub releases API `releases/latest` |
| Gentle AI previous | v4.1.0, v4.0.0, v3.7.0 | release list |
| Shell npm package | `gentle-pi` **4.1.0**, `dist-tags.latest` | `npm view gentle-pi dist-tags` |
| Shell release repo | `Gentleman-Programming/gentle-shell` tag **v4.1.0**, 2026-10-12T13:02:25Z | GitHub releases API |
| Review provider contract | `1.2.0` -> **`1.3.0`** | v4.1.0 release notes |
| Go module path / review CLI | unchanged (`/v4`), additive flags only | v4.1.0/v4.1.1 release notes |

Archive digests were cross-checked three ways for the Darwin arm64 asset: the
publisher's tagged installer
(`gentle-shell` v4.1.0 `scripts/gentle-ai-installer.mjs`, `INSTALLER_VERSION`
4.1.1), the release `checksums.txt`, and a local download. All four systems
match the installer's pinned `sha256` values.

| System | Release asset | sha256 | SRI |
| --- | --- | --- | --- |
| x86_64-darwin | `gentle-ai_4.1.1_darwin_amd64.tar.gz` | `f2e9aebf...decffd` | `sha256-8umuv7owVuiKjXxxk+TowEKC3BJtXqoiFryAferez/0=` |
| aarch64-darwin | `gentle-ai_4.1.1_darwin_arm64.tar.gz` | `8093dced...7eea9` | `sha256-gJPc7TcTDLJlNNgWYwE/gdkDk0LjPwC4yFqlMZqn7qk=` |
| x86_64-linux | `gentle-ai_4.1.1_linux_amd64.tar.gz` | `57869ebc...46b4` | `sha256-V4aevNuluplCSTq0E7vBXRRuJFHE3KPqr88WP8vWRrQ=` |
| aarch64-linux | `gentle-ai_4.1.1_linux_arm64.tar.gz` | `5f8fa385...f4eb` | `sha256-X4+jhXPuoPIRCQLwmWqgsAiqxY3A+aarvfMB3LyT9Os=` |

Archive layout is unchanged: the root carries the `gentle-ai` binary and
`LICENSE` (plus `README.md`, `contracts/`, `docs/`), so `installPhase` needs no
edit. v4.1.1 exists only to re-tag the v4.1.0 commit under a consistent Go module
checksum; it declares no new behavior and no breaking change beyond v4.1.0's.

Behavior that reaches this machine from the v4.1 line:

- **Proportionate native review.** Automatic review starts only for `high` risk;
  `medium` reports `review_due: false` with `under_budget`. Agent-selected lenses
  arrive as additive `--lenses` / `--lenses-reason` flags and the
  `start_lens_selection` capability.
- **Provider contract 1.3.0.** Additive over 1.2.0. Authority carrying a lens
  selection cannot be read by the old binary, so no in-flight lineage may be
  resumed across the swap.
- **`sync` is required after the upgrade.** It retires installed SDD artifacts
  (Gentle-owned Pi/OpenCode/Kilocode SDD agents, skills, commands, and the
  Claude preflight hook) and refreshes orchestrator prompts, permissions, and
  reviewer assets.

Host prerequisites for Shell 4.1.0 are already satisfied on `civislend`: Pi
**1.0.2** (>= 0.99.1) and Node **24.21.0** (>= 22.19).

## Scope

- **Source surfaces:** `packages/gentle-ai/package.nix`,
  `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`,
  and this task file. Preserve the module options, the package-override path,
  and native ownership of `~/.pi/agent`.
- **Runtime:** Shell pin install, `gentle-ai sync`, and the operator-run Nix
  activation of the new pin, in that dependency order.
- **Ordering rule:** the native package swap happens last. This live session
  loads Shell 4.0.0; after the replacement it must run no native capture,
  delegation or review and hand off to an explicit restart.

## Non-goals

- No repository file pins Pi or `npm:gentle-pi`. Shell keeps its upstream-owned
  pin in `~/.pi/agent/settings.json`; the repository only states the version.
- No `gentle-ai` re-architecture, no SDD/OpenSpec reintroduction, no re-adding of
  retired upstream selectors.
- No flake input update, no Engram change, no Pi bump, no MCP migration beyond
  what `sync` itself performs.

## Execution contract

- ODD with one sequential delegated writer; the parent owns this file, the
  Engram mirror `odd/gentle-upstream-4-1/tasks`, decisions, and commits.
- Tests first where they are real: change the engine check to expect 4.1.1 while
  the pin is still 4.0.0 and observe RED, then bump the pin and observe GREEN.
  That check executes the real pinned binary with an isolated HOME/XDG and
  `GENTLE_AI_NO_SELF_UPDATE=1`, so it is genuine evidence, not a label check.
- Exact runner: `nix build .#checks.aarch64-darwin.integration-gentle-ai-engine
  --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file
  --no-link`.
- Full evaluation: `nix flake check --no-build` with the fixture secrets input,
  plus `just fmt-check`.
- Fixture secrets are for checks only; never activate fixtures or print
  credentials. No blind deduplication of user-owned assets.
- RDD is on: the source work-unit commit is the review candidate, and review
  runs before the runtime swap. Verdicts are provider-owned; nothing here
  authorizes delivery.
- Commits are local work-unit commits on the feature branch. Push, PR and merge
  remain the user's decision.

## Tasks

- [x] **GS-1 — RED.** Delegated writer changed both assertions in
  `checks/gentle-ai-engine/default.nix` to `4.1.1` with the pin still at 4.0.0.
  Observed RED: `error: AI ownership failures: packageVersion`, exit 1.
- [x] **GS-2 — GREEN.** `packages/gentle-ai/package.nix` bumped to `4.1.1` with
  the four SRI hashes and a provenance comment naming the installer tag actually
  read. Observed GREEN: the same runner command exited 0 and built
  `gentle-ai-4.1.1` plus `ai-native-ownership-check`, which executes the real
  binary under an isolated HOME and asserts `gentle-ai 4.1.1` and no `.pi`
  profile.
- [x] **GS-3 — Docs.** `modules/common/ai-tools/README.md` states CLI **4.1.1**
  and Shell **`npm:gentle-pi@4.1.0`**, with one added paragraph on what v4.1
  changes here. `just fmt-check` exit 0 (404 files, 0 changed).
- [x] **GS-4 — Independent verification.** Delegated read-only verifier: digests
  re-derived from both upstream sources and matched against downloaded bytes for
  two platforms; engine check GREEN; eight related AI-tools checks exit 0;
  `just fmt-check` exit 0; `just darwin-build civislend` exit 0 to
  `/nix/store/s4pqwzzw6rwpn0jg9jchdq5qy20pxnw8-darwin-system-26.11.4cff07d`
  whose closure carries `gentle-ai-4.1.1` and unchanged `pi-coding-agent-1.0.2`;
  all-systems evaluation exit 0 (107 checks, 55 Darwin / 52 Linux); CI-parity
  Darwin `nix flake check` exit 0 with all 55 checks green; `flake.lock`
  unchanged; no stale live `4.0.0` statement left. The verifier could not
  independently reproduce RED end to end (the check cannot be overridden without
  editing the tree) and confirmed the binding structurally instead.
- [x] **GS-5 — Commit and native review.** Work-unit commit `5ce89368
  feat(ai-tools): bump the Gentle AI pin to v4.1.1` (3 files, +20/-13),
  repository pre-commit hooks green. Native RDD review
  `review-d97430df88969d27`, tier `medium`, lens `review-reliability`, 33
  authored lines, one model run, outcome `approved` and exact acknowledgement
  consumed with `authority=burned`. One advisory, non-blocking finding
  `R3-version-literal-drift` (`packages/gentle-ai/package.nix:7`, severity
  SUGGESTION) records that the version literal now lives in three files; it
  opened no correction and is deliberately not acted on, since the engine check
  is the drift guard.
- [ ] **GS-6 — Nix activation (operator-run).** `just darwin-switch civislend`,
  then read back `gentle-ai --version` = 4.1.1 and the resulting system
  generation.
- [ ] **GS-7 — Shell install and sync.** `pi install npm:gentle-pi@4.1.0`,
  verify the versioned pin and banner filter survived, run `gentle-ai sync` with
  the 4.1.1 CLI, and read back persona, MCP, and package state.
- [ ] **GS-8 — Close.** Honest report of every passed, failed, skipped or
  pending check, with explicit restart handoff.

## Verified evidence and limitations

Nothing above is checked off without observed evidence. What remains unproven
or unexercised at this point:

- The archive digests for `x86_64-darwin` and `aarch64-linux` were verified
  against the two upstream sources (release `checksums.txt` and the tagged
  installer) and against each other, but no local bytes were downloaded for
  those two platforms; only `darwin_arm64` and `linux_amd64` were matched
  against real downloaded archives.
- `fetchurl` verifies SHA-256 only; the release's minisign signature is not
  verified by this derivation.
- RED was observed by the writer against the real check; the independent
  verifier could only reproduce the assertion structurally, not the original
  failure, because the check cannot be overridden without editing the tree.
- The v4.1 behavior described in the README (high-risk-only automatic review,
  provider contract 1.3.0, `sync` retiring SDD artifacts) is taken from the
  published release notes and the shipped provider-contract asset, not from live
  runtime observation on this host.
- Nix activation, the Shell install, and `sync` are still pending; the live
  system and the native package remain at 4.0.0 until GS-6 and GS-7.
