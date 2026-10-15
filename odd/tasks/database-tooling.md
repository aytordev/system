# Database tooling

## Intent and scope

Provide reproducible OSS-first SQL/NoSQL client tooling for the Civislend work home. Keep the existing flake, nix-darwin and Home Manager architecture. CLI tools are the automation interface; rainfrog is SQL-only interactive convenience; DbGate is the single graphical SQL/MongoDB/Redis convenience tool.

No database connections, credentials, secrets migrations, server services, destructive automation, unrelated refactors, global runtimes, activation or application restarts. The user subsequently authorized publishing only the existing DB-1 commit and opening one draft PR. Merge, activation and restarts remain unauthorized.

## Accepted decisions

- Isolated worktree: `../system-database-tooling`, branch `feat/database-tooling`.
- Base: `384e7d9cec9da0faba9b6a7867fb6803a566ad35` (fetched main; PR #219 had already been merged externally).
- User explicitly approved DbGate fallback, strict TDD and local work-unit commits.
- The user accepted a single 402-line draft PR with `size:exception`, a new approved tracking issue, `type:feature`, and publication of only `e548f029`; no new commits or native review mutations.
- Pinned nixpkgs: `7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f`; primary platform `aarch64-darwin`.
- QoreDB is absent from this pin. Its Apache-2.0 core/BUSL premium macOS app could be repackaged, but an existing nixpkgs DbGate package avoids local packaging maintenance. DbGate 7.2.4's release has a non-premium universal macOS artifact and separate premium artifacts; upstream GPL-3.0 conflicts with this pin's MIT metadata, but both are OSS. Do not fix that unrelated upstream metadata here.
- New database suite owns CLI package policy; separate rainfrog and DbGate capabilities compose with `mkDefault`. Enable only the work home. GUI/TUI overrides must not remove CLI tools.
- MariaDB has a real client-only derivation. PostgreSQL and Redis do not have client outputs; use a small `buildEnv` executable projection, not an overlay or custom source build. Only requested commands enter the profile; upstream server outputs can remain in the Nix store closure. Never describe the projection as a server-free build/closure.
- Use the current stable pinned PostgreSQL default, MariaDB client, SQLite bin output, DuckDB CLI output, Redis CLI and mongosh; confirm realized executable layout before claiming success.

## Execution contract

- Workflow: ODD, delegated direct; one writer, sequential tasks.
- TDD: **strict**, source: explicit user choice in this conversation.
- Exact focused runner: `nix build path:.#checks.aarch64-darwin.integration-database-tooling --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.
- RED must be an observed missing-option/behavior failure, not a parser/environment failure. Implement only after RED; then GREEN and scoped refactor/recheck.
- All Nix host/check evaluations substitute fixture secrets and do not modify lockfiles. No connection to any database.
- Route: mapping delegated (4+ files); implementation delegated (multiple nontrivial files); foreground writer checks are the record, plus independent command verification when required by native assessment or incomplete review.
- Delivery: `exception-ok`, explicitly accepted for 402 total changed lines (397 excluding generated golden headers). One cohesive source/test/docs slice, with no history rewriting or code compression.
- RDD is enabled. Native review applies to a work-unit commit/explicit bounded slice, never a TODO checkbox. Preserve unrelated existing review authority; use the selected worktree and exact native bindings. Approval is not assumed from checks.

## Tasks

- [x] **DB-1 — Implement and document the client stack with focused regression coverage.** Status: complete; local commit `e548f02945173c772b1a87d258174a7d872f29f4`. Add independent rainfrog/DbGate capabilities, database suite, work-home opt-in, module-contract registration and option golden update. Cover disabled suite, enabled composition, independent GUI/TUI opt-outs, exact requested CLI commands and absence of server executables/services. Follow strict RED/GREEN; run focused check, module contract, docs generation and scoped formatting. Document tools and client/closure/security limits in the existing README. Close with a local Conventional Commit after checks.
- [ ] **DB-2 — Verify platform composition, realized executables and review evidence.** Status: partial — functional verification passed; native reviewer output and final evidence commit are blocked. Evaluate the complete flake for supported systems with fixture secrets, confirm work-home/owner-home selection, verify command versions without DB connections and macOS `.app` version/arm64 architecture without launching it, run applicable integration checks and independently spot-check recorded evidence. Record every failed/skipped/pending check and native candidate disposition. Close the evidence with a local Conventional Commit; no push/PR/activation.

- [x] **DB-3 — Publish the approved draft PR.** Status: complete; issue #220 and draft PR #221 confirmed by exact-body readback; published only commit `e548f029`. Create and read back a non-duplicate feature issue with `status:approved`; push only the frozen DB-1 commit and open/read back a draft PR to main with `type:feature` and `size:exception`. Disclose recorded checks, package discrepancies and pending native review. Preserve HEAD, index, frozen candidate, uncommitted progress, and DB-2's partial state. No new commit, merge, activation or restart.

## Acceptance checks

1. `psql`, `pg_dump`, `pg_restore`, `mysql`, `mysqldump`, `sqlite3`, `duckdb`, `redis-cli`, `mongosh` and `rainfrog` resolve on Apple Silicon.
2. PostgreSQL/Redis server commands are absent from the projected user toolchain; no database daemon/service is enabled.
3. DbGate is the existing nixpkgs non-premium macOS app; bundle version and arm64 slice verified, not merely metadata.
4. Only Civislend opts into the suite; disabling rainfrog/DbGate preserves CLI tooling.
5. No secrets/connections, insecure-package exemptions, overlay, custom application derivation or unrelated configuration changes.
6. Focused checks and applicable evaluation pass, or limits are explicitly reported without a completion claim for blocked checks.

## Evidence

- Read-only mapping and package evaluation completed before source writes; no prior builds claimed.
- Package metadata/source inventory and primary upstream license/driver/release evidence recorded under `database-tooling/package-feasibility` and `database-tooling/implementation-scope`.
- Main checkout remains on `fix/pi-gui-environment`, clean; this feature uses the approved separate worktree.
- DB-1 observed missing-option RED, then GREEN and post-format GREEN. Focused database-tooling, module-contract and docs-generation checks pass. Separate GUI-only and TUI-only opt-out fixtures also pass.
- The focused derivation executed nine client version commands and rainfrog without connections, verified the exact nine projected binaries/no server commands, and inspected DbGate 7.2.4's universal arm64 bundle without launching it.
- Runtime caveat: nixpkgs labels mongosh 2.11.1, but its realized shell reports 2.10.0; do not claim the package label is the runtime version.
- DB-1 work-unit commit: `e548f02945173c772b1a87d258174a7d872f29f4` (402 changed lines; 397 excluding generated golden headers). DB-2 evidence commit pending.
- Initial unstaged assessment was unassessable because new files were undeclared; it returned a high-risk verification plan requiring an independent verifier. Source files were subsequently staged explicitly and committed. Inspect on the staged scope was ready, with no existing authority in this worktree; no review was started.
- DB-2 independent full evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file` passed (54 Darwin and 50 Linux checks evaluated; Linux runtime not built).
- Independent database-tooling spot build passed. Current-tree module-contract, docs-generation, home-portability and `unit-architecture-layers` checks all built with exit 0. An initial command guessed `integration-architecture-layers`; it failed identically on base and was corrected without source changes. No remaining functional check failure.
- Real homes independently evaluated: Civislend suite/rainfrog/DbGate true; owner all false with zero client toolchains. The nine realized CLI versions and rainfrog were rerun from Nix store paths in a temporary HOME; DbGate 7.2.4 plist/universal arm64 inspected without launch. No database connections, activation, full production build or Linux runtime build.
- Committed ASSESS returned schema-incompatible/unassessable; its required independent verifier completed the checks above. A first START consent expired before any lineage/mutation; the provider offered a fresh START, which received fresh consent.
- Active native review: `review-d11b28969993d737`, target `sha256:5aa2f7819a593d598ca9db056516bcdf6b96d9e89cc3ff549f29e197a62fef4d`, medium, one reliability lens, frozen commit `e548f029` / tree `801171b852ae1330c05f90c6840cecd785ff9701` against base tree `835a693444e519da2ece49963fccbaebaf10b056`.
- One reviewer run failed with empty output and `stopReason: length` (209712 ms, not timed out, no admitted result/mutation). Fresh bound STATUS remains reviewing/collect. No automatic retry, verdict, acknowledgement or approval.
- DB-2 remains partial. Progress-only changes in this document intentionally remain uncommitted so HEAD/frozen committed range stay unchanged; do not create the evidence commit while this review is pending.
- DB-3: approved issue https://github.com/aytordev/system/issues/220 (`enhancement`, `status:approved`); draft PR https://github.com/aytordev/system/pull/221 (`type:feature`, `size:exception`), main base, nine files / 402 changed lines. Exact title/body/state/labels/issue linkage and remote head matched `e548f029`; no new commit or history change.
- Publication preserves native review as pending, with no verdict/acknowledgement/approval. Final Git proof: HEAD `e548f029`, tree `801171b852ae1330c05f90c6840cecd785ff9701`, clean index, only this progress document dirty; original worktree clean.
- Historical publication CI readback: formatting and labeler succeeded; Darwin/Linux jobs were still in progress. Initial private-body preparation failed before any issue create call because python3 could not execute; read-only incident diagnosis confirmed usable Node, then exactly one actual issue and PR create attempt each succeeded; temporary files were cleaned.
- User requested continuation. All four PR #221 checks now report SUCCESS. Independent read-only verification corroborated Check run `36980137316`: `nix flake check --override-input secrets path:./checks/fixtures/secrets --accept-flake-config`, without `--no-build`. Both Linux and Darwin freshly built `integration-database-tooling`; their logs end with all checks passed. This adds Linux runtime check evidence to the earlier local evaluation-only record; it does not prove activation or a full production system build.
- CI checked out synthetic merge commit `84e1b1436a6ecf61d98cac50e71c5b562d39d243`, not HEAD. GitHub commit metadata independently confirms its tree is exactly `801171b852ae1330c05f90c6840cecd785ff9701`, matching the frozen candidate/HEAD tree.
- Read-only runtime diagnosis: `lib/inprocess-reviewer.ts` refuses completed responses containing no text parts; the host relay maps this to `reviewer-empty-output`. The completion options do not explicitly set an output-token cap. `length` is a truncation stop, not the distinct timeout failure. Exact token usage/reasoning split is unavailable; reasoning-budget exhaustion is a hypothesis, not an established cause.
- Current user-owned `review-reliability` routing is `nan/deepseek-v4-flash`, thinking `high`, in the routing-only `~/.pi/gentle-ai/models.json`. The host capture reads this routing entry, not the compatibility agent Markdown frontmatter. Current configuration is not a persisted per-run selection/usage record. No model/profile changes were made.
- The first read-only diagnosis scout stalled after grep and timed out; separate bounded verification supplied the diagnosis. This scout failure is distinct from the native review refusal.
- After fresh bound STATUS and the one-model forecast, exactly one controlled native retry again returned empty output with `stopReason: length`, elapsed `161324` ms, `timed_out: false`, `mutation_performed: false`. Fresh bound STATUS still reports the same target/tree, `reviewing/collect`, no admitted result or approval. No further retry, reset, recovery, acknowledgement, new commit/push, PR state change, merge, activation or application launch.

## Next step

Keep DB-2 partial and the PR in draft. Do not repeat an unchanged capture automatically. A possible diagnostic experiment is to keep the selected model and temporarily lower only `review-reliability` thinking from high to medium for one run, then restore high; this is not a proven fix and requires fresh explicit user authorization because the routing store is global. Otherwise preserve the pending review unchanged. Any authorized capture must first read fresh bound STATUS and use only its exact offered binding. Keep the progress evidence uncommitted while review remains pending; no merge, activation or restart.
