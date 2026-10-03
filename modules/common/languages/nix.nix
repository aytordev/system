# Pure Nix development-toolchain data. See ./catalog.nix.
#
# This is Nix as a language the user develops in, not the substrate this
# configuration is written in: the substrate is foundational and cannot be
# gated. See ADR-0018.
{pkgs}: let
  toolchain = with pkgs; [
    hydra-check
    nix-bisect
    nix-diff
    nix-fast-build
    nix-health
    nix-index
    nix-output-monitor
    nix-update
    nixpkgs-hammering
    nixpkgs-lint-community
    nixpkgs-review
    nurl
  ];
in {
  name = "nix";

  # No version axis: the toolchain is a single set of packages.
  versions = [];
  defaultVersion = null;

  # Both roles resolve to the same set, and the version argument is ignored.
  runtime = _: toolchain;
  toolchain = _: toolchain;
}
