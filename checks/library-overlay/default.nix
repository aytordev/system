{
  inputs,
  pkgs,
  ...
}: let
  overlayAttrs = inputs.self.lib.overlay inputs.nixpkgs.lib inputs.nixpkgs.lib;
  requiredExports = [
    "aytordev"
    "file"
    "system"
    "getFile"
    "importModulesRecursive"
    "mkOpt"
    "hm"
  ];
  removedExports = [
    "getDirectories"
    "relativeToRoot"
  ];
  forcedExports = map (name: builtins.seq overlayAttrs.${name} true) (
    builtins.attrNames overlayAttrs
  );
  tests = [
    (builtins.deepSeq forcedExports true)
    (builtins.all (name: builtins.hasAttr name overlayAttrs) requiredExports)
    (builtins.all (name: !(builtins.hasAttr name overlayAttrs)) removedExports)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "library-overlay-tests" {} ''
      touch "$out"
    ''
