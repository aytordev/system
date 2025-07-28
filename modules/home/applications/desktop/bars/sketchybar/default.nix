{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf getExe;

  # Get the final package with proper path wrapping
  finalPackage = pkgs.sketchybar.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/sketchybar \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.coreutils
          pkgs.gnused
          pkgs.gnugrep
        ]}
    '';
  });

  # Shell aliases for common operations
  shellAliases = {
    restart-sketchybar = ''launchctl kickstart -k gui/"$(id -u)"/org.nix-community.home.sketchybar'';
  };

  cfg = config.applications.desktop.bars.sketchybar;
in
{
  # Define the module options under the expected path
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

      # Internal configuration using home-manager's programs.sketchybar module
      programs.sketchybar = {
        enable = true;
        configType = "lua";
        package = cfg.package;
        sbarLuaPackage = pkgs.sbarlua;

        extraPackages = with pkgs; [
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
        ] ++ cfg.extraPackages
          ++ lib.optionals (osConfig.services ? yabai && osConfig.services.yabai.enable) [
            osConfig.services.yabai.package
          ]
          ++ lib.optionals (config.programs ? aerospace && config.programs.aerospace.enable) [
            config.programs.aerospace.package
          ];

        config = {
          source = ./config;
          recursive = true;
        };
      };
    }
    {
      programs.zsh.initContent = ''
        brew() {
          command brew "$@" && ${getExe finalPackage} --trigger brew_update
        }

        mas() {
          command mas "$@" && ${getExe finalPackage} --trigger brew_update
        }
      '';
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
