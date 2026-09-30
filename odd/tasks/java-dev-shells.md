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
