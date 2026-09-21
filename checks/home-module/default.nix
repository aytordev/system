{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  baseHome = {
    home = {
      username = "module-test";
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/module-test"
        else "/home/module-test";
      stateVersion = "25.11";
    };
  };
  mkHome = modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        hostname = "module-test";
        username = "module-test";
        osConfig = {};
        lib = extendedLib;
      };
      modules = modules ++ [baseHome];
    };
  home = mkHome [
    inputs.self.homeModules.default
    (
      {
        config,
        lib,
        ...
      }: {
        assertions = [
          {
            assertion = lib.attrByPath ["programs" "zellij" "settings" "keybinds"] {} config == {};
            message = "Zellij keybinds must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "zellij" "layouts"] {} config == {};
            message = "Zellij layouts must be empty while the aytordev module is disabled";
          }
        ];
      }
    )
  ];
  injectedHome = inputs.self.lib.system.mkHome {
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "injected-host";
    username = "injected-user";
    homeModules = [
      ({lib, ...}: {
        options.testMarker = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        config.testMarker = true;
      })
    ];
    modules = [
      {
        home = {
          username = "injected-user";
          homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Users/injected-user"
            else "/home/injected-user";
          stateVersion = "25.11";
        };
      }
    ];
  };
  tests = [
    injectedHome.config.testMarker
  ];
in
  assert builtins.all (test: test) (
    extendedLib.imap0 (
      index: test:
        if test
        then true
        else builtins.trace "home-module test ${toString index} failed" false
    )
    tests
  );
    home.activationPackage
