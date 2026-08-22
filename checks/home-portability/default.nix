{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "portability-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  commonHome = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "portability-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "portability@example.test";
            fullName = "Portability User";
            home = homeDirectory;
          };
          suites.common.enable = true;
        };
        home.stateVersion = "25.11";
      }
    ];
  };
  inherit (commonHome) config;
  packageNames = map lib.getName config.home.packages;
  dragBinding =
    lib.findFirst (
      binding: binding.on == ["<C-v>"]
    )
    null
    config.programs.yazi.keymap.mgr.prepend_keymap;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  tests = [
    (builtins.seq commonHome.activationPackage true)
    (config.aytordev.services.protonmail-bridge.enable == isDarwin)
    (config.aytordev.programs.terminal.tools.nh.flake == null)
    (!(builtins.hasAttr "nixcfg" config.home.shellAliases))
    (
      if isDarwin
      then dragBinding == null
      else builtins.elem "dragon-drop" packageNames && lib.hasInfix "bin/dragon-drop" dragBinding.run
    )
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-portability-tests" {} ''
      touch "$out"
    ''
