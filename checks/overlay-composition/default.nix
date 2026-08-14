{
  inputs,
  pkgs,
  ...
}: let
  overlays = inputs.self.overlays;
  overlayNames = builtins.attrNames overlays;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  appliedOverlays = darwin.config.nixpkgs.overlays;
  tests = [
    (builtins.hasAttr "default" overlays)
    (!(builtins.hasAttr "aytordev" overlays))
    (builtins.length appliedOverlays == builtins.length overlayNames)
    (builtins.hasAttr "pencil-dev" darwin.pkgs.aytordev)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "overlay-composition-tests" {} ''
      touch "$out"
    ''
