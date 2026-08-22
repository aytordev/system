{
  inputs,
  lib,
  pkgs,
  ...
}: let
  overlays = inputs.self.overlays;
  overlayNames = builtins.attrNames overlays;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  appliedOverlays = darwin.config.nixpkgs.overlays;
  devModule = import ../../flake/dev {
    inherit inputs lib;
    inherit (inputs) self;
  };
  devPkgs =
    (devModule.perSystem {inherit (pkgs.stdenv.hostPlatform) system;})._module.args.pkgs.content;
  tests = [
    (builtins.hasAttr "default" overlays)
    (!(builtins.hasAttr "aytordev" overlays))
    (builtins.length appliedOverlays == builtins.length overlayNames)
    (builtins.hasAttr "pencil-dev" darwin.pkgs.aytordev)
    (builtins.seq devPkgs.aytordev.agentapi true)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "overlay-composition-tests" {} ''
      touch "$out"
    ''
