# Language Packs

## Goal

Make language support a first-class, per-host choice. One flag enables a language and
everything that follows from it: the toolchain, the editor extensions, and the editor and
shell settings that language needs. Today each new language is paid for by editing the editor
module, and its content leaks into every profile on every host.

Driving problem, from `odd/tasks/java-dev-shells.md`: the Java Extension Pack and its six
members sit in VS Code's shared `commonExtensions` list
(`modules/home/programs/desktop/editors/vscode/default.nix:197-209`), so they reach all
profiles on all hosts with no way to opt out.

## Scope

- A pure-data language catalog, shared by the Home modules and by the dev-shell partition.
- Home modules that expose `aytordev.languages.<lang>` with `enable` and a version selector.
- The editor seams a language pack needs, so packs never edit the editor modules.
- Dev shells that read the same catalog, keeping their public names unchanged.
- Migration of the existing `aytordev.suites.development.nixEnable` into the catalog.
- A verification check for the new class, plus regenerated docs golden.

## Non-goals

- Rust. With `pkgs.cargo` there is no version axis and no `rust-toolchain.toml` support, and
  `flake.nix` has no `rust-overlay`/`fenix`/`oxalica` input. It enters when that input is
  decided, in its own change.
- Editor support beyond VS Code and Zed. Neovim delegates all language configuration to the
  external `aytordev-nvim` input.
- Gating the repository's own contributor tooling (`nixpkgs-fmt`, `statix`, `deadnix` in every
  dev shell) by language. That is substrate, not a per-host language choice.

## Decisions

- **Catalog location: `modules/common/languages/`**, not `libraries/`. `libraries/` is the
  public `flake.lib` surface with its own golden check (`checks/library-exports`), and the
  catalog is configuration data, not a library function. The repository already has the exact
  precedent: `modules/common/ai-tools/` holds `catalog.nix` and `ai-skills.nix`, has **no**
  `default.nix`, and is imported as a plain file from other partitions
  (`checks/impeccable/default.nix:21`, `libraries/system/common/default.nix:12`).
- **No `default.nix` in the catalog directory.** That is what keeps it out of module
  discovery. Data files only.
- **Packs live in `modules/home/languages/<lang>/default.nix`** because they fan out to
  `programs.vscode`, `programs.zed-editor` and `home.packages`, which is Home Manager scope.
  `modules/common` is system scope today: its modules are pulled in explicitly by the Darwin
  modules via `lib.getFile`.
- **The catalog is a function of `pkgs`** so one definition serves both lockfiles: the root
  flake and the separate `dev` partition.
- **v1 languages: java, python, node, go, and nix.** Nix is not a language like the others:
  the catalog entry covers Nix as a *development toolchain* (LSP, formatter, linter, tree-sitter
  grammar, editor extensions). Nix as the substrate this configuration is written in is
  foundational and not gateable.
- **`aytordev.languages.nix` replaces `aytordev.suites.development.nixEnable`.** One API for
  one intent; the suite flag is migrated, not kept alongside.
- **Dev shells consume the catalog; they do not activate it.** A dev shell is an ephemeral
  environment entered with `nix develop`, not an installed artifact. Enabling a language must
  never promise a dev shell.
- **Editor modules own their profile names.** A pack writes to
  `aytordev.programs.desktop.editors.vscode.extraExtensions` and never needs to know that the
  module has a `default` and a `Nix` profile.

## Tasks

1. [x] Adopt the language pack class in an ADR, and reference it from the relevant
       `AGENTS.md`/`README.md` so the protocol is discoverable next to the code.
2. [x] Build the catalog in `modules/common/languages/` with Java as the pilot, plus unit
       tests for the catalog shape.
3. [ ] Add the editor seams: VS Code `extraExtensions`/`extraSettings`, Zed
       `extraLanguages`/`extraExtensions`, and align `checks/home-zed`.
4. [ ] Add the Java pack and migrate the Java extensions out of `commonExtensions`.
5. [ ] Add the remaining v1 languages and migrate `suites.development.nixEnable` to
       `aytordev.languages.nix`.
6. [ ] Rewire `dev-shells/*` to the catalog, preserving the public `.#<name>` attributes.
7. [ ] Add `checks/language-packs`, regenerate the docs golden, and update README/AGENTS.

## Constraints

- `mkForce` is rejected in suites and archetypes by `checks/architecture-layers/default.nix:66-84`.
- Every new `aytordev.*` option drifts `checks/docs-generation/golden/home.txt`; regenerate with
  `just golden-update`.
- `checks/module-contract` asserts that each listed package-owning capability exposes a
  singular `package`. A language pack owns a *set* of packages, so the ADR must state the
  exemption explicitly rather than let the check imply it.
- Dev-shell public names are consumed by `.github/workflows/build-dev-shells.yml:60` and
  `Justfile:155`; they must not change.
- Zed composes `languages.<Lang>` from two sources (the pinned snapshot and
  `preferences.nix:25-46`) and `recursiveUpdate` **replaces lists**, so the fan-out must
  respect that semantics.
- Home Manager's `programs.vscode.profiles` is `attrsOf (submodule …)` and `extensions` is
  `types.listOf types.package`, so additive extension from another module works.
  `enableUpdateCheck`/`enableExtensionUpdateCheck` are valid on the `default` profile only.

## Evidence

- Feature tracked in Engram as `odd/language-packs/tasks`.
- Catalog precedent: `modules/common/ai-tools/{catalog.nix,ai-skills.nix}`, imported as plain
  files from `checks/impeccable/default.nix:21` and `libraries/system/common/default.nix:12`.
- Editor seam feasibility verified against the pinned Home Manager:
  `modules/programs/vscode/mkVscodeModule.nix:379-386` (`extensions` is a package list) and
  `:493-497` (update-check options are default-profile only).
- Nixpkgs builds `vscjava.vscode-java-pack` without propagated members, verified at the pinned
  revision `pkgs/applications/editors/vscode/extensions/default.nix:5227-5241`, which is why
  the members are listed explicitly and why the pack needs to own that list.
- ADR numbering: the next free index is **0018**; `0009` is `per-user-identity`. The highest
  index before this change was 0017.
- Task 1: `docs/decisions/0018-language-pack-class.md` landed and is referenced from the Module
  Contract V1 sections of `modules/common/AGENTS.md` and `modules/home/AGENTS.md`.
- Task 1 needs no docs golden change: `checks/docs-generation` diffs the `## ` header index of
  the generated *option* docs, and the mdbook SUMMARY is built from option declarations
  (`flake/docs/default.nix:59-63`), so repository ADRs are not part of that site.
- Task 2: catalog added at `modules/common/languages/{catalog,java}.nix` with Java as the pilot, and
  `tests/languages/catalog.nix` asserts the shape plus the R3-001 JDK-pinning contract through a
  stub `pkgs`, because the nix-unit harness passes test files no `pkgs`.
- The catalog keeps `python3` out of Java's toolchain: it is a need of those specific shells, not
  part of Java language support, so it stays a shell-local extra.
- Gotcha for the remaining tasks: a new directory must be staged before Nix can see it. A flake
  Git tree hides untracked paths, so `importTestFiles ./languages` first failed with
  `Path 'tests/languages' ... is not tracked by Git`. Stage or `git add -N` new paths before
  evaluating, or a check fails for the wrong reason.
- Task 2 verification: `unit-nix-unit` built against the fixture secrets, and the composed test set
  reports 411 tests, of which 9 are the new `testLanguage*` cases.

## Commits

- (none yet)
