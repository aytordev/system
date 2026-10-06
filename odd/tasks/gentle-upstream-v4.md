# Gentle upstream v4 migration

## Goal and authority

Targets: Civislend Pi **1.0.0**, Nix operator Gentle AI **4.0.0**, native Shell **`npm:gentle-pi@4.0.0`**. Nix and the native package-local engine have separate owners.

The user authorized source changes, Nix activation including pending main/database changes, native install and `sync`, then explicitly confirmed strict TDD and local commits. The user later authorized this delivery cycle: full repository validation plus pushing the branch and creating the issue and pull request for the v4 source change. Still excluded: model/provider changes, GitHub permissions, old-review cleanup, secret migration, database connections, and system activation or native installation inside this cycle. Pi/Pen restart is manual.

Worktree `../system-gentle-upstream`, branch `feat/gentle-upstream-v4`, base `9ca3827b21d8d770e71b13cf7a79222208ad25a6`, reviewed boundary `2d0a12eb6235ec94391fad6624b16e067c0db308`. Preserve original clean checkout `948d142c` and database checkout `e548f029` with its dirty progress/frozen authority.

Baseline: active Pi 0.87.1, Node 24.20.0, operator/Shell/bundled engine 3.7.0. Main's nixpkgs `a7868a727837f3c09cee2ce0ca671c76b1589fed` already provides Pi 1.0.0; no lock bump/overlay. Old live system `/nix/store/dmz79x8gdjip1j8hh09zqdsa7qxdb0rf-darwin-system-26.11.4cff07d`, generation 44; recheck before rollout. Observed integrated Home Manager gcroot: `/nix/store/z3kzxkd2246j8vaj75vnn3r01gir4z8g-home-manager-generation`.

## Execution contract

- ODD delegated direct, one sequential writer; parent owns this file, full Engram mirror `odd/gentle-upstream-v4/tasks`, decisions and commits.
- TDD **on**, source **explicit user choice**. Observe RED before pin changes, GREEN/refactor; never restore retired v4 Strict TDD selector/SDD workflow.
- Exact runner: `nix build path:.#checks.aarch64-darwin.integration-gentle-ai-engine --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`. Related `integration-ai-tools-docs-links` uses the same flags.
- Full evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`.
- Source surfaces: `packages/gentle-ai/package.nix`, `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`. Preserve overrides/options and native configuration ownership.
- Tests use fixture secrets; production build/switch use real existing host inputs normally. Never activate fixtures or print credentials.
- Snapshot configuration and npm package state privately, retain generation/package rollback evidence, preserve user-owned/unknown assets. No blind companion deduplication.
- Native replacement last: live Pi must satisfy Shell 4 prerequisites before `sync` retires the MCP adapter for native MCP. This session loaded 3.7.0; after replacement no old capture/delegation, explicit restart handoff.
- Interactive sudo is required. No password request, askpass or privilege bypass.
- RDD enabled; exact work-unit commits only, provider-owned bindings/consent. Historical Pi/database lineages stay untouched. Checkboxes never grant review/delivery.
- Forecast 150–250 authored changed lines; observed commits 117 lines. Delivery `ask-on-risk`; publication of this source change is authorized: repository-only validation, branch push, issue and pull request. System activation and native installation stay outside the pull request scope.

## Tasks

- [x] **GU-1 — Pins, regression and docs.** Delegated writer plus independent source/formatter verification. Commit `23b55a2c009883209c759f83cfa0c7fde5821f78`, four files/105 changed lines. Native medium/reliability review `review-2bff032facdc20d9` approved once and exact acknowledgement burned authority. Advisory `R3-001` engine-check line 173 is informational, no correction; body not returned, do not invent it.
- [x] **GU-2 — Stack verification and production build.** Independent verifier passed evaluation, related builds, actual production build and isolated SDK/engine smoke. Evidence commit `2d0a12eb6235ec94391fad6624b16e067c0db308`, 12 metadata-only lines; native low-tier closure `review-6c93c31f906cc03a` acknowledged/burned, no model run. Live UI/MCP dispatch explicitly deferred to restart.
- [ ] **GU-3 — Private snapshot, Nix activation/readback.** Parent-approved operational execution, independent readback. State: blocked on interactive sudo, not complete. Private snapshot and independent privacy audit completed; closure delta reviewed and current-pin database check passed. Still require repository switch and actual live system/HM/Pi/operator readback; do not commit completion evidence before activation is observed.
- [ ] **GU-4 — Native pin, sync and restart verification.** Final bounded transaction after live Pi prerequisite. Preserve settings/models, exact native package and bundled-engine 4.0.0, documented sync order/MCP migration. Evidence checkpoint before replacing own harness; explicit manual restart and honest pending live checks.
- [ ] **GU-5 — Full repository validation and publication.** Repository-only scope: `just fmt-check`, Darwin `nix flake check` with fixture secrets, all-systems evaluation and the civislend production build, then the approved issue, branch push and pull request with one `type:*` label. Records every failed, skipped or pending check honestly; no activation and no native installation.

## Verified evidence and limitations

GU-1 strict RED: `AI ownership failures: packageVersion` while pin was 3.7.0. GREEN executes the real Darwin binary with isolated HOME/XDG/no-self-update, requires exact `gentle-ai 4.0.0` and no `.pi` onboarding. Overrides preserved; independent engine/docs checks and whitespace check passed. Publisher archive pins from tagged installer `https://raw.githubusercontent.com/Gentleman-Programming/gentle-shell/v4.0.0/scripts/gentle-ai-installer.mjs`; Nix validated Darwin-arm64 archive bytes/root `LICENSE`/`gentle-ai` layout. No foreign runtime/minisign verification; Darwin strip/codesign changes the installed binary hash.

Formatter incident resolved independently: writer incorrectly claimed exit 0 for `nix fmt -- --check`; actual flag is unsupported (exit 1). Exact repository treefmt 2.6.0/config on temporary copies with `--tree-root TEMP --ci` passed, two Nix files/zero changes; Markdown unmatched. Repository entry point: `just fmt-check` (`nix run .#formatter.aarch64-darwin -- --ci path`). No source change by verification.

Native source target `sha256:629bb68f5801813b43002df48b044870ceb3db19721ed1c3a7137884c1d1fac6`, consumed revision `sha256:1ff4146558022f370d4bb3a2372b7a0f802e5a0d7b30f1edd0326c7d24ce9549`. Evidence-only target `sha256:38af4a4c015c39b1c6377b7d3d00861931e536a287ec6b8f37f9546893ea8ff4`, consumed revision `sha256:661598b3ffcc043d78ab4a80985d4049e34b567cff0537356b14f4f2a0280817`. Both acknowledgements returned `authority=burned`; no STATUS after either burn. ASSESS remains schema-incompatible/unassessable in this old harness; initial required independent verification completed, then immediate same-candidate `nativeReviewOutcome=closed` recorded after each acknowledgement. No fabricated tier or approval from failed assessment.

GU-2 all-systems fixture evaluation: **105 checks (54 Darwin/51 Linux)**, no build implied. Actual focused Darwin builds passed: Pi GUI environment, docs generation, skill contract, AI inventory/dependencies. Production `just darwin-build civislend` passed; `result` points to `/nix/store/ck295c804h2wwr3bsxjqlksavflwksnw-darwin-system-26.11.4cff07d`. Justfile exposes no lock-write flag mechanism; guarded lock SHA remained `43b0ac65b424f730d61c756e8033e818dc09b8c3f643cba75e85479c6b9da9a2`.

Realized Pi `/nix/store/wpn9ql9wpns0g1phirx3s1p4l57y6a81-pi-coding-agent-1.0.0` reports 1.0.0; Node 24.20.0. Private npm fixture used SDK 1.0.0/Shell 4.0.0. Package-private engine reports 4.0.0, raw SHA matches publisher `18a9f7fae55d85c95684b6d512a4a148d0cb24a856325f72573c34caf65159eb`. In-memory SDK loaded startup header/Gentle 4 with zero loader errors, 14 commands/13 tools, no prompts/provider/MCP calls or real profile writes. Session-event dispatch/live UI/native MCP were not exercised and remain restart-dependent. Build is not activation.

## Next action

Private rollback snapshot: `$HOME/Library/Application Support/aytordev-system/migrations/gentle-upstream-v4-2026-10-05T11-43-02.795Z-pG5WE1`. Eight existing configuration/package surfaces, 204837242 bytes, full native npm tree and opaque configuration copied; no credential bodies inspected/logged. Independent stat-only audit: owner UID 501, directories 700, regular files 600/executables 700, symlinks preserved, zero permission/owner anomalies; `snapshot.json` complete=true. Old system generation 44 and integrated HM z3 retained; native package remains 3.7.0.

`nix store diff-closures /run/current-system ./result` passed (49 package additions/12 removals), including Pi/Gentle, database GUI/clients and other already-accepted main changes. Current-pin Darwin database tooling check passed, no connections/server/GUI launch. A verifier's cross-host warning was independently refuted: OS and BOTH activation scripts declare civislend; store hash prefix `dmz` is not a host identifier. No archetype switch. `configurationRevision=null`; normal repository switch re-evaluates, actual live store path still requires readback.

`sudo -n true` still exits 1, password required. No activation/global native install/sync/model or historical-lineage changes. User interactive handoff:

```sh
cd /Users/avicente/Developer/aytordev/system-gentle-upstream
just darwin-switch civislend
```

The user enters any password only in their terminal, never in chat. After confirmation, independently verify the live Nix/HM closures and exact Pi 1.0.0/operator 4.0.0 before native Shell installation/sync. Live UI/MCP, foreign-architecture runtime and minisign checks remain unperformed; the first two await manual restart, the latter two are outside this host rollout. Current cycle: commit this record, run the full repository validation, then push `feat/gentle-upstream-v4` and open the pull request. GU-3 activation and GU-4 native installation remain unstarted and outside the pull request scope.
