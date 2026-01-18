{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption getExe;
  inherit (lib.types) package listOf;

  cfg = config.aytordev.programs.desktop.bars.sketchybar;

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
  conditionalPackages =
    lib.optionals (osConfig.services ? yabai && osConfig.services.yabai.enable) [
      osConfig.services.yabai.package
    ]
    ++ lib.optionals (config.programs ? aerospace && config.programs.aerospace.enable) [
      config.programs.aerospace.package
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
  };

  config = mkIf cfg.enable {
    # Shell integration
    home.shellAliases = shellAliases;
    programs.zsh.initContent = brewIntegration;

    # Main sketchybar configuration
    programs.sketchybar = {
      enable = true;
      configType = "lua";
      package = cfg.package;
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
    xdg.configFile = let
      theme = import ./theme.nix;

      # Helper to convert attributes to Lua table
      toLuaTable = attrs: let
        toLuaValue = v: if builtins.isString v then "\"${v}\"" else if builtins.isAttrs v then toLuaTable v else builtins.toString v;
        fields = lib.mapAttrsToList (k: v: "${k} = ${toLuaValue v}") attrs;
      in "{\n${builtins.concatStringsSep ",\n" fields}\n}";
    in {
      "sketchybar" = {
        source = lib.cleanSourceWith {
          src = ./config;
          filter = name: _type:
            let baseName = baseNameOf name;
            in baseName != "sketchybarrc"
            && baseName != "install_dependencies.sh";
        };
        recursive = true;
      };

      # Generated constants from Nix
      "sketchybar/nix_constants.lua".text = ''
        return {
          colors = ${toLuaTable theme.schemes.wave},
          fonts = {
            main = "Sketchybar App Font:Regular:16.0",
            icon = "Sketchybar App Font:Regular:16.0"
          }
        }
      '';

      "sketchybar/helpers/icon_map.lua".source = "${pkgs.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua";
    };
  };
}
