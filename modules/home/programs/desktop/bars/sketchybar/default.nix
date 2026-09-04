{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.bars.sketchybar;
  themeCfg = config.aytordev.theme;

  luaGen = import ./lua-gen.nix {
    inherit
      lib
      pkgs
      cfg
      themeCfg
      ;
  };
in {
  options.aytordev.programs.desktop.bars.sketchybar =
    import ./options.nix {inherit lib;}
    // {
      # Set package default here where pkgs is available
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.sketchybar;
        defaultText = lib.literalExpression "pkgs.sketchybar";
        description = "The Sketchybar package to use.";
      };
    };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    # restart-sketchybar and the brew/mas refresh are shell-agnostic commands;
    # publish them as bins so no per-shell command-substitution aliases are
    # needed (the bin name equals the command name). `forced` is the manual
    # refresh trigger the brew widget subscribes to (see config/items/widgets/brew.lua).
    home.packages = [
      (pkgs.writeShellApplication {
        name = "restart-sketchybar";
        runtimeInputs = [pkgs.coreutils];
        text = ''
          exec launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.sketchybar"
        '';
      })
      (pkgs.writeShellApplication {
        name = "sketchybar-brew";
        text = ''
          command brew "$@" && ${lib.getExe cfg.package} --trigger forced
        '';
      })
      (pkgs.writeShellApplication {
        name = "sketchybar-mas";
        text = ''
          command mas "$@" && ${lib.getExe cfg.package} --trigger forced
        '';
      })
    ];

    # Main sketchybar configuration
    programs.sketchybar = {
      enable = true;
      configType = "lua";
      inherit (cfg) package;
      sbarLuaPackage = pkgs.sbarlua;
      extraPackages = luaGen.allPackages;

      extraLuaPackages = luaPkgs: let
        patchedRockspec = pkgs.runCommand "luaposix-36.2.1-1.rockspec" {} ''
          sed 's/lua >= 5.1, < 5.5/lua >= 5.1/' ${
            pkgs.fetchurl {
              url = "https://luarocks.org/manifests/gvvaughan/luaposix-36.2.1-1.rockspec";
              hash = "sha256-mlv8WUAdD+pfMUXGVh3zGgknfMoKDzFcyoeOyEtJj1Y=";
            }
          } > $out
        '';
        luaposix = luaPkgs.buildLuarocksPackage {
          pname = "luaposix";
          version = "36.2.1";
          src = pkgs.fetchFromGitHub {
            owner = "luaposix";
            repo = "luaposix";
            rev = "v36.2.1";
            hash = "sha256-oxHH7RmaEGLU1tSlFhtf7F6CKOSRaNamq7QxtWyfwtI=";
          };
          knownRockspec = patchedRockspec.outPath;
          disabled = false;
        };
      in [
        luaposix
        luaPkgs.dkjson
        luaPkgs.lua-cjson
      ];

      config.text = luaGen.mainConfig;
    };

    # Configuration files
    xdg.configFile = luaGen.configFiles;
  };
}
