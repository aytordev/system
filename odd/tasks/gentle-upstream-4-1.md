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
  whose closure carries `gentle-ai-4.1.1` and `pi-coding-agent-1.0.2`;
  all-systems evaluation exit 0 (107 checks, 55 Darwin / 52 Linux); CI-parity
  Darwin `nix flake check` exit 0 with all 55 checks green; `flake.lock`
  unchanged **at that revision** (the later merge with `main` adopts main's
  lock; see the post-merge section below); no stale live `4.0.0` statement left.
  The verifier could not independently reproduce RED end to end (the check
  cannot be overridden without editing the tree) and confirmed the binding
  structurally instead.
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
- [x] **GS-6 — Nix activation (operator-run).** Operated in the terminal on
  2026-10-13. Independent readback: `gentle-ai --version` reports **4.1.1**; the
  PATH entry resolves to
  `/nix/store/hr8pyhys4c68y2k1rac4rgws1vkcn1r4-gentle-ai-4.1.1/bin/gentle-ai`; the
  live system is
  `/nix/store/m3ih8rk6i86in8nvcgbvql9gkyklyvyc-darwin-system-26.11.4cff07d`
  (generation 52, previous 51) with an integrated Home Manager generation at
  `/nix/store/p0r8bs43yq9xljklc261yf0vjsmzr7sn-home-manager-generation`. Pi stays
  `1.0.2`. `nix store diff-closures` between the pre-switch verified build and
  the live system reports only a `source: 10.5 KiB` metadata entry: no package
  drift, and the closure carries `gentle-ai-4.1.1` and `pi-coding-agent-1.0.2`.
- [x] **GS-7 — Shell install and sync.** `pi install npm:gentle-pi@4.1.0`
  installed 4.1.0 and kept the versioned pin **`npm:gentle-pi@4.1.0`** together
  with the `!startup-banner.ts` filter; `settings.json` changed in no other way,
  and `mcp.json`, `~/.pi/gentle-ai/`, the extension set and the npm dependency
  declarations are byte-identical. The package-local engine landed at
  `.gentle-ai/v4.1.1/gentle-ai` and reports `gentle-ai 4.1.1`; its
  `integrity.json` pins asset `gentle-ai_4.1.1_darwin_arm64.tar.gz` with sha256
  `8093dced37130cb26534d81663013f81d9039342e33f00b8c85aa5319aa7eea9`, the same
  digest this change pins in Nix. `gentle-ai sync` (4.1.1) exited 0 and executed
  exactly one change, `~/.config/gga/config` (the generated Guardian Angel
  config); the RDD switch still reads `on`. npm warned that the package's
  `postinstall` is not covered by its allow list, yet the engine asset and its
  integrity manifest were present and verifiable.
- [x] **GS-8 — Close.** Reported honestly below. The only live check left is the
  manual restart: this session loaded Shell 4.0.0, so its in-memory extension and
  the on-disk engine are now different versions and no further native capture,
  delegation or review is run from here.

## Post-merge reconciliation and publication

`main` advanced to `3669165c` while this work sat above `c63e899d`, so the pull
request reported `CONFLICTING` and the branch was merged with `origin/main` in
commit `1bec79a8`. Both sides had touched
`checks/gentle-ai-engine/default.nix` in adjacent lines — main added the Engram
engine assertion, this branch changed the CLI version assertions — and the local
`mergiraf` merge driver resolved the adjacency that GitHub cannot. The resolved
file keeps all three bindings exactly once: `packageVersion` `4.1.1` (line 105),
`engramPackageVersion` `3.1.0` (line 114, byte-identical to main) and
`grep -qx 'gentle-ai 4.1.1'` (line 182).

What the merge imported from main, and the two facts it changed for this change:

- **Pi moves to 1.0.3**, not the 1.0.2 the pre-merge evidence recorded. Main's
  nixpkgs bump (`151fa4e8`) carries it; the branch tip's lock (`494ce7fd`) is
  superseded so the validated lock equals the landing lock. The live host still
  runs Pi 1.0.2 from its activated generation until the next switch.
- **Engram is pinned at 3.1.0** by main, while the sentence in
  `modules/common/ai-tools/README.md` that states the toolchain still read
  `2.0.0-rc.11`. That sentence is the one this change edits for the CLI version,
  so the stale value was corrected here rather than left half-true.
- Main's activation tool-path work (`checks/activation-dry-run`, the Darwin
  docker socket fragment, `packages/engram`) arrives unchanged.

Post-merge re-verification, independent of the writer, on `1bec79a8`:
`git diff --stat origin/main...HEAD` lists exactly the four intended paths;
`flake.lock` and `flake/dev/flake.lock` are byte-identical to main's; the engine
check exits 0 and still exercises the real binary; `just fmt-check` exits 0
(641 traversed, 404 emitted, 0 changed); all-systems evaluation exits 0 with
107 checks (55 Darwin / 52 Linux); CI-parity Darwin `nix flake check` exits 0
with every check green; `just darwin-build civislend` exits 0 to
`/nix/store/6k577w1g4q3hxw51dcg32ml4d0idabkh-darwin-system-26.11.4cff07d`,
whose closure carries `gentle-ai-4.1.1`, `engram-3.1.0` and
`pi-coding-agent-1.0.3`.

### Publication

Issue **#241** (`status:approved`) and pull request **#242**, opened with the
personal account through the module's `ghp` wrapper (the default `gh` wrapper
authenticates as the work account). The pull request carries `type:feature` and
`dependencies`, and the labeler added `Packages`, `Modules` and `Checks`.

### Review position after the merge

The merge created a revision that neither burned lineage covers: the source
work unit was reviewed and acknowledged at the pre-merge tree, and the two
review targets since then are documentation-only deltas. No review facade call
is made after the native swap, because this session's loaded extension is Shell
4.0.0 while the engine on disk is 4.1.1; the pull request states that position
explicitly instead of implying a review that does not exist.

## Verified evidence and limitations

Nothing above is checked off without observed evidence. What remains unproven
or unexercised after the swap:

- The archive digests for `x86_64-darwin` and `aarch64-linux` were verified
  against the two upstream sources (release `checksums.txt` and the tagged
  installer) and against each other, but no local bytes were downloaded for
  those two platforms; `darwin_arm64` and `linux_amd64` were matched against real
  downloaded archives, and `darwin_arm64` was confirmed again by the installed
  engine's own `integrity.json`.
- `fetchurl` verifies SHA-256 only; the release's minisign signature is not
  verified by this derivation.
- RED was observed by the writer against the real check; the independent
  verifier could only reproduce the assertion structurally, not the original
  failure, because the check cannot be overridden without editing the tree.
- The v4.1 behavior described in the README (high-risk-only automatic review,
  provider contract 1.3.0, `sync` retiring SDD artifacts) comes from the release
  notes and the shipped provider-contract asset, not from live observation on
  this host. `sync` reported no SDD artifact to retire here, so that path stayed
  unexercised.
- No restart verification yet: the running session still carries Shell 4.0.0
  in memory while the package on disk is 4.1.0 with engine 4.1.1. Session
  behavior under the new Shell, live UI and native MCP dispatch remain
  restart-dependent.
- The native package swap mints a new review candidate. The final commit on this
  branch touches only this task document: it is a passive documentation-only
  delta, so it is reported and deliberately left unreviewed rather than
  re-invoking the review facade after the engine/extension versions diverged.

## Live state at close

| Surface | Value |
| --- | --- |
| Operator CLI (`PATH`) | `gentle-ai 4.1.1` |
| Shell package (`~/.pi/agent/npm`) | `gentle-pi 4.1.0` |
| Shell package-local engine | `.gentle-ai/v4.1.1/gentle-ai` = `gentle-ai 4.1.1` |
| Shell pin in `settings.json` | `npm:gentle-pi@4.1.0` (banner filter kept) |
| Pi | `1.0.2` (unchanged) |
| Live system | generation 52, `m3ih8rk6i86in8nvcgbvql9gkyklyvyc-darwin-system-26.11.4cff07d` |
| Landing tree (post-merge) | `gentle-ai 4.1.1`, `engram 3.1.0`, `pi-coding-agent 1.0.3` |
| Session in memory | Shell 4.0.0 until restart |

## Next action

Restart Pi from a terminal so the session loads Shell 4.1.0 with the 4.1.1
engine, then verify the running session: the header renders, no loader error
appears, the managed skills and MCP servers still resolve, and a trivial RDD
flow reports provider contract `1.3.0`. The next Darwin switch also moves the
host from Pi 1.0.2 to the 1.0.3 that main's lock carries. Merge remains the
operator's decision; the pull request holds every check performed here.
