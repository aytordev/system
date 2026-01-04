{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption getExe;
  inherit (lib.types) package listOf;

  cfg = config.aytordev.applications.desktop.bars.sketchybar;

  # Base packages required for sketchybar functionality
  basePackages = with pkgs; [
    blueutil
    coreutils
    lua54Packages.dkjson
    curl
    gh
    gh-notify
    gnugrep
    gnused
    jankyborders
    switchaudio-osx
  ];

  # Conditionally included packages based on system configuration
  conditionalPackages =
    lib.optionals (osConfig.services ? yabai && osConfig.services.yabai.enable) [
      osConfig.services.yabai.package
    ]
    ++ lib.optionals (config.applications ? aerospace && config.applications.aerospace.enable) [
      config.applications.aerospace.package
    ];

  # All packages needed for sketchybar
  allPackages = basePackages ++ conditionalPackages ++ cfg.extraPackages;

  # Shell aliases for common operations
  shellAliases = {
    restart-sketchybar = ''launchctl kickstart -k gui/"$(id -u)"/org.nix-community.home.sketchybar'';
  };

  # Brew integration functions for zsh
  brewIntegration = ''
    brew() {
      command brew "$@" && ${getExe cfg.package} --trigger brew_update
    }

    mas() {
      command mas "$@" && ${getExe cfg.package} --trigger brew_update
    }
  '';
in {
  options.aytordev.applications.desktop.bars.sketchybar = {
    enable = mkEnableOption "Sketchybar status bar";

    package = mkOption {
      type = package;
      default = pkgs.sketchybar;
      defaultText = lib.literalExpression "pkgs.sketchybar";
      description = "The Sketchybar package to use.";
    };

    extraPackages = mkOption {
      type = listOf package;
      default = [];
      description = "Extra packages needed for Sketchybar plugins and functionality.";
    };
  };

  config = mkIf cfg.enable {
    # Shell integration
    home.shellAliases = shellAliases;
    applications.zsh.initContent = brewIntegration;

    # Main sketchybar configuration
    applications.sketchybar = {
      enable = true;
      configType = "lua";
      package = cfg.package;
      sbarLuaPackage = pkgs.sbarlua;
      extraPackages = allPackages;

      config = {
        source = ./config;
        recursive = true;
      };
    };

    # Configuration files
    xdg.configFile = {
      "sketchybar/sketchybarrc" = {
        text = ''
          #!/usr/bin/env lua
          require("init")
        '';
        executable = true;
      };

      "sketchybar/helpers/icon_map.lua".source = "${pkgs.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua";
    };
  };
}
