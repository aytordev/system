{pkgs, ...}: let
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
in
  # Consumer projects own their hooks and lint/format policy.
  pkgs.mkShellNoCC {
    name = "node-26-minimal";
    packages = catalog.node.toolchain "26";
  }
