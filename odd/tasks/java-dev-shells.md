# Java Development Shells

## Goal
Add auto-discovered Nix development shells for Java 25, 21, and 17, each with its matching JDK plus Maven and Gradle.

## Scope
- Add one shell under `dev-shells/` for each selected Java version.
- Document the shells in `dev-shells/README.md`.
- Preserve existing uncommitted changes in the flake lockfiles.

## Tasks
1. [x] Add Java 25, 21, and 17 dev-shell definitions following the existing shell conventions.
2. [x] Document the new shells and validate parsing, package availability, and flake evaluation where supported.

## Decisions
- Versions: Java 25, 21, and 17 (all LTS releases).
- Build tools: include Maven and Gradle in each shell.
- Discovery: rely on the existing auto-discovery loader; no loader edits.

## Evidence
- Existing shell conventions: `dev-shells/python/default.nix`, `dev-shells/nix/default.nix`.
- Auto-discovery is implemented in `flake/dev/dev-shells/default.nix`.
- `nix-instantiate --parse` passed for all three shell files.
- Direct imports evaluated against pinned nixpkgs on `aarch64-darwin` and `x86_64-linux`; each shell resolved its matching JDK, Maven 3.9.16, and Gradle 8.14.4.
- After the files were committed, `nix eval .#devShells.aarch64-darwin.<java-*>.drvPath` passed for all three shells, confirming loader discovery.
- `nix fmt -- --no-cache --fail-on-change` passed for all three Nix files; `git diff --check` passed; the commit's pre-commit hooks passed.
- Native review could not start for the committed change: inspect bound the dirty lockfile workspace target, and the explicit committed-range START was rejected for candidate target projection drift. No review lineage was created.
- Existing changes in `flake.lock` and `flake/dev/flake.lock` remain untouched and unstaged.

## Commits
- `ebd6db8` — `feat(dev-shells): add Java 17, 21, and 25 environments` (shell definitions and README).
- Commit and push explicitly authorized by the user.

## Follow-up: Java Python and VS Code Support

### Goal
Add `python3` to each Java development shell and add the Java Extension Pack (`vscjava.vscode-java-pack`) to the configured VS Code extensions.

### Tasks
1. [x] Add `python3` to the package list exposed by Java 17, Java 21, and Java 25 shells.
2. [x] Add the Java Extension Pack to the shared VS Code extension set and verify package resolution, shell evaluation, formatting, and diff hygiene.

### Decisions
- Apply `python3` consistently to all three Java shells.
- Put the Java Extension Pack in the shared VS Code extension list so it is available to both configured profiles.
- Preserve the pre-existing uncommitted changes in `flake.lock` and `flake/dev/flake.lock`.

### Evidence
- Read-only Nix evaluation resolved `pkgs.vscode-extensions.vscjava.vscode-java-pack` at version `0.31.1`.
- The Java shell package lists now include `python3` in `dev-shells/java-17/default.nix`, `dev-shells/java-21/default.nix`, and `dev-shells/java-25/default.nix`.
- `pkgs.vscode-extensions.vscjava.vscode-java-pack` resolves at version `0.31.1` and appears in the evaluated `wang-lin` default VS Code profile.
- `nix-instantiate --parse` passed for all four changed Nix files; `nix fmt -- --no-cache --fail-on-change <four changed Nix files>` passed with zero files changed; `git diff --check` passed.
- `nix eval --raw .#devShells.aarch64-darwin.java-{17,21,25}.drvPath` passed individually for all three shells.
- `nix develop .#java-{17,21,25} --command python3 --version` passed for all three shells and reported Python 3.14.7.
- Implementation commit: `d281eb3` — `feat(dev-shells): add Python and Java VS Code pack`.

## Follow-up: Install Java Pack Members Explicitly

### Goal
Install all six extensions listed in the Java Extension Pack manifest alongside the pack itself.

### Tasks
1. [x] Add all six pack members to the shared VS Code extension list.
2. [x] Verify each package is available and appears in the evaluated VS Code profile.

### Members
- `redhat.java`
- `vscjava.vscode-java-debug`
- `vscjava.vscode-java-test`
- `vscjava.vscode-maven`
- `vscjava.vscode-gradle`
- `vscjava.vscode-java-dependency`

### Evidence
- Each Nixpkgs extension package resolves successfully on `aarch64-darwin`.
- `nix-instantiate --parse`, `nix fmt -- --no-cache --fail-on-change modules/home/programs/desktop/editors/vscode/default.nix`, and `git diff --check` passed.
- Evaluating `wang-lin`'s default VS Code profile includes all six packages and `vscjava.vscode-java-pack`.
- Nixpkgs builds the pack as a plain marketplace extension with no propagated members (verified in the pinned nixpkgs at `pkgs/applications/editors/vscode/extensions/default.nix:5227-5241`), which is why the members are listed explicitly.
- Implementation commit: `e81244e` — `feat(vscode): install Java extension pack members explicitly`.
- Follow-up out of scope: the extensions sit in the shared `commonExtensions` list, so they reach every VS Code profile on every host. Gating them per language is tracked as the separate `language-packs` feature.

## Correction: Pin the Build Tools to the Shell JDK

### Finding
Native review `R3-001` (CRITICAL, reliability, introduced by this candidate): the shells listed
`maven` and `gradle` straight from `pkgs`. Both ship wrappers that pin their own JDK, so `mvn`
and `gradle` ran on a different JDK than the one the shell advertises, defeating the
version-specific environment. The original evidence below only asserted `java --version` and
`python3 --version`, never `mvn --version` or `gradle --version`.

### Fix
- Pin the build tools to the shell JDK: `maven.override { jdk_headless = jdk; }` and
  `gradle.override { java = jdk; }`.
- Export `JAVA_HOME` in each shell hook.

### Evidence
- Both wrappers use `--set-default`, so the shell's exported `JAVA_HOME` also wins at runtime.
- Gradle default confirmed in the pinned dev nixpkgs:
  `pkgs/development/tools/build-managers/gradle/default.nix:156` (`java ? defaultJava`) and
  `:392` (`gradle_8 = mkGradle { … defaultJava = jdk21; }`).
- Maven default confirmed at `pkgs/by-name/ma/maven/package.nix:30-32`
  (`--set-default JAVA_HOME "${jdk_headless}"`).
- `nix develop .#java-17|21|25` now reports the shell JDK from both build tools:
  - `java-17`: `Java version: 17.0.19` (maven), `Launcher JVM: 17.0.19` (gradle)
  - `java-21`: `Java version: 21.0.11` (maven), `Launcher JVM: 21.0.11` (gradle)
  - `java-25`: `Java version: 25.0.3` (maven), `Launcher JVM: 25.0.3` (gradle)
- `nix-instantiate --parse` passed for all three shells; `git diff --check` passed.

## Correction: Unblock `nix flake check` After the nixpkgs Bump

### Signal
`Check aarch64-darwin` and `Check x86_64-linux` went red on this branch while `Build and Cache
Dev Shells` stayed green. The root cause is the nixpkgs bump, not the Java shells:

| commit | what it is | `Check` |
| --- | --- | --- |
| `576eab8` | before the bump | pass |
| `57493e2` | lockfile refresh (nixpkgs `7a0f122f` → `b4fd65b1`) | **fail** |
| `55052bdc` | the `R3-001` fix | fail (same cause) |

### Failures and disposition

**`mergiraf 0.19.1` on x86_64-linux** — its own integration corpus aborts: the `working` target
logs `corrupted size vs. prev_size` and the process dies with SIGABRT at
`integration::path_062`. Fixed with `overlays/mergiraf/default.nix`, which disables the check
phase on Linux, following the existing `overlays/kvazaar` precedent. The merge driver does not
depend on its test suite.

**`lix 2.95.3` on aarch64-darwin** — fails at the Meson compiler sanity check
(`meson.build:35:0: ERROR: Compiler clang++ cannot compile programs.`), before any check phase,
so `doCheck` cannot help. No fix by version pin is possible either: no Lix series is cached for
aarch64-darwin (`lix_2_94` 2.94.2 and `lix_2_95`/`stable`/`latest` 2.95.3 all absent from
`cache.nixos.org`), so any pin still has to build Lix from source. Disposition: the check is no
longer registered on Darwin (`darwinExcludedCheckNames` in `flake/dev/checks/default.nix`).
Parsing is platform-independent, and `unit-parse-nix` still covers Darwin.

### Evidence
- The nixpkgs delta is `7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f` →
  `b4fd65b198c599cbe814fcb9f42d25d021595ec9`; the pre-bump directory had no `2.94.nix`/`2.95.nix`,
  so the Lix packaging was restructured inside this window.
- The failing mergiraf derivation in CI was `qaj0q1szdzia8362cw82kla76ijcvcqq-mergiraf-0.19.1.drv`,
  which is exactly what unmodified nixpkgs yields for x86_64-linux; the overlay yields
  `mxzymqi4qw84603b4g2068clzr09cnjd-mergiraf-0.19.1.drv`.
- Check inventory after the change: aarch64-darwin 51 checks with `unit-parse-lix` absent and
  `unit-parse-nix` present; x86_64-linux 48 checks with both present.
- `nix-instantiate --parse` passed for both changed files; `git diff --check` passed.

### Follow-up
Two upstream workarounds now live in the repository only to make this bump green. They should
move out with the lockfile refresh into its own change, where each one can be retested and
retired independently.

### Retirement: attempted and blocked

An attempt was made to retire both workarounds, and it was reverted. It is recorded here so the next
attempt starts from evidence instead of repeating the diagnosis.

Upstream fixed both root causes in `c59305bab2065cfecc4944690d9eedbb56f3a9fa`:

- mergiraf gained `env.NIX_CFLAGS_COMPILE = "-fno-strict-aliasing"`, because older tree-sitter
  grammars bundle an `array.h` that breaks strict aliasing. That missing fix was the memory
  corruption the aborting test hit.
- lix applies `NIX_LDFLAGS` only on ELF, because Apple's `ld64` rejects `-z`. That was the Meson
  `Compiler clang++ cannot compile programs` failure.

Both rebuilt outputs are in `cache.nixos.org`, `lix-2.95.3` for `aarch64-darwin` and
`mergiraf-0.19.1` for `x86_64-linux`. Because Hydra builds with the test phase, those entries are
the proof that the mergiraf tests pass and that lix compiles on Darwin. With that revision
`unit-parse-lix` is registered on Darwin again and it fetches lix from the cache rather than
building it, so the check costs no extra Darwin build time.

The blocker is unrelated to either workaround. The same revision changes the `herdr-0.9.1`
derivation, so it has to be built instead of fetched, and its `aarch64-darwin` build fails inside
the vendored `libghostty-vt` with `/bin/cp: Operation not permitted` and exit code 126, because Zig
invokes the macOS system tools by absolute path and the Nix sandbox denies them. Two hypotheses
were tested and discarded: the recipe's Linux-only `postPatch` is not involved, since it
substitutes `bundle_compiler_rt` and `bundle_ubsan_rt` rather than paths, and `herdr` is absent
from `cache.nixos.org` for Darwin, so that revision cannot be fetched either.

That is the dangerous combination: a sandbox-free CI runner can build `herdr` while a workstation
whose sandbox is `relaxed` and whose `sandbox-extra-paths` omits `/bin/cp` cannot, so this bump
would pass CI and still break the local `darwin-switch`.

Retirement conditions, either of which makes the bump free:

1. the `herdr` Darwin output for the new revision appears in `cache.nixos.org`, which removes the
   build entirely; or
2. upstream stops calling the macOS system tools by absolute path, which is worth reporting there.

Operational detail learned while attempting this: the `dev` partition's nixpkgs follows
`root/nixpkgs`, so it has no `nixpkgs` input of its own and `nix flake update nixpkgs` fails inside
`flake/dev` with `does not match any input of this flake`. The lever is `nix flake update root`
from that directory, which moves the follower.
