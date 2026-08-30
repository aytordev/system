{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  darwin = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs.lib = extendedLib;
    modules = [
      {_module.args.lib = extendedLib;}
      ../../modules/common/suites/common
      {aytordev.suites.common.enable = true;}
    ];
  };

  packageNames = map extendedLib.getName darwin.config.environment.systemPackages;
  linuxOnlyPackages = [
    "pciutils"
    "xclip"
  ];
in
  assert builtins.all (package: !(builtins.elem package packageNames)) linuxOnlyPackages;
    pkgs.runCommand "system-common-suite-tests" {} ''
      touch "$out"
    ''
