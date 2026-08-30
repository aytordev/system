{pkgs, ...}: let
  shared = import ../parse/shared.nix;
in
  shared {
    inherit pkgs;
    inherit (pkgs) lib;
    nix = pkgs.lixPackageSets.latest.lix;
  }
