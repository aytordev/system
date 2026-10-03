# Database tooling

## Intent and scope

Provide reproducible OSS-first SQL/NoSQL client tooling for the Civislend work home. Keep the existing flake, nix-darwin and Home Manager architecture. CLI tools are the automation interface; rainfrog is SQL-only interactive convenience; DbGate is the single graphical SQL/MongoDB/Redis convenience tool.

No database connections, credentials, secrets migrations, server services, destructive automation, unrelated refactors, global runtimes, activation or application restarts. Push and PR creation are not authorized.

## Accepted decisions

- Isolated worktree: `../system-database-tooling`, branch `feat/database-tooling`.
- Base: `384e7d9cec9da0faba9b6a7867fb6803a566ad35` (fetched main; PR #219 had already been merged externally).
- User explicitly approved DbGate fallback, strict TDD and local work-unit commits.
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
- Delivery: `ask-on-risk`; forecast about 300 authored changed lines (excluding generated golden index), one coherent PR-sized slice. If materially larger, reassess before committing; do not compress code/tests.
- RDD is enabled. Native review applies to a work-unit commit/explicit bounded slice, never a TODO checkbox. Preserve unrelated existing review authority; use the selected worktree and exact native bindings. Approval is not assumed from checks.

## Tasks

- [ ] **DB-1 — Implement and document the client stack with focused regression coverage.** Status: in progress. Add independent rainfrog/DbGate capabilities, database suite, work-home opt-in, module-contract registration and option golden update. Cover disabled suite, enabled composition, independent GUI/TUI opt-outs, exact requested CLI commands and absence of server executables/services. Follow strict RED/GREEN; run focused check, module contract, docs generation and scoped formatting. Document tools and client/closure/security limits in the existing README. Close with a local Conventional Commit after checks.
- [ ] **DB-2 — Verify platform composition, realized executables and review evidence.** Status: pending. Evaluate the complete flake for supported systems with fixture secrets, confirm work-home/owner-home selection, verify command versions without DB connections and macOS `.app` version/arm64 architecture without launching it, run applicable integration checks and independently spot-check recorded evidence. Record every failed/skipped/pending check and native candidate disposition. Close the evidence with a local Conventional Commit; no push/PR/activation.

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
- Work-unit commits: pending.
- Native risk/review outcome for this candidate: pending, not inherited from the Pi feature.

## Next step

Delegate DB-1 in the approved worktree with exact source surfaces and the strict focused runner.
