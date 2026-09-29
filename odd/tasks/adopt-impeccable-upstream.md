# Adopt upstream Impeccable

This is the implementation-phase record. Later delivery authorization and commit evidence appear at the end; earlier authorization statements describe their original phase.

## Objective and authorization

Adopt the complete, unmodified upstream Impeccable Pi skill and compatible engine through Nix. Retire `aytordev-interface-design` and `aytordev-design-system`; preserve `aytordev-pen-ops` and unrelated skills. User authorized implementation and temporary GPT-6-Astra explorer/writer/verifier definitions, to be removed when finished. No activation, live-profile installation, commit, push, or PR is authorized.

No upstream frontmatter/reference rewrites, curated subset, imposed local metadata, updater wrapper, or local orchestrator. Native Gentle AI retains workflow ownership. Preserve historical fixtures, `oldNames`, task records and retired documentation as history.

## Identity and integration

- Branch: `feat/adopt-impeccable-upstream`; clean starting HEAD `279b94690970cb7520ec47ff253b5889064f1a45` on `main`.
- Skill: 4.4.0; `pbakaus/impeccable` commit `114ea1d3838fca73b253af45f873b9c4f5f213c8`.
- Source hash: `sha256-CGIBrg4dvbY592/BdgsjbNpNBTxvMRrjBAW4JumI5HM=`.
- Preserve 54 original payload files, including 42 references. Add only LICENSE, NOTICE.md, and the supported sibling engine path.
- Engine: official `engine-v0.1.6`; release commit `d446ed6411522d6379ea86a0cc3a0955bc1251b2`.
- Darwin asset SHA-256: `efa0860cce03382e4d384709529b9892eaaa20dd49c3e5fcf73e680abc6d7574`.
- Linux asset SHA-256: `19dbe233b82acb5d8b8ae2cb37621f23f950cba258cfc62313a3fa50e557930c`.
- Package-local fetching; no new flake input. Engine sibling path: `scripts/bin/{darwin-arm64,linux-x64}/impeccable`.
- Final collection: five authored local packages plus upstream `impeccable`. Local metadata contracts remain local-only. Neutral export and guarded recursive Pi file publication; no ownership of the whole Pi skills root.

## Routing, checks and delivery

All writers/verifiers use `openai-codex/gpt-6-astra`, high effort. Parent owns this file, Engram topic `odd/adopt-impeccable-upstream/tasks`, and visible tasks. One writer at a time.

**Strict TDD**, selected explicitly by the user in this session: intentional RED, implementation, GREEN, refactor. Runner: `nix build path:.#checks.aarch64-darwin.<check> --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`. `path:.` includes new files without staging. Linux evaluation is not Linux runtime verification.

RDD is on. Native consent/review remains parent-owned and never authorizes delivery. Commit evidence is pending explicit human authorization. Delivery strategy is ask-on-risk if/when a commit or PR is requested; no delivery currently authorized. Initial forecast: 200-400 additions plus 713 removed lines in 14 retired skill files and supporting edits; T1 actually added 290 lines. Do not vendor upstream or omit checks to reduce review size.

## Tasks

- [x] **T1 — Package faithful upstream bundle and engine.** Completed. Route: bounded writer plus independent verifier (multi-file write). Added the two packages and integration check, updated package docs. Intentional RED and final GREEN observed; package contents preserved, isolated sibling-engine selection verified. No commit authorized.
- [x] **T2 — Replace the two published design skills.** Completed. Route: bounded writer (multi-file write). Updated distributor, current inventories/dependency/publication/transition checks, docs and creator guidance; removed exactly the 14 approved source files. Historical fixtures and unrelated skills preserved. Three intentional RED checks followed by the full eight-target GREEN suite, including disabled/custom-root/retirement/foreign-file scenarios. No commit authorized.
- [x] **T3 — Verify, review, and clean up.** Completed with native review declined by the user. Independent Astra verifier passed all eight focused targets and all-system evaluation; parent structural readback completed. Native START created no lineage or mutation. Removed all three authorized temporary agent definitions and confirmed the original agent inventory. Activation and Linux runtime remain unperformed; no commit authorized.

## Acceptance criteria

1. Reproducible skill source and platform engine pins; all original upstream bytes unchanged.
2. Complete payload and license notices survive standalone copies; packaged engine does not require fallback download or ambient override.
3. Neutral/enabled-Pi publication contains exactly five retained local skills plus `impeccable`; disabled Pi emits no Pi paths.
4. Retired sources/managed links disappear without deleting historical records or foreign/native files.
5. Local metadata/dependency validation stays enforced without modifying upstream to satisfy it.
6. Recorded check results distinguish native Darwin execution, Linux evaluation/inspection, and untested Linux runtime.
7. No activation, installs into live profiles, upstream init/hooks/update, commits, or publication.

## Verification evidence

T1 exact commands, both final writer and independent verifier exit 0:

```sh
nix build path:.#checks.aarch64-darwin.integration-impeccable --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link
nix build path:.#packages.aarch64-darwin.impeccable-engine path:.#packages.aarch64-darwin.impeccable-skills --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link
git diff --check
```

- Intentional RED exited 1: `FAIL: pinned impeccable-engine and faithful impeccable-skills packages are required`.
- Final integration output: `/nix/store/7jhz9b56f5fmb2skj07zxcdzc1rzy7n2-impeccable-upstream-check`.
- Darwin engine: `/nix/store/bkcwjvprbn4jm0nvhqf18kyw42dfy3vf-impeccable-engine-0.1.6`.
- Skill output: `/nix/store/wgj3nry2vgplwii49iw1lcbfxqadndzz-impeccable-skills-4.4.0`.
- Native engine and isolated copy passed engine-probe. Both platform derivations evaluated. Linux binary inspected as static PIE, not executed. Darwin linkage: Security, CoreFoundation, libiconv, libSystem. `readelf` unavailable.
- Intermediate T1 test harness failures (foreign-platform fetching and read-only copied directories) were corrected before GREEN; transient SQLite-busy warning absent from final sequential runs.
- Independent verifier reran the exact commands using cached outputs; no blockers. RED was writer-observed, not independently replayed.
- Native assess after T1: unassessable because intended untracked files were not yet declared; writer profile recognized as large. Required independent verifier completed. No review lineage created.
- Parent structurally read all three new Nix files. `git diff --check` does not cover untracked files; focused Nix check covers their behavior and targeted formatter ran.

T2/T3 planned commands:

```sh
nix build path:.#checks.aarch64-darwin.unit-ai-tools-inventory path:.#checks.aarch64-darwin.unit-ai-tools-dependencies path:.#checks.aarch64-darwin.integration-ai-tools-skill-contract path:.#checks.aarch64-darwin.integration-ai-tools-docs-links path:.#checks.aarch64-darwin.integration-gentle-ai-engine path:.#checks.aarch64-darwin.integration-ai-skills-transition path:.#checks.aarch64-darwin.unit-input-policy --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link
nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file
```

## T2 evidence and final verification

- Three individual RED runs (inventory, publication, transition) exited 1 before implementation: five-local inventory mismatch, exact/custom-root publication mismatch, and missing upstream publication after historical migration.
- The three targets then passed together; after formatting, all eight focused checks (including upstream fidelity) exited 0. `git diff --check` passed.
- T2: 26 files, 254 additions / 792 deletions; 713 deleted lines are exactly the retired skill packages. Full source work comprises T1's 290 additions plus T2's changes.
- Publication checks compare every upstream file and standalone copy, verify offline sibling-engine selection, disabled/client/custom-root guards, and managed retirement with/without hm.old while preserving native/foreign replacements.
- Retired names remain only in retirement documentation, dedicated retirement fixtures and historical records, not active inventories.
- Initial deletion helper lacked host python3; scoped removal completed without environment installation. Live profiles untouched.
- Native INSPECT selected all four intended untracked paths and reports fresh-target-ready. ASSESS still returns unassessable for undeclared-untracked scope, so a separate Astra verifier is mandatory; no review lineage created.
- Parent read back the distributor and all three new Nix files.

## T3 outcome

- Independent Astra verifier: PASS, no source/documentation corrections required. Eight-target focused build exited 0 using existing store outputs; this rerun did not execute fresh builders.
- `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file` exited 0 with `all checks passed!`, including both supported platforms and production Darwin configuration evaluation. This is not a full system build or activation.
- `git diff --check` passed; verifier additionally read and whitespace-checked all untracked files. Expected fixture/no-lock, Firefox legacy-path, and nix-unit nested-input warnings were nonblocking.
- First native review consent expired without a lineage or mutation. A fresh START received user decline for target `sha256:5256d8828f61af9202b111a86a4eb8a913270d878a402c137f6126b36b2b86de`: `consent-declined-this-candidate`, medium native risk, 31 paths, 1421 diff lines at that snapshot. No lenses ran and no approved authority or receipt is claimed.
- Post-decline ASSESS again returned unassessable due to its untracked declaration requirement, selecting independent verification. The full-candidate Astra verification above satisfies that fallback; no code changed after it.
- All three temporary Astra definitions were reread, removed under the user's authorization, and confirmed absent through native agent inventory. Existing agents were untouched.
- Not executed: Linux runtime, live Pi/Pen discovery, browser operations, full production build, profile installation/activation, commits, pushes or PRs. Earlier intended TDD failures were followed by passing checks; no implementation check remains failing.
- Final bookkeeping updates affect only this passive task artifact and its Engram mirror, not the verified code.

## Next step

Review the working-tree diff, add the new files to Git when authorized, and activate the configuration only on an explicit request. The default Git-flake switch must not be used while the new package/check files remain untracked. Until activation and client reload, the live profile still exposes the old generation.

## Subsequent delivery authorization and evidence

The maintainer subsequently authorized atomic commits, push, one PR with a size exception, and an approved linked issue. Issue [#204](https://github.com/aytordev/system/issues/204) was created and its title, body and approval label read back successfully. The maintainer also explicitly approved the three delivery labels.

Implementation, tests and behavior documentation are committed together in `9d8f5c8eb55b4909e16cb2ba48af444e9d94a356` (`feat(ai-tools)!: adopt Impeccable with centralized ownership`), covering the adoption and the subsequent ownership refactor. This is the work-unit commit evidence for the completed implementation tasks. The two passive task records form a separate documentation commit.

Final Git-flake treefmt built successfully, eight focused checks passed using cached results, and staged whitespace checks passed. Commit hooks passed conflict-marker, deadnix, statix, treefmt and typo checks without bypass; eslint and luacheck had no applicable files. A preceding path-source treefmt attempt failed before formatting because the source snapshot carried a checkout Git hook into its builder. Normal Git source selection resolved that transport problem without changing source or disabling hooks.

The candidate-scoped native review decline is preserved; staging and committing unchanged source do not claim a new review or receipt. Temporary delivery agents were removed and the original inventory restored. Push/PR publication is the next delivery action; merge and activation remain unauthorized. Publication results are recorded by Git/GitHub and the session delivery summary.
