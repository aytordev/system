{
  inputs,
  lib,
  pkgs,
  ...
}: let
  overlays = inputs.self.overlays;
  overlayNames = builtins.attrNames overlays;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  appliedOverlays = darwin.config.nixpkgs.overlays;
  linuxSystem = "x86_64-linux";
  baseLinuxPkgs = import inputs.nixpkgs {
    system = linuxSystem;
    config.allowUnfree = true;
  };
  overlaidLinuxPkgs = import inputs.nixpkgs {
    system = linuxSystem;
    overlays = lib.attrValues overlays;
    config.allowUnfree = true;
  };
  tests = [
    (builtins.hasAttr "default" overlays)
    (!(builtins.hasAttr "aytordev" overlays))
    (builtins.length appliedOverlays == builtins.length overlayNames)
    (builtins.hasAttr "pen-dev" darwin.pkgs.aytordev)
    (!darwin.pkgs.chromaprint.doCheck)
    (!darwin.pkgs.kvazaar.doCheck)
    (lib.hasInfix "internal/updater/install_darwin.go" darwin.pkgs.protonmail-bridge.postPatch)
    # The zed overlay must stay Darwin-only and must not disturb the Linux derivation.
    (lib.hasInfix "osx.info_plist_exts" darwin.pkgs.zed-editor.postPatch)
    # The overlay must restrict the bundle format so the sandboxed installPhase never needs hdiutil.
    (lib.hasInfix "--format osx" darwin.pkgs.zed-editor.installPhase)
    (overlaidLinuxPkgs.zed-editor.drvPath == baseLinuxPkgs.zed-editor.drvPath)
    (overlaidLinuxPkgs.kvazaar.drvPath == baseLinuxPkgs.kvazaar.drvPath)
    (overlaidLinuxPkgs.chromaprint.drvPath == baseLinuxPkgs.chromaprint.drvPath)
    (overlaidLinuxPkgs.protonmail-bridge.drvPath == baseLinuxPkgs.protonmail-bridge.drvPath)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "overlay-composition-tests" {} ''
      touch "$out"
    ''
