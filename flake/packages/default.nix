{
  inputs,
  lib,
  ...
}:
let
  directory = ../../packages;

  packageFunctions = lib.filesystem.packagesFromDirectoryRecursive {
    inherit directory;
    callPackage = file: _args: import file;
  };

  # Create overlay from packages directory
  aytordevPackagesOverlay =
    final: prev:
    {
      aytordev = prev.lib.fix (
        self:
        prev.lib.mapAttrs (
          _name: func: final.callPackage func (self // { inherit inputs; })
        ) packageFunctions
      );
    };
in
{
  flake.overlays = {
    default = aytordevPackagesOverlay;
    aytordev = aytordevPackagesOverlay;
  };

  perSystem =
    { pkgs, ... }:
    let
      # Use the packages from the overlay we just created/injected
      # Note: pkgs here will have the overlay applied because of the global configuration in overlays/default.nix
      builtPackages = pkgs.aytordev or {};

      supportedPackages = lib.filterAttrs (
        _name: package:
        package != null
        && (!(package ? meta.platforms) || lib.meta.availableOn pkgs.stdenv.hostPlatform package)
      ) builtPackages;
    in
    {
      packages = supportedPackages;
    };
}
