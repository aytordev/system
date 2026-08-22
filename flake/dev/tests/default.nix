{
  inputs,
  lib,
  ...
}: let
  hasNixUnit = inputs ? nix-unit && inputs.nix-unit ? modules;
in {
  imports = lib.optional hasNixUnit inputs.nix-unit.modules.flake.default;

  perSystem = _: {
    nix-unit = lib.mkIf hasNixUnit {
      inputs = {
        inherit
          (inputs)
          flake-parts
          home-manager
          nixpkgs
          ;
      };
    };
  };
}
