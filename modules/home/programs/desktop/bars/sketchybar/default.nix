{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.bars.sketchybar;
  themeCfg = config.aytordev.theme;

  luaGen = import ./lua-gen.nix {inherit lib pkgs cfg themeCfg;};
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

      extraLuaPackages = luaPkgs: [
        pkgs.aytordev.luaposix
        luaPkgs.dkjson
        luaPkgs.lua-cjson
      ];

      config.text = luaGen.mainConfig;
    };

    # Configuration files
    xdg.configFile = luaGen.configFiles;
  };
}
