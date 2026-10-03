# Language Catalog

Pure per-language data for the language pack class. See ADR-0018
(`docs/decisions/0018-language-pack-class.md`).

- This directory has NO `default.nix` and must not gain one: the absence is
  what keeps the catalog out of module discovery.
- `catalog.nix` is a function of `pkgs` imported as a plain file, which is why
  one definition serves the root flake and the separate `dev` partition,
  including `dev-shells/` and `checks/`.
- The entry contract (name, versions, defaultVersion, runtime, toolchain,
  editor) is documented at the top of `catalog.nix`.

Adding a language:

1. Add `<language>.nix`, declaring `editor.vscode.extensions` even when empty.
2. Register it in `catalog.nix`.
3. Add the pack at `modules/home/languages/<language>/default.nix`.
4. Enable it in the homes that want it; an unenabled language contributes
   nothing.

`checks/language-packs` enforces the contract and forces every pack, so a
contract break fails at evaluation time instead of at home activation.
