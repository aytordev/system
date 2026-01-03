{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      directory = ../../packages;
      packageFunctions = lib.filesystem.packagesFromDirectoryRecursive {
        inherit directory;
        callPackage = file: _args: import file;
      };

      builtPackages = lib.fix (
        self:
        lib.mapAttrs (
          _name: packageData:
          let
            packageFn = packageData.default or packageData;
          in
          pkgs.callPackage packageFn (
            self
            // {
              inherit inputs;
            }
          )
        ) packageFunctions
      );

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
