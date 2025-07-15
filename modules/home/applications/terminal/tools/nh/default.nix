{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.applications.terminal.tools.nh;
  inherit (lib) mkIf;

  # Default configuration values
  defaultConfig = {
    clean.enable = true;
    flake = "/Users/${inputs.secrets.username}";
  };

  nhPackage = pkgs.nh.overrideAttrs {
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/nix-community/nh/pull/340.patch";
        hash = "sha256-AYrogYKEbwCO4MWoiGIt9I5gDv8XiPEA7DiPaYtNnD8=";
      })
    ];
  };

  # Platform-specific nixre alias
  nixreAlias = "nh ${if pkgs.stdenv.hostPlatform.isLinux then "os" else "darwin"} switch";

in {
  options.applications.terminal.tools.nh = {
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
      flake = cfg.flake;
    };

    home = {
      sessionVariables = {
        NH_SEARCH_PLATFORM = 1;
      };
      shellAliases.nixre = nixreAlias;
    };
  };
}
