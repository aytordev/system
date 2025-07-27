{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf getExe;

  shellAliases = {
    restart-sketchybar = ''launchctl kickstart -k gui/"$(id -u)"/org.nix-community.home.sketchybar'';
  };

  cfg = config.applications.desktop.bars.sketchybar;
in
{
  options.applications.desktop.bars.sketchybar = {
    enable = lib.mkEnableOption "Sketchybar status bar";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sketchybar;
      defaultText = lib.literalExpression "pkgs.sketchybar";
      description = "The Sketchybar package to use.";
    };
    
    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
      description = "Extra packages needed for Sketchybar plugins and functionality.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.shellAliases = shellAliases;

      programs.sketchybar = {
        enable = true;
        configType = "lua";
        package = cfg.package;
        sbarLuaPackage = pkgs.sbarlua;

        extraPackages = with pkgs; [
          sbarlua
        ];

        config = {
          source = ./config;
          recursive = true;
        };
      };
    }
    {
      xdg.configFile = {
        "sketchybar/sketchybarrc".text = ''
          #!/usr/bin/env lua
          require("init")
        '';
        "sketchybar/sketchybarrc".executable = true;

        "sketchybar/helpers/icon_map.lua".source =
        "${pkgs.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua";
      };
    }
  ]);
}
