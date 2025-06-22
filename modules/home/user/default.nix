# User Module
#
# This module provides a standardized way to configure user accounts and their home directories
# across different platforms. It handles user-specific settings, home directory structure,
# and ensures consistent user environment setup.
#
# Maintainer: Aytor Vicente Martinez <me@aytor.dev>
# Last Updated: 2025-06-23
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

  # Calculate the default home directory based on the platform
  # @param name The username
  # @return The absolute path to the user's home directory
  home-directory =
    if cfg.name == null
    then throw "user.name must be set"
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.user = {
    # Enable user configuration
    enable = mkEnableOption "user account configuration";

    # User's home directory configuration
    home = mkOption {
      type = nullOr str;
      default = home-directory;
      defaultText = "Derived from username and platform";
      description = ''
        Absolute path to the user's home directory.
        Defaults to /Users/username on Darwin and /home/username on other platforms.
      '';
    };

    # Username configuration
    name = mkOption {
      type = nullOr str;
      default = "aytordev";
      description = "The username for the account";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Input validation
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

      # Create standard directories in the user's home folder
      home.file = {
        "Desktop/.keep".text = "";
        "Documents/.keep".text = "";
        "Downloads/.keep".text = "";
        "Music/.keep".text = "";
        "Pictures/.keep".text = "";
        "Videos/.keep".text = "";
      };

      # Ensure the home directory is set correctly
      home.homeDirectory = mkForce cfg.home;

      # Set the username in home-manager
      home.username = mkDefault cfg.name;
    }
  ]);
}
