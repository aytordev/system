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
  mkPortableHome = suite:
    inputs.self.lib.system.mkHome {
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
            suites.${suite}.enable = true;
          };
          home.stateVersion = "25.11";
        }
      ];
    };
  commonHome = mkPortableHome "common";
  desktopHome = mkPortableHome "desktop";
  businessHome = mkPortableHome "business";
  inherit (commonHome) config;
  desktopConfig = desktopHome.config;
  businessConfig = businessHome.config;
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
    (builtins.seq desktopHome.activationPackage true)
    (builtins.seq businessHome.activationPackage true)
    (config.aytordev.services.protonmail-bridge.enable == isDarwin)
    (config.aytordev.programs.terminal.tools.nh.flake == null)
    (!(builtins.hasAttr "nixcfg" config.home.shellAliases))
    (
      if isDarwin
      then dragBinding == null
      else builtins.elem "dragon-drop" packageNames && lib.hasInfix "bin/dragon-drop" dragBinding.run
    )
    (desktopConfig.aytordev.programs.desktop.bars.sketchybar.enable == isDarwin)
    (desktopConfig.aytordev.programs.desktop.browsers.chrome-dev.enable == isDarwin)
    (desktopConfig.aytordev.services.jankyborders.enable == isDarwin)
    ((desktopConfig.home.file ? "Pictures/screenshots/.keep") == isDarwin)
    (
      desktopConfig.programs.firefox.profiles.default.settings."browser.download.dir"
      == "${homeDirectory}/Downloads"
    )
    (!businessConfig.aytordev.programs.terminal.tools.bitwarden-cli.settings.apiKey.useSops)
    (!(businessConfig.home.file ? ".local/bin/rbw-unlock-sops"))
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-portability-tests" {} ''
      touch "$out"
    ''
