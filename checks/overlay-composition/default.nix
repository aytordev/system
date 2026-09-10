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
    (builtins.hasAttr "pencil-dev" darwin.pkgs.aytordev)
    (!darwin.pkgs.chromaprint.doCheck)
    (!darwin.pkgs.kvazaar.doCheck)
    (builtins.hasAttr "google-chrome-dev" darwin.pkgs)
    (builtins.hasAttr "ungoogled-chromium-macos" darwin.pkgs)
    (lib.hasInfix "internal/updater/install_darwin.go" darwin.pkgs.protonmail-bridge.postPatch)
    (overlaidLinuxPkgs.google-chrome.drvPath == baseLinuxPkgs.google-chrome.drvPath)
    (!(builtins.hasAttr "google-chrome-dev" overlaidLinuxPkgs))
    (!(builtins.hasAttr "ungoogled-chromium-macos" overlaidLinuxPkgs))
    (overlaidLinuxPkgs.kvazaar.drvPath == baseLinuxPkgs.kvazaar.drvPath)
    (overlaidLinuxPkgs.chromaprint.drvPath == baseLinuxPkgs.chromaprint.drvPath)
    (overlaidLinuxPkgs.protonmail-bridge.drvPath == baseLinuxPkgs.protonmail-bridge.drvPath)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "overlay-composition-tests" {} ''
      touch "$out"
    ''
