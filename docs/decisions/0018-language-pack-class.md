# ADR 0018: Adopt the Language Pack Class

Status: Accepted

## Decision

Language support becomes a first-class, per-host choice with two halves: a pure-data catalog
and a language pack class. This adds a seventh class to the catalogue in
[ADR-0008](0008-module-contract-v1.md).

The catalog lives in `modules/common/languages/` and holds one file per language plus a
`catalog.nix` registry. It is a function of `pkgs`, has **no `default.nix`**, and is imported as
a plain file. That is what lets one definition serve both the root flake and the separate `dev`
partition without either importing the other, and it keeps the catalog out of module discovery.
The location follows `modules/common/ai-tools/`, which already keeps pure data in a
`default.nix`-less directory imported as a plain file from other partitions.

A language pack is a Home Manager module at `modules/home/languages/<lang>/default.nix` that
declares `aytordev.languages.<lang>` with `enable` and, for versioned families, a `version`
selector drawn from the catalog.

## Consequences

- A pack owns a *set* of packages rather than one primary package, so it is exempt from the
  `checks/module-contract` capability list, which asserts a singular `package` option. A pack
  declares `packages`, and `checks/language-packs` enforces that contract instead.
- A pack never edits an editor module. It writes to the extension and settings seams those
  modules expose, so it does not need to know which VS Code profiles exist.
- Dev shells consume the catalog; they do not activate it. A dev shell is an ephemeral
  environment entered with `nix develop`, never an installed artifact, so enabling a language
  must not promise a dev shell.
- `aytordev.languages.nix` owns the Nix *development toolchain* and replaces
  `aytordev.suites.development.nixEnable`. Nix as the substrate this configuration is written in
  is foundational and is not gateable: disabling it would require evaluating Nix to do so.
- A language that is not enabled contributes nothing — no packages, no editor extensions, no
  editor or shell settings.
