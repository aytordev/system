# Zed upstream snapshots and owned configuration

## Contract

User authorized option 3, Astra/high and strict TDD. Branch `feat/zed-101-alignment`, implementation base `ffdcda09164ceed782e889c36e268451ae9a9c6b`, published HEAD `6d6efadb116b6d11febd1e24af123b2087078730`. Preserve previous uncommitted adaptation, .pi/prior ODD and dirty root/dev locks. Combined lock diff SHA256: `a67bb493d7a8137ba15f2301540f4f92c2d6dc9e99e1581dec698324882202a0`. Implementation initially excluded staging/commits/push. The later explicit delivery authorization below supersedes that restriction for the exact 25-file candidate only. Activation/live HOME edits/global installs remain unauthorized.

## Design

Pinned Python/json5 updater; exact upstream raw settings/keymap/tasks/license, normalized JSON, exact-value policy, selected profile, immutable hashed generations and atomic pointer-last publication. Report-only refresh; apply requires exact reviewed digest. No network evaluation/IFD/new flake inputs. Unselected fields/tasks inert; hashes prove integrity, not authenticity. Failed publication may leave inactive staging; no power-loss guarantee.

Compose reviewed source → owned preferences/keymaps → existing theme adapter. Leaf mkDefaults, replacing source lists, additive HM extensions, explicit context/chord exclusions and ordered keymaps. Safety at ordinary priority, not enforcement. Preserve enable/package API, fonts/theme/privacy/global Neovim and mutable deployment. No FFF/codemux/Ollama/providers/services. Source removal/rollback does not clean live files.

## Tasks

- [x] **T1 — Updater/offline tests.** Astra writer, observed RED/GREEN, final 37 tests before T2. update.py/updater.nix and checks/zed-upstream.
- [x] **T2 — Snapshot/adoption.** Parent reviewed and applied exact digest; 37 setting selectors/46 safe bindings. Offline reconstruction/safety tests RED/GREEN, now 41 tests. Four vendored files/1,175 lines, seven generated files/1,614 lines.
- [x] **F1 — Producer/consumer schema alignment.** Independent verifier discovered future-refresh blocker despite passing active-snapshot checks. Astra correction with RED 385/391 unit and two real-HM failures, then GREEN. Omitted/null global contexts, ordered repeated disjoint contexts and arbitrary JSON action parameters supported; malformed/collision inputs rejected. Owned chords go to last matching block, removed from earlier same-context blocks. Full active settings/keymap parity preserved. README task-hash wording corrected. Independent Astra re-verification passed.
- [x] **T3 — Composition and independent verification.** Source/tests/docs implemented and independently verified: owned preferences/keymaps, checked profile, five compatibility fixes. Removed enable_vim_sneak/agent_follow/notification_panel/chat_panel; folder_icons migrated to folder_indicator. All required technical checks pass; no current technical blocker.
- [x] **R1 — Native review disposition.** Final committed-candidate review is unavailable, not approved. Earlier workspace consent expired without lineage; the later explicit committed-range START failed closed on projection drift before lineage/mutation. Independent exact-candidate verification and incident diagnosis passed; ordinary explicitly authorized delivery continues without bypassing review or Git hooks.

## Snapshot identity

Upstream `jellydn/zed-101-setup`, revision `aab371cdb1118b2da74c1d75e2bd822c77d2523f`; audited target `1.21.0` is provenance, not a custom-package restriction.
Applied report SHA256: `7621f1dd00f332fd6da660525c7ab27af8025613842fb95b1e9d536f2f5667d2`.
Generation suffix/manifest SHA256: `6f0093869cbfbebe00660432bef8b940d62ba8b4efd1ea3f7db15897dc9720e8`.
Profile SHA256: `f669d3f5a5012563da71513af340e07e016aa692dad709082d3f881c3fffbaaf`.
Root policy SHA256: `5f58cf96171818cd4031c75bea34fa75495c90b990ee21f853c59af5d739c0c9`. All raw hashes in manifest; preserved across composition/correction.

## Verification evidence

All writers/verifiers attested `openai-codex/gpt-6-astra`, reasoning `high`. Explicit-user strict TDD; intended assertions failed before code changes, not setup alone. Initial T3 RED 376/379 unit plus auditedKeys/nestedPreferenceOverride; F1 RED above.

Final independent verification: **393 unit tests**, **41 updater tests**, **22 real-HM checks + 3 generated-JSON assertions**, home-portability/module-contract/theme-migration builds all pass. Final realizations cached, stored logs inspected; writers observed fresh GREEN. Fresh both-platform evaluation, packaged offline verify and schema/composition probes pass. Eighteen malformed/collision cases rejected. Nine Nix files passed pinned Alejandra --check; README read back (no Markdown formatter configured). Fourteen source/config/check hashes and Git inventory unchanged across verifier execution; locks/snapshot preserved. No failed command in final independent round.

Runner prefix: `nix build --no-link --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets`; targets `path:.#checks.aarch64-darwin.{unit-nix-unit,integration-home-zed,integration-zed-upstream,integration-home-portability,integration-module-contract,integration-theme-migration}`. All-platform evaluation: `nix flake check --no-build --all-systems --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets path:.`. Updater via `nix run` with same override/no-write-lock-file and `path:.#checks.aarch64-darwin.integration-zed-upstream.updater`, command `verify --root "$PWD/modules/home/programs/desktop/editors/zed"`. `path:.` includes unstaged files; only Nix store/cache/test-temp outputs allowed.

## Review and limits

Native inspect selected intended untracked source files excluding ODD. Corrected target was `sha256:73497aa716302a8ae15da38d381de741c7c5d4c1b96686225c29b641f4b0cc45`. START requested consent, but the binding expired after ten minutes without an answer; no native invocation, lineage or mutation occurred. Returned continuation is restart-for-fresh-consent; old binding must not be replayed. Stop rather than repeatedly prompting an absent user. ASSESS remains unassessable due untracked declaration; independent verification completed. Prior candidate decline does not transfer. Global ignore hides module .gitignore; future authorized staging must include it explicitly. No native approval claimed.

GUI/full runtime schema/action dispatch, activation and live mutable-file behavior remain untested. Existing warnings persist; no full-system build claimed. Forecast 1,600–2,300 authored/moved lines plus vendored/generated content; retain tests, no minification. The user subsequently authorized one atomic delivery with an explicit size exception, as recorded below.

## Next

## Authorized delivery

User selected `authorize_atomic_zed_delivery`: commit the 25 scoped Zed files, create and mark the linked issue approved, create necessary labels, push `feat/zed-101-alignment` and open one PR with `type:feature` and `size:exception`. One slicing pass found coupled and individually oversized units; accepted total 6,689 changed lines (3,879 authored, 1,614 generated, 1,196 vendored). Keep `.pi/subagents.json`, both ODD documents, runtime `.updater.lock` and both pre-existing dirty locks out. Include module `.gitignore` explicitly despite global ignore. No activation or implicit native-review consent.

- [x] **D1 — Scope and delivery authorization.** Read-only delegated Astra map and parent ghp reads completed; no existing matching Zed issue or branch PR; main confirmed. status:approved/size:exception labels exist; type:feature must be created if still absent.
- [x] **D2 — Exact committed-lock verification.** Delegated Astra/high verified isolated HEAD plus exactly 25 approved overlays and committed locks. Unit, HM, updater/portability/module-contract/theme-migration, full treefmt, both-platform evaluation and offline verify passed. Unit/treefmt/theme-migration built freshly; other builds cached. Initial missing ambient python3 helper was replaced with shell copying; symlink-root verify attempt succeeded on physical-path retry. No source correction. Overlay manifest SHA256 `5cfe3f886a7adb0ac543021b6ef23ed17caf7e6144620e69e43c714450dab386`; complete candidate file manifest `ff74e3bb15eef527a5dd2dad39f6e2d917cc4b56836979140cb051403b0666f5`. Original HEAD/index/diff/status/locks/25 source hashes preserved. Exact numeric totals were not independently recounted in this round.
- [x] **R1 — Fresh native-review disposition.** Unavailable for committed range `ffdcda09164ceed782e889c36e268451ae9a9c6b..6d6efadb116b6d11febd1e24af123b2087078730`. START returned candidate-target-projection-drift, lineage_created=false, mutation_performed=false. Separate read-only diagnosis confirmed inspection represented only dirty locks, while all 25 committed/working blobs matched D2 manifest; index empty, original locks preserved. No source drift/remediation. ASSESS with nativeReviewOutcome=unavailable remains unassessable, requiring independent verification already satisfied by D2. No native approval, reset, recovery, alternate candidate or hook bypass.
- [x] **D3 — Commit, push and PR.** Published `6d6efadb116b6d11febd1e24af123b2087078730` (`feat(zed): add reviewed upstream snapshots and owned preferences`) normally to origin/feat/zed-101-alignment. Created and exact-readback confirmed approved issue https://github.com/aytordev/system/issues/206 and non-draft PR https://github.com/aytordev/system/pull/207 targeting main, closing #206, labels type:feature/size:exception. Created the missing type:feature label under user authorization. PR matches exactly 25 verified files, +6249/-440, correct remote HEAD/title/body/labels; mergeable. At publication main had advanced 10 unrelated commits, disclosed in PR; no rebase/force push/merge. Staged bytes matched D2; whitespace passed. Hooks passed conflict markers/deadnix/statix/treefmt/typos; eslint/luacheck skipped with no matching files. Last CI read: Linux/Darwin/expression checks in progress; label job succeeded. Local/remote HEAD match, index empty, excluded dirty-lock diff unchanged. Session routing and both ODD records remain local/untracked.

Delivery complete. Next is CI and human review of PR #207; do not merge or activate without separate authorization. Native review unavailable (not approved), GUI/full runtime/full-system verification not performed, and mutable-file migration remains separate. Original locks and session files remain local.
