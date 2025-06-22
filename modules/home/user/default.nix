# User Module
#
# This module configures user accounts and their home directories.
# It handles user-specific settings, shell aliases, and home directory structure.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption mkMerge mkDefault mkForce;
  inherit (lib.types) str package bool nullOr;
  inherit (builtins) baseNameOf;

  cfg = config.user;

  home-directory =
    if cfg.name == null
    then throw "user.name must be set"
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.user = {
    enable = mkEnableOption "user configuration";

    home = mkOption {
      type = nullOr str;
      default = home-directory;
      defaultText = "Derived from username and platform";
      description = "The user's home directory path";
    };

    name = mkOption {
      type = nullOr str;
      default = "aytordev";
      description = "The username";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "user.home must be set";
        }
      ];

      home.file = {
        "Desktop/.keep".text = "";
        "Documents/.keep".text = "";
        "Downloads/.keep".text = "";
        "Music/.keep".text = "";
        "Pictures/.keep".text = "";
        "Videos/.keep".text = "";
      };

      home.homeDirectory = mkForce cfg.home;

      home.username = mkDefault cfg.name;
    }
  ]);
}
