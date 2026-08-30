{
  inputs,
  lib,
  pkgs,
  ...
}: let
  libExports = builtins.mapAttrs (_: exports: builtins.attrNames exports) (
    builtins.removeAttrs inputs.self.lib ["overlay"]
  );
  goldenExports = import ./golden.nix;
  changed = name:
    builtins.sort (a: b: a < b) (
      lib.unique (
        builtins.filter (fn: !(builtins.elem fn libExports.${name})) goldenExports.${name}
        ++ builtins.filter (fn: !(builtins.elem fn goldenExports.${name})) libExports.${name}
      )
    );
  missing = lib.concatLists (builtins.map changed (builtins.attrNames goldenExports));
  errorMessage = lib.concatLists [
    ["Library export drift. Added or removed public exports:"]
    (builtins.map (fn: "  - ${fn}") missing)
    ["Update checks/library-exports/golden.nix to match."]
  ];
in
  if libExports == goldenExports
  then
    pkgs.runCommand "library-exports-check" {} ''
      touch "$out"
    ''
  else throw (builtins.concatStringsSep "\n" errorMessage)
