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

  config = lib.mkIf cfg.enable {
    # Shell integration
    home.shellAliases = luaGen.shellAliases;
    programs.zsh.initContent = luaGen.brewIntegration;

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
