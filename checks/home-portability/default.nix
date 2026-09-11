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
  commonNoFastfetchHome = mkPortableHome {
    suite = "common";
    extraModule.aytordev.programs.terminal.tools.fastfetch.enable = false;
  };
  desktopHome = mkPortableHome {suite = "desktop";};
  businessHome = mkPortableHome {suite = "business";};
  catppuccinHome = mkPortableHome {
    suite = "desktop";
    extraModule.aytordev = {
      theme = {
        name = "catppuccin";
        variant = "mocha";
      };
      programs.terminal.tools.yazi.enable = true;
    };
  };
  catppuccinDevHome = mkPortableHome {
    suite = "development";
    extraModule.aytordev.theme = {
      name = "catppuccin";
      variant = "mocha";
    };
  };
  desktopOverrideHome = mkPortableHome {
    suite = "desktop";
    extraModule.aytordev = {
      theme.variant = "lotus";
      programs.desktop.bars.sketchybar.items.menus.enable = false;
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
  commonNoFastfetchConfig = commonNoFastfetchHome.config;
  desktopConfig = desktopHome.config;
  businessConfig = businessHome.config;
  catppuccinConfig = catppuccinHome.config;
  catppuccinDevConfig = catppuccinDevHome.config;
  desktopOverrideConfig = desktopOverrideHome.config;
  developmentOverrideConfig = developmentOverrideHome.config;
  developmentOptions = developmentOverrideHome.options.aytordev.suites.development;
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
    (config.programs.fish.package == config.aytordev.programs.terminal.shells.fish.package)
    (config.programs.nushell.package == config.aytordev.programs.terminal.shells.nushell.package)
    (config.programs.zsh.package == config.aytordev.programs.terminal.shells.zsh.package)
    (builtins.seq commonHome.activationPackage true)
    (config.home.file ? "Desktop/.keep")
    (config.programs.bash.shellAliases ? cleanup)
    (config.programs.fish.shellAliases ? cleanup)
    (!(config.home.shellAliases ? cleanup))
    config.programs.home-manager.enable
    (!(commonNoFastfetchConfig.programs.bash.shellAliases ? clear))
    (lib.hasInfix "__HM_SESS_VARS_SOURCED" config.programs.bash.shellAliases.hmvar-reload)
    (lib.hasInfix config.home.profileDirectory config.programs.bash.shellAliases.hmvar-reload)
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
    (!(desktopConfig.aytordev.theme ? enable))
    (!(desktopConfig.aytordev.programs.desktop.bars.sketchybar ? themeOverride))
    (!(desktopConfig.aytordev.services.jankyborders ? themeOverride))
    (desktopConfig.aytordev.services.jankyborders.enable == isDarwin)
    (desktopConfig.aytordev.theme.providers ? kanagawa)
    (desktopConfig.aytordev.theme.providers ? catppuccin)
    (catppuccinConfig.aytordev.theme.palette.accent.hex == "#89b4fa")
    (catppuccinConfig.aytordev.theme.appTheme.capitalized == "Catppuccin Mocha")
    (catppuccinConfig.aytordev.theme.appThemeDark.capitalized == "Catppuccin Mocha")
    (catppuccinConfig.aytordev.theme.appThemeLight.capitalized == "Catppuccin Latte")
    (!catppuccinConfig.aytordev.theme.isLight)
    (catppuccinConfig.aytordev.programs.terminal.emulators.ghostty.theme == "catppuccin-mocha")
    (desktopConfig.aytordev.programs.terminal.emulators.ghostty.theme == "kanagawa-dragon")
    (desktopConfig.aytordev.programs.terminal.tools.pi.theme == "aytordev")
    (config.programs.yazi.theme.flavor.dark == "kanagawa-dragon")
    (catppuccinConfig.programs.yazi.theme.flavor.dark == "catppuccin-mocha")
    (
      if isDarwin
      then
        desktopConfig.services.jankyborders.settings.active_color
        != desktopConfig.services.jankyborders.settings.inactive_color
      else true
    )
    (
      if isDarwin
      then let
        constants = desktopConfig.xdg.configFile."sketchybar/nix_constants.lua".text;
      in
        lib.hasInfix "catppuccin/mocha" constants
        && lib.hasInfix "kanagawa/dragon" constants
        && lib.hasInfix "active_theme" constants
      else true
    )
    (config.aytordev.programs.terminal.tools.starship.palette == "aytordev")
    (
      catppuccinDevConfig.programs.vscode.profiles.default.userSettings."workbench.colorTheme"
      == "Catppuccin Mocha"
    )
    (
      catppuccinDevConfig.programs.vscode.profiles.default.userSettings."workbench.preferredDarkColorTheme"
      == "Catppuccin Mocha"
    )
    (
      catppuccinDevConfig.programs.vscode.profiles.default.userSettings."workbench.preferredLightColorTheme"
      == "Catppuccin Latte"
    )
    (
      developmentOverrideConfig.programs.vscode.profiles.default.userSettings."workbench.preferredDarkColorTheme"
      == "Kanagawa Dragon"
    )
    (lib.elem "catppuccin" catppuccinDevConfig.programs.zed-editor.extensions)
    (catppuccinDevConfig.programs.zed-editor.userSettings.theme == "Catppuccin Mocha")
    (developmentOverrideConfig.programs.zed-editor.userSettings.theme == "Kanagawa Dragon")
    ((desktopConfig.home.file ? "Pictures/screenshots/.keep") == isDarwin)
    (desktopConfig.programs.firefox.configPath == ".mozilla/firefox")
    (
      desktopConfig.programs.firefox.profiles.default.settings."browser.download.dir"
      == "${homeDirectory}/Downloads"
    )
    (!businessConfig.aytordev.programs.terminal.tools.bitwarden-cli.apiKey.enable)
    (!(businessConfig.home.file ? ".local/bin/bitwarden-login-sops"))
    (desktopOverrideConfig.aytordev.theme.variant == "lotus")
    (!desktopOverrideConfig.aytordev.programs.desktop.bars.sketchybar.items.menus.enable)
    (!developmentOverrideConfig.aytordev.programs.terminal.editors.neovim.enable)
    (!developmentOverrideConfig.aytordev.programs.terminal.editors.neovim.default)
    (!(developmentOptions ? azureEnable))
    (!(developmentOptions ? dockerEnable))
    (!(developmentOptions ? gameEnable))
    (!(developmentOptions ? goEnable))
    (!(developmentOptions ? sqlEnable))
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-portability-tests" {} ''
      touch "$out"
    ''
