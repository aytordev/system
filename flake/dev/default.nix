{
  inputs,
  lib,
  self,
  ...
}: let
  allOverlays = lib.attrValues self.overlays;
in {
  imports = [
    ./dev-shells
    ./checks
    ./treefmt
    ./templates
  ];

  perSystem = {system, ...}: {
    _module.args.pkgs = lib.mkDefault (
      import inputs.nixpkgs {
        inherit system;
        overlays = allOverlays;
        config.allowUnfree = true;
      }
    );
  };
}
