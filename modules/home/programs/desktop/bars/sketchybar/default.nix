{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption getExe;
  inherit (lib.types) package listOf str int float enum nullOr;

  cfg = config.aytordev.programs.desktop.bars.sketchybar;
  themeCfg = config.aytordev.theme;

  # Get the active palette from central theme module
  inherit (themeCfg) palette;

  # Convert central palette to sketchybar Lua format
  # Maps semantic colors to the flat structure expected by Lua config
  sketchybarColors = {
    default = palette.fg.sketchybar;
    black = palette.bg_dim.sketchybar;
    white = palette.fg.sketchybar;
    red = palette.red.sketchybar;
    red_bright = palette.red_bright.sketchybar;
    green = palette.green.sketchybar;
    blue = palette.accent.sketchybar;
    blue_bright = palette.blue_bright.sketchybar;
    yellow = palette.yellow.sketchybar;
    orange = palette.orange.sketchybar;
    magenta = palette.violet.sketchybar;
    grey = palette.fg_dim.sketchybar;
    transparent = palette.transparent.sketchybar;

    bar = {
      # Add alpha to background (0xf0 instead of 0xff)
      bg = builtins.replaceStrings ["0xff"] ["0xf0"] palette.bg.sketchybar;
      border = palette.border.sketchybar;
    };

    popup = {
      bg = palette.bg.sketchybar;
      border = palette.border.sketchybar;
    };

    bg1 = palette.bg.sketchybar;
    bg2 = palette.border.sketchybar;

    accent = palette.accent.sketchybar;
    accent_bright = palette.accent_dim.sketchybar;

    spotify_green = palette.green.sketchybar;
  };

  # Base packages required for sketchybar functionality
  basePackages = with pkgs; [
    blueutil
    coreutils
    curl
    gh
    gh-notify
    gnugrep
    gnused
    jankyborders
    switchaudio-osx
  ];

  # Conditionally included packages based on system configuration
  conditionalPackages = [];

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

  # Helper to convert Nix attrs to Lua table syntax
  toLuaTable = attrs: let
    toLuaValue = v:
      if builtins.isString v
      then "\"${v}\""
      else if builtins.isBool v
      then
        (
          if v
          then "true"
          else "false"
        )
      else if builtins.isAttrs v
      then toLuaTable v
      else builtins.toString v;
    fields = lib.mapAttrsToList (k: v: "${k} = ${toLuaValue v}") attrs;
  in "{\n${builtins.concatStringsSep ",\n" fields}\n}";
in {
  options.aytordev.programs.desktop.bars.sketchybar = {
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

    # Theme override (optional - uses global theme by default)
    themeOverride = mkOption {
      type = nullOr (enum ["wave" "dragon" "lotus"]);
      default = null;
      description = ''
        Override the global Kanagawa theme variant for Sketchybar only.
        If null (default), uses the global theme from aytordev.theme.variant.
      '';
    };

    # Font configuration
    fonts = {
      text = mkOption {
        type = str;
        default = "SF Pro";
        description = "Main text font family.";
      };
      icon = mkOption {
        type = str;
        default = "Hack Nerd Font";
        description = "Icon font family (should be a Nerd Font).";
      };
      size = mkOption {
        type = float;
        default = 13.0;
        description = "Base font size.";
      };
    };

    # Icon style
    iconsStyle = mkOption {
      type = enum ["sf_symbols" "nerdfont"];
      default = "sf_symbols";
      description = "Icon set to use (SF Symbols or Nerd Font icons).";
    };

    # Bar configuration
    bar = {
      height = mkOption {
        type = int;
        default = 30;
        description = "Height of the bar in pixels.";
      };
      blurRadius = mkOption {
        type = int;
        default = 20;
        description = "Blur radius for the bar background.";
      };
      shadow = mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show shadow under the bar.";
      };
      sticky = mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the bar stays visible when switching spaces.";
      };
      topmost = mkOption {
        type = enum ["off" "window" "layer"];
        default = "window";
        description = "Bar topmost mode.";
      };
      paddingLeft = mkOption {
        type = int;
        default = 10;
        description = "Left padding of the bar.";
      };
      paddingRight = mkOption {
        type = int;
        default = 10;
        description = "Right padding of the bar.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Shell integration
    home.shellAliases = shellAliases;
    programs.zsh.initContent = brewIntegration;

    # Main sketchybar configuration
    programs.sketchybar = {
      enable = true;
      configType = "lua";
      inherit (cfg) package;
      sbarLuaPackage = pkgs.sbarlua;
      extraPackages = allPackages;

      extraLuaPackages = luaPkgs: [
        pkgs.aytordev.luaposix
        luaPkgs.dkjson
        luaPkgs.lua-cjson
      ];

      # Sbar initialization - add config dir to LUA_PATH since we use config.text
      config.text = ''
        -- Add config directory to package.path for local modules
        local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
        package.path = package.path .. ";" .. config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua"

        sbar = require("sketchybar")
        sbar.begin_config()
        require("bar")
        require("default")
        require("items")
        sbar.hotload(true)
        sbar.end_config()
        sbar.event_loop()
      '';
    };

    # Configuration files - copy Lua configs, exclude imperative files
    xdg.configFile = {
      "sketchybar" = {
        source = lib.cleanSourceWith {
          src = ./config;
          filter = name: _type: let
            baseName = baseNameOf name;
          in
            baseName
            != "sketchybarrc"
            && baseName != "install_dependencies.sh"
            # Only exclude the root init.lua (dead code), not items/init.lua
            && !(baseName == "init.lua" && !lib.hasInfix "/items/" name);
        };
        recursive = true;
      };

      # Generated constants from Nix - bridges all configurable values to Lua
      "sketchybar/nix_constants.lua".text = ''
        -- Auto-generated by Nix. Do not edit manually.
        return {
          colors = ${toLuaTable sketchybarColors},
          fonts = {
            text = "${cfg.fonts.text}",
            icon = "${cfg.fonts.icon}",
            size = ${toString cfg.fonts.size}
          },
          settings = {
            icons_style = "${cfg.iconsStyle}"
          },
          bar = {
            height = ${toString cfg.bar.height},
            blur_radius = ${toString cfg.bar.blurRadius},
            shadow = ${
          if cfg.bar.shadow
          then "true"
          else "false"
        },
            sticky = ${
          if cfg.bar.sticky
          then "true"
          else "false"
        },
            topmost = "${cfg.bar.topmost}",
            padding_left = ${toString cfg.bar.paddingLeft},
            padding_right = ${toString cfg.bar.paddingRight}
          }
        }
      '';

      "sketchybar/helpers/icon_map.lua".source = "${pkgs.aytordev.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua";
    };
  };
}
