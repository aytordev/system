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
      ../../modules/darwin/system/env
      {
        aytordev.system.env.TEST_PATH = [
          "/first"
          "/second"
        ];
      }
    ];
  };

  inherit (darwin.config) environment;
  tests = [
    (extendedLib.hasInfix ''export TEST_PATH="/first:/second"'' environment.extraInit)
    (environment.variables.PAGER == "less -FR")
    (builtins.elem "/share/doc" environment.pathsToLink)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "system-env-tests" {} ''
      touch "$out"
    ''
