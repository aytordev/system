# Zed 101 alignment

## Intent and constraints

Adapt jellydn/zed-101-setup at `aab371cdb1118b2da74c1d75e2bd822c77d2523f` with Astra to `modules/home/programs/desktop/editors/zed/`, with focused tests/docs. Preserve Sora/Kanagawa, fonts, telemetry opt-out, enable/package contracts and global Neovim ownership. Keep HM mutable merging and live customizations; no activation. Use native search instead of unprovisioned codemux/fff-gpui. No Ollama, ACP/MCP services, external AI accounts or permissive grants.

User authorized local Astra routing and strict TDD. Pre-existing dirty lockfiles preserved. No commits, push, PR or activation authorized/performed. Branch: `feat/zed-101-alignment`; HEAD: `ffdcda09164ceed782e889c36e268451ae9a9c6b`. ODD, no SDD. Delivery: ask-on-risk; approximately 758 changed lines for module/tests/docs, exceeding the 400–650 forecast to retain meaningful tests/docs. Commit/slice creation awaits authorization; commit evidence: none.

## Tasks

- [x] **T1 — Configure local Astra routing.** Inline mechanical configuration; `.pi/subagents.json` routes writer/verifier to `openai-codex/gpt-6-astra`, high. Globals unchanged; runtime identities observed.
- [x] **T2 — Implement with strict TDD.** Delegated writer (multi-file/preparation triggers). Changed default.nix/keymaps.nix; added README.md/LICENSE.upstream and tests/apps/zed-settings.nix. Modern settings, native search, safe agent defaults, language configuration, package-derived EDITOR, guarded shortcuts and attribution. Theme adapter/public options unchanged.
- [x] **T3 — Verify and resolve review disposition.** Independent Astra verifier passed focused checks and both-platform evaluation. Native review explicitly declined for this candidate; no lineage created. Required fallback independent verification completed; no review approval claimed.

## Evidence

Strict TDD source: explicit user session choice. Exact RED/GREEN runner:
`nix build --no-link --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets 'path:.#checks.aarch64-darwin.unit-nix-unit'`.

- Fourteen new tests. Main RED: 366/378 successful, 12 intended failures before implementation. GREEN: 378 successful.
- Compatibility follow-up RED: 377/378 successful for old prediction/file-finder keys. GREEN: 378 successful with modern keys and legacy-key absence assertions.
- Independent unit build passed; its output did not repeat the writer-observed test count.
- Home portability, module-contract and theme-migration builds passed in writer and verifier runs.
- Scoped formatting check passed with zero changes; three Nix files processed. README formatting was not established by that formatter. Scoped tracked diff whitespace check passed; untracked files were inspected separately.
- `nix flake check --no-build --all-systems --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets path:.` passed for aarch64-darwin and x86_64-linux. Evaluation only, not builds of every check or host system; platform-specific skips remain skips.
- Original lockfile diff SHA256 unchanged: `a67bb493d7a8137ba15f2301540f4f92c2d6dc9e99e1581dec698324882202a0`.
- Native START classified the full ambient candidate medium (8 files, 854 lines, including pre-existing locks). User declined; no mutation/lineage. ASSESS remained unassessable because its untracked declaration was unavailable, so the high-risk fallback of writer checks plus independent verification was followed.
- No unresolved automated check failures. Existing warnings: nested nativeBuildInputs, Linux Firefox legacy configPath; fixture lock-write warning expected. Initial cache timeout recovered.

## Decisions and limits

Symbol search moved to `space s s/S` to preserve Sneak; panel/model actions remain in native contexts. Source revision, exclusions, MIT attribution, prerequisites and manual checks are documented in the module README.

HM mutable merges retain removed settings, old contexts and pre-existing permissions. New emitted defaults are not a cleanup or runtime sandbox. No live-file edits, activation, GUI/schema/dispatch test, full system build or real language-server/AI invocation was performed. Pure tests use synthetic module sinks; they do not prove HM merge behavior. Official Zed v1.21.0 defaults/keymaps informed compatibility, supplemented by cached 1.19.2 action evidence.

## Next step

User reviews the diff and mutable-file migration notes, then separately authorizes activation if desired. Complete README GUI checks after activation. Commits and publication remain separate decisions.
