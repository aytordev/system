# Sudo Configuration Module for Darwin
#
# This module configures sudo with Touch ID authentication and custom settings
# for macOS systems. It enables secure authentication with Touch ID and sets
# a reasonable default timeout for sudo credentials.
#
# Version: 1.0.0
# Last Updated: 2025-07-08
{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.darwin.security.sudo;
in {
  ####################################
  # Module Options
  ####################################
  options.darwin.security.sudo = {
    enable = mkEnableOption "sudo configuration with Touch ID support";
  };

  ####################################
  # Module Implementation
  ####################################
  config = mkIf cfg.enable {
    security = {
      # Configure PAM for sudo with Touch ID support
      pam.services = {
        sudo_local = {
          reattach = true;
          touchIdAuth = true;
        };
      };

      # Set sudo timeout to 30 minutes
      sudo.extraConfig = ''
        # Set sudo timeout to 30 minutes (1800 seconds)
        Defaults timestamp_timeout=30
        
        # Preserve environment variables (adjust as needed)
        Defaults env_keep += "HOME"
        Defaults env_keep += "PATH"
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';
    };
  };
}
