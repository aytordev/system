{
  inputs,
  lib,
  ...
}:
let
  overlaysPath = ../../overlays;

  # Read overlay directories (skip default.nix)
  dynamicOverlaysSet =
    if builtins.pathExists overlaysPath then
      let
        entries = builtins.readDir overlaysPath;
        overlayDirs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
      in
      lib.genAttrs overlayDirs (
        name:
        let
          overlayPath = overlaysPath + "/${name}";
        in
        # Existing overlays are already final: prev: functions
        import overlayPath
      )
    else
      { };

  # Create aytordev packages overlay
  aytordevPackagesOverlay =
    final: prev:
    let
      directory = ../../packages;
      packageFunctions = prev.lib.filesystem.packagesFromDirectoryRecursive {
        inherit directory;
        callPackage = file: _args: import file;
      };
    in
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
  flake.overlays = dynamicOverlaysSet // {
    default = aytordevPackagesOverlay;
    aytordev = aytordevPackagesOverlay;
  };
}
