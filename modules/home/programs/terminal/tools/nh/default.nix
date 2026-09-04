{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.nh;
  inherit (lib) mkIf;
  defaultConfig = {
    clean.enable = true;
    flake = null;
  };
  platform =
    if pkgs.stdenv.hostPlatform.isLinux
    then "os"
    else "darwin";
  nixAliases = lib.mapAttrs (_name: sub: "nh ${platform} ${sub}") {
    nixre = "switch";
    nixrb = "boot";
    nixrt = "test";
  };
in {
  options.aytordev.programs.terminal.tools.nh = {
    enable = lib.mkEnableOption "nh";
    package = lib.mkPackageOption pkgs "nh" {};
    clean = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.clean.enable;
        description = "Enable nh clean functionality";
      };
    };
    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = defaultConfig.flake;
      description = "Path to the mutable flake checkout used by nh";
    };
  };
  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      inherit (cfg) package;
      clean.enable = cfg.clean.enable;
      inherit (cfg) flake;
    };
    home = {
      sessionVariables = {
        NH_SEARCH_PLATFORM = 1;
      };
      shellAliases = nixAliases;
    };
  };
}
