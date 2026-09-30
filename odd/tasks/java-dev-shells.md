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
