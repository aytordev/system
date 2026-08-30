{
  inputs,
  lib,
  self,
  ...
}: let
  overlaysPath = ../../overlays;

  # Read overlay directories (skip default.nix)
  dynamicOverlaysSet =
    if builtins.pathExists overlaysPath
    then let
      overlayDirs = self.lib.file.configurationDirectories overlaysPath;
    in
      lib.genAttrs overlayDirs (
        name:
        # Existing overlays are already final: prev: functions
          import (overlaysPath + "/${name}/default.nix")
      )
    else {};
in {
  flake.overlays = dynamicOverlaysSet;

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # Apply ALL overlays defined in the flake (including the ones from packages module)
      overlays = lib.attrValues self.overlays;
      config.allowUnfree = true;
    };
  };
}
