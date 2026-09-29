# Centralize AI skill ownership

This is the implementation-phase record. Later delivery authorization and commit evidence appear at the end; earlier authorization statements describe their original phase.

## Objective and authorization

Implement the user-approved ownership proposal: `modules/common/ai-tools/` owns skill definitions, update metadata, private preparation recipes, and publication. Keep `packages/impeccable-{engine,skills}/package.nix` as thin import adapters and checks under `checks/`. Do not change versions, upstream payloads, public package outputs, module options, or client publication behavior.

The prior adoption remains uncommitted on `feat/adopt-impeccable-upstream`, HEAD `279b94690970cb7520ec47ff253b5889064f1a45`. Preserve all its tracked/untracked changes and historical artifacts; this refactor builds on that working tree, not HEAD. Prior evidence: `odd/tasks/adopt-impeccable-upstream.md`.

User reauthorized three temporary global Astra agents for this refactor, with cleanup afterward. Use only `openai-codex/gpt-6-astra`, high effort. No staging, commits, pushes, activation, profile installation, new updater, runtime registry, discovery mechanism, or source vendoring is authorized.

## Design and scope

- Add pure-data `modules/common/ai-tools/catalog.nix` as the six-entry inventory and sole production authority for upstream pins/update relationships.
- Classify local, adapted, and intact upstream sources from recorded evidence. Historical comparison pins are not original-import or last-synchronized baselines. Keep local frontmatter/metadata and detailed provenance canonical; do not duplicate descriptions or fabricate provenance.
- Move Impeccable recipe bodies into `modules/common/ai-tools/upstream/impeccable/{engine,skill}.nix`, consuming catalog data without Home Manager/config dependencies.
- Keep direct-import package adapters to preserve `callPackage` argument introspection and existing package discovery.
- Derive publication sources from the catalog; preserve namespace, guards, neutral/Pi paths and file ownership.
- Update ownership/inventory tests and active authoring/docs guidance only. Keep independent test expectations rather than deriving every oracle from the implementation.
- Impeccable skill 4.4.0 at `114ea1d3838fca73b253af45f873b9c4f5f213c8`, engine 0.1.6, existing source/platform hashes and all 54 upstream files stay unchanged. Local creator guidance may change as part of the requested documentation correction.

## Tasks and routing

- [x] **T1 — Capture the pre-refactor baseline.** Completed by delegated Astra verifier. Both platforms' package/source identities captured and eight focused checks plus two Darwin package targets passed using cached outputs. No repository mutation.
- [x] **T2 — Centralize ownership with strict TDD.** Completed by one bounded Astra writer. Observed ownership RED/GREEN and a second structured-origin metadata RED/GREEN. Fourteen scoped files changed; eleven negative fixtures, exact baseline parity, scoped formatter, eight checks/two Darwin packages and all-system evaluation passed.
- [x] **T3 — Verify, review, and clean up.** Completed. Independent Astra verification passed without findings; native review was declined by the user for this candidate, creating no lineage. All three authorized temporary definitions were reread, removed, and confirmed absent; original agents preserved.

Mapping was delegated because understanding requires more than four files. It confirmed no changes to package loaders, overlays, Home module imports, historical records, or local metadata are necessary. Parent owns this document, Engram mirror `odd/centralize-ai-skill-ownership/tasks`, and todo projection.

## Verification contract

Strict TDD is ON, from the user's explicit selection earlier in this same session; no contrary setting was introduced. Exact runner: `nix build path:.#checks.aarch64-darwin.<check> --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.

Focused checks: `unit-ai-tools-inventory`, `unit-ai-tools-dependencies`, `integration-ai-tools-skill-contract`, `integration-ai-tools-docs-links`, `integration-impeccable`, `integration-gentle-ai-engine`, `integration-ai-skills-transition`, `unit-input-policy`. Build the two native Impeccable packages. Evaluate package/source drvPath/outPath/version for both platforms before and after; every identity must match. Final evaluation: `nix flake check path:. --all-systems --no-build --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`. Run scoped formatting in the writer and `git diff --check`; include untracked-source structural/whitespace verification. Never run a mutating formatter in a read-only verifier.

Normal Nix store/cache outputs are allowed; no result links or flake.lock mutation. Linux evaluation is not Linux runtime execution. No full production build or activation is planned.

## Review and delivery

Forecast incremental change: 435–595 added/deleted lines, including relocated recipes, tests and docs. One coherent ownership refactor; no artificial split or omitted tests to meet a line heuristic. Prior adoption diff is additional and must be distinguished. Delivery strategy: ask-on-risk if delivery is later requested. No commit authorized, so commit identities remain pending human authorization. Previous native review decline applied only to the adoption candidate, not this refactor.

## Evidence and next action

- Read-only Astra mapping completed; no source writes or builds performed by mapper.
- Parent confirmed actual model, branch, HEAD, existing dirty scope and prior task document/memory agreement.
- T1 evidence: session-local `before-full-{aarch64-darwin,x86_64-linux}.json` baseline reports. Explicit version/derivation/output fields and source identities read back successfully. Initial records used the special `outPath` field and serialized to strings; the corrected capture preserves every field. Initial files retained.
- Eight focused checks and two Darwin package targets exited 0 using cached store outputs; `git diff --check` passed and Git status was unchanged. Only fixture/no-lock warnings. This is not fresh runtime execution.
- Baseline skill source output: `/nix/store/7glly3m6vdnhyw25k0526a6gm0a29nrx-source`; Darwin outputs: `/nix/store/bkcwjvprbn4jm0nvhqf18kyw42dfy3vf-impeccable-engine-0.1.6`, `/nix/store/wgj3nry2vgplwii49iw1lcbfxqadndzz-impeccable-skills-4.4.0`; Linux outputs: `/nix/store/dzphqg50fcnihiv32d42blwq640ghc9a-impeccable-engine-0.1.6`, `/nix/store/hsn059rkaqwkagb190wjk5rzw6vm2mli-impeccable-skills-4.4.0`.
- T2 RED: `AI skill ownership requires a pure six-entry catalog`; later requirement-completion RED: `AI skill catalog ownership, structured origins/tracking, payload location, or pure-data shape drifted`. Both preceded their implementations and ended GREEN.
- Parent readback required structured origins/baselines/tracking, not only document links. Catalog now exposes known upstream relationships, honest unknown sync/import baselines and unconfigured tracking; recipes consume payload path and release-tag data. No update discovery was added.
- T2 final verification: exact baseline diff passed on both platforms; eight focused checks/two Darwin packages and final focused ownership rerun passed; all-system no-build evaluation reported `all checks passed!`; scoped formatter and `git diff --check` passed. Collection/Home fixtures/ownership/transition rebuilt; other outputs were cached.
- An optional Python hash-inspection invocation failed. Separate read-only diagnosis found shell Python available but unnecessary for the authorized commands. No retry, installation or environment change; required commands subsequently passed.
- Incremental change estimated at 700–800 added/deleted lines across fourteen source/test/doc files, including relocations and structured metadata coverage; not an exact count. This completes the approved ownership scope, not update automation. Prior adoption diff remains additional.
- Native ASSESS recognized the large Astra writer but could not assess undeclared-untracked scope; returned high-risk-equivalent independent-verifier plan. Independent T3 verification satisfied that plan; post-decline ASSESS returned the same requirement.
- Independent Astra verification: PASS, no blocking findings. Both-platform baseline comparison, eight checks/two Darwin package build request, all-system no-build evaluation, and `git diff --check` all exited 0. The independent build reused cached results, not fresh builders/runtime probes. All eight untracked files were read and separately inspected for whitespace/conflict markers. Before/after Git status was identical.
- Native INSPECT selected all eight intended untracked files. User declined the fresh candidate at START: `consent-declined-this-candidate`, target `sha256:84881e15c1fff8cd91b29992e2df66a3d8ae17cfb89c2edea9640002ae89b66e`, medium risk, 36 paths and 1905 changed lines including prior adoption. No lineage, mutation, lenses, approval or receipt. Candidate scope was explicitly explained before consent.
- Cleanup: only `astra-ai-skills-{explore,worker,verify}-temp.md` definitions were removed from the global agent directory after readback. Native inventory confirmed the preexisting agents unchanged.
- Not performed: Linux runtime, fresh independent Darwin runtime replay, full production build, live Pi/Pen/browser checks, activation, profile installation, staging, commits, push or PR. Expected fixture/no-lock, Firefox legacy-path and nix-unit deprecation warnings were nonblocking. No required implementation check remains failing.
- Only passive task bookkeeping changes follow verification; source remains unchanged. Next: review the uncommitted diff, track new files only when authorized, and activate only on explicit request. Default Git-flake activation cannot include still-untracked files. Automatic upstream detection remains a separate, unimplemented follow-up.

## Subsequent delivery authorization and evidence

The maintainer subsequently authorized atomic commits, push, one PR with a size exception, and an approved linked issue. Issue [#204](https://github.com/aytordev/system/issues/204) was created and its title, body and approval label read back successfully. The maintainer also explicitly approved the three delivery labels.

Implementation, tests and behavior documentation are committed together in `9d8f5c8eb55b4909e16cb2ba48af444e9d94a356` (`feat(ai-tools)!: adopt Impeccable with centralized ownership`), covering the adoption and this ownership refactor. This is the work-unit commit evidence for the completed implementation tasks. The two passive task records form a separate documentation commit.

Final Git-flake treefmt built successfully, eight focused checks passed using cached results, and staged whitespace checks passed. Commit hooks passed conflict-marker, deadnix, statix, treefmt and typo checks without bypass; eslint and luacheck had no applicable files. A preceding path-source treefmt attempt failed before formatting because the source snapshot carried a checkout Git hook into its builder. Normal Git source selection resolved that transport problem without changing source or disabling hooks.

The candidate-scoped native review decline is preserved; staging and committing unchanged source do not claim a new review or receipt. Temporary delivery agents were removed and the original inventory restored. Push/PR publication is the next delivery action; merge and activation remain unauthorized. Publication results are recorded by Git/GitHub and the session delivery summary.
