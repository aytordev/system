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
  mkPortableHome = {
    suite,
    extraModule ? {},
  }:
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
          };
          home.stateVersion = "25.11";
        }
        {aytordev.suites.${suite}.enable = true;}
        extraModule
      ];
    };
  commonHome = mkPortableHome {suite = "common";};
  desktopHome = mkPortableHome {suite = "desktop";};
  businessHome = mkPortableHome {suite = "business";};
  desktopOverrideHome = mkPortableHome {
    suite = "desktop";
    extraModule.aytordev = {
      theme.variant = "lotus";
      programs.desktop.browsers.brave.enable = false;
    };
  };
  developmentOverrideHome = mkPortableHome {
    suite = "development";
    extraModule.aytordev.programs.terminal.editors.neovim = {
      enable = false;
      default = false;
    };
  };
  inherit (commonHome) config;
  desktopConfig = desktopHome.config;
  businessConfig = businessHome.config;
  desktopOverrideConfig = desktopOverrideHome.config;
  developmentOverrideConfig = developmentOverrideHome.config;
  packageNames = map lib.getName config.home.packages;
  dragBinding =
    lib.findFirst (
      binding: binding.on == ["<C-v>"]
    )
    null
    config.programs.yazi.keymap.mgr.prepend_keymap;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  tests = [
    (config.programs.bash.package == pkgs.bashInteractive)
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
    (desktopConfig.programs.firefox.configPath == ".mozilla/firefox")
    (
      desktopConfig.programs.firefox.profiles.default.settings."browser.download.dir"
      == "${homeDirectory}/Downloads"
    )
    (!businessConfig.aytordev.programs.terminal.tools.bitwarden-cli.apiKey.enable)
    (!(businessConfig.home.file ? ".local/bin/bitwarden-login-sops"))
    (desktopOverrideConfig.aytordev.theme.variant == "lotus")
    (!desktopOverrideConfig.aytordev.programs.desktop.browsers.brave.enable)
    (!developmentOverrideConfig.aytordev.programs.terminal.editors.neovim.enable)
    (!developmentOverrideConfig.aytordev.programs.terminal.editors.neovim.default)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-portability-tests" {} ''
      touch "$out"
    ''
