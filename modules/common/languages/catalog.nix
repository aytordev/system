# Pure per-language data, shared by the Home language packs and by the dev
# shells. Not a module and not a runtime registry.
#
# Two properties matter and are easy to break: this directory has no
# `default.nix`, which is what keeps the catalog out of module discovery, and
# the catalog is a function of `pkgs`, so the root flake and the separate
# `dev` partition share one definition without importing each other.
#
# Import it as a plain file:
#   import ../../../modules/common/languages/catalog.nix { inherit pkgs; }
#
# Every language entry exposes:
#   name           the language name.
#   versions       the selectable versions, or [] when the language has no
#                  version axis worth choosing.
#   defaultVersion one of `versions`, or null for an unversioned language.
#   runtime        version -> packages installed so the language works.
#                  An unversioned language ignores the argument and its pack
#                  passes null, so a consumer never branches on the language.
#   toolchain      version -> the fuller set a development shell adds.
#   editor         optional editor contributions: vscode.extensions and
#                  vscode.settings, zed.extensions and zed.languages.
#
# See ADR-0018 (docs/decisions/0018-language-pack-class.md).
{pkgs}: {
  java = import ./java.nix {inherit pkgs;};
  nix = import ./nix.nix {inherit pkgs;};
}
