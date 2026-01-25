{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.nh;
  inherit (lib) mkIf;
  defaultConfig = {
    clean.enable = true;
    flake = "/Users/${inputs.secrets.username}";
  };
  nhPackage = pkgs.nh;
  nixreAlias = "nh ${
    if pkgs.stdenv.hostPlatform.isLinux
    then "os"
    else "darwin"
  } switch";
in {
  options.aytordev.programs.terminal.tools.nh = {
    enable = lib.mkEnableOption "nh";
    clean = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.clean.enable;
        description = "Enable nh clean functionality";
      };
    };
    flake = lib.mkOption {
      type = lib.types.str;
      default = defaultConfig.flake;
      description = "Path to the flake to use with nh";
    };
  };
  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      package = nhPackage;
      clean.enable = cfg.clean.enable;
      inherit (cfg) flake;
    };
    home = {
      sessionVariables = {
        NH_SEARCH_PLATFORM = 1;
      };
      shellAliases.nixre = nixreAlias;
    };
  };
}
