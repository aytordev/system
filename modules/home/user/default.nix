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
  inherit (lib) mkIf mkOption types mkEnableOption mkMerge mkDefault;
  inherit (lib.types) str package bool nullOr;
  inherit (builtins) baseNameOf;

  cfg = config.user;

  home-directory =
    if cfg.name == null
    then null
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.user = {
    enable = mkEnableOption "user configuration";

    email = mkOption {
      type = str;
      default = variables.useremail;
      description = "The email address of the user";
    };

    fullName = mkOption {
      type = str;
      default = variables.userfullname;
      description = "The full name of the user";
    };

    home = mkOption {
      type = nullOr str;
      default = home-directory;
      defaultText = "Derived from username and platform";
      description = "The user's home directory path";
    };

    icon = mkOption {
      type = nullOr package;
      default = null;
      description = "The profile picture to use for the user";
    };

    name = mkOption {
      type = nullOr str;
      default = variables.username;
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

      home = {
        file =
          {
            "Desktop/.keep".text = "";
            "Documents/.keep".text = "";
            "Downloads/.keep".text = "";
            "Music/.keep".text = "";
            "Pictures/.keep".text = "";
            "Videos/.keep".text = "";
          }
          // lib.optionalAttrs (cfg.icon != null) {
            ".face".source = cfg.icon;
            ".face.icon".source = cfg.icon;
            "Pictures/${baseNameOf cfg.icon}".source = cfg.icon;
          };

        homeDirectory = mkDefault cfg.home;

        username = mkDefault cfg.name;
      };
    }
  ]);
}
