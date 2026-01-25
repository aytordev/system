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
      entries = builtins.readDir overlaysPath;
      overlayDirs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
    in
      lib.genAttrs overlayDirs (
        name: let
          overlayPath = overlaysPath + "/${name}";
        in
          # Existing overlays are already final: prev: functions
          import overlayPath
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
