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
# See ADR-0018 (docs/decisions/0018-language-pack-class.md).
{pkgs}: {
  java = import ./java.nix {inherit pkgs;};
}
