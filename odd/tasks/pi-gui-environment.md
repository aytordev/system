# Feature: pi-gui-environment

## Authorization and baseline

User authorized source correction of Pen-hosted Gentle Pi executable discovery and selected strict TDD. No models/profiles, global PATH, signed Pen or canvas MCP changes. User subsequently authorized commit and push of the completed source change and evidence. No activation, app restart, PR or merge authorized. Branch `fix/pi-gui-environment`, clean starting main `d8e5c57de5a3041b3f02a091f32dc6b7cc3bbecc`.

Pen's observed GUI PATH excludes terminal Pi's profile. Supported `GENTLE_PI_AGENTS_PI` avoids ambient lookup. DeepSeek monthly-cap errors are separate; existing GLM writer and read-only Astra auditor succeeded without profile changes.

## Implemented design

Optional `aytordev.programs.terminal.tools.pi.guiEnvironment.enable` defaults off; publication requires Pi/opt-in/Darwin/HM launchd. Absolute executable derived from configurable package via `lib.getExe' cfg.package "pi"`; unsupported whitespace rejected. Civislend opts in.

GUI one-shot RunAtLoad LaunchAgent plus enabled activation reconciliation after setupLaunchAgents. Override only, never PATH. Isolated activation fragments, private atomic state recording with explicit error checks, conditional compensation, foreign override preservation/no adoption, exact-match disable cleanup. Bounded ownership-token lock without age-based takeover; abandoned locks require operator inspection. Cleanup reachable while Pi/option/launchd disabled. Dry-run inert. Comparisons cannot make external launchctl writes atomic.

Only future GUI processes can inherit this variable; launchctl getenv proves the launchd table, not existing Pen's environment. No ordering promise against restored login apps. Removing the module entirely is not automatic cleanup. All runtime tests use a stub, not live launchctl.

## Tasks

- [x] GUI-1: Add focused configuration test and observe intended missing-option RED. Route: bounded GLM writer.
- [x] GUI-2: Implement adapter, opt-in, lifecycle regressions, option contract/index and README; observe GREEN and compatibility checks. Route: same single bounded GLM writer. Source blockers corrected and independently rechecked.
- [x] GUI-3: Final independent source/evidence verification completed with Astra. Native review declined for this candidate; risk assessment unavailable, so independent verification was required and performed. Source outcome verified with limits below; runtime remains pending. Route: read-only Astra auditor plus native review preflight.

- [x] GUI-4: Commit the coherent source/test/docs work unit after explicit authorization. Commit `49d4dcf3458e582211e8943d21ca2785423be5fe`, `fix(pi): resolve subagent executable in GUI sessions`.
- [x] GUI-5: Push the feature branch after explicit authorization. `git push --set-upstream origin fix/pi-gui-environment` succeeded and created the remote branch.

Parent owns document, full mirror `odd/pi-gui-environment/tasks`, and todo. Multi-file delegation honored; initial worker timeout preserved partial writes. Scope is one behavior plus tests/docs, not a general framework. Source work unit: 1048 authored changed lines across seven files, including 675 test lines; kept tests/docs with the behavior rather than splitting by file type. No PR opened; PR slicing remains a separate decision.

## Verification evidence

Strict TDD explicitly enabled by user this session. Focused runner:
`nix build path:.#checks.aarch64-darwin.integration-pi-gui-environment --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link`.

Observed RED: missing guiEnvironment option; later regression REDs caught unchecked staging writes and unsafe lock takeover. Writer observed final focused GREEN (30 PASS branches) and post-format repeat GREEN. Writer commands also passed:
- integration-gentle-ai-engine and integration-docs-generation builds using same fixture/no-lock/no-link flags.
- `nix eval --raw path:.#checks.x86_64-linux.integration-pi-gui-environment.drvPath --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file`.
- Scoped nix fmt on Pi default/adapter, civislend home and the two check files; git diff --check clean.

Independent Astra source review found activation-aborting exits, manufactured ownership, unsafe state handling/lock takeover, missing activation retry, Linux/negative test weaknesses and inaccurate docs. Writer added regressions and corrected them. Final bounded recheck: prior blockers fixed, no residual severe defect within scoped review. Commands are attributed to writer, not auditor.

Covered guards/custom executable/GUI domain, inline activation sentinels, publication/update/disable, foreign-equal values, dry-run empty environment, repeated disable, injected launchctl/staging failures, compensation and concurrent/abandoned locks. Real rename-syscall failure not directly injected; concurrency test does not force every interleaving. Linux runtime not built on Darwin. Full production build/flake suite and live Pen verification not run.

## Remaining work and delivery

Native review: inspect included all seven source files (three explicitly selected new paths), excluding this task file. START consent was declined for this candidate; no lineage or review authority created and no native approval claimed. ASSESS with real writer profile nan/glm5.3-flash/high and explicit declined outcome was unassessable (untracked scope), requiring independent verifier; fresh Astra fallback audited all seven files and corroborated existing logs/artifacts without rerunning builds.

Final verification: focused derivation `/nix/store/43vcs7ihy326m547828vkd7vbxgscd48-pi-gui-environment.drv` has 30 PASS log lines; existing native ownership and docs-generation outputs/logs corroborated, golden byte-identical. Current seven files match recorded source snapshot. Exact final flake/derivation binding was not independently established for every historical cached command. Linux evaluation produced a drvPath, but wrapper's printed status was not independently reliable. No severe residual source blocker found; prior failures superseded by successful checks except explicitly untested rename syscall/concurrency/runtime limits.

Delivery: source commit `49d4dcf3458e582211e8943d21ca2785423be5fe` published to `origin/fix/pi-gui-environment`. Commit hooks passed conflict-marker, deadnix, statix, treefmt and typos checks; eslint/luacheck skipped because no applicable files. Committed-range risk assessment remained unavailable while this evidence file was still untracked; the same independently verified source candidate was not changed or implicitly approved. This task document is synchronized in a separate documentation commit after the source push.

Live activation and Pen inheritance/spawn verification remain separate user actions. Source changes alone do not fix an already-running app. Next: authorized activation for civislend, then relaunch GUI host and test actual subagent spawn. Source files are now tracked in Git; no system activation, app restart, PR or merge performed.
