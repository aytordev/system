{
  inputs,
  lib,
  ...
}:
let
  overlaysConfig = import ../overlays/default.nix { inherit inputs lib; };
  allOverlays = lib.attrValues (overlaysConfig.flake.overlays or {});
in
{
  imports = [
    ./devshells
    ./checks
    ./formatter
    ./templates
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = lib.mkDefault (
        import inputs.nixpkgs {
          inherit system;
          overlays = allOverlays;
          config.allowUnfree = true;
        }
      );
    };
}
