# Darwin-specific Nix Configuration
#
# This module extends the shared Nix configuration with Darwin-specific settings.
# It imports the shared Nix module and applies Darwin-specific customizations.
#
# Version: 1.0.0
# Last Updated: 2025-06-27
{
  config,
  libraries,
  lib,
  ...
}: let
  # Import the shared Nix module
  sharedNix = import (libraries.relativeToRoot "modules/shared/nix/default.nix");
in {
  # Import the shared Nix module
  imports = [sharedNix];

  # Darwin-specific Nix configuration
  config = {
    nix = {
      # Additional Darwin-specific Nix options
      extraOptions = ''
        # Bail early on missing cache hits
        connect-timeout = 10
        keep-going = true
      '';

      # Configure garbage collection schedule
      gc = {
        interval = [
          {
            Hour = 3;
            Minute = 15;
            Weekday = 1;
          }
        ];
      };

      # Optimize nix store after cleaning
      optimise.interval = lib.lists.forEach config.nix.gc.interval (e: {
        inherit (e) Minute Weekday;
        Hour = e.Hour + 1;
      });

      # Darwin-specific Nix settings
      settings = {
        # Set build users group for Darwin
        build-users-group = "nixbld";

        # Additional sandbox paths required for Darwin
        extra-sandbox-paths = [
          "/System/Library/Frameworks"
          "/System/Library/PrivateFrameworks"
          "/usr/lib"
          "/private/tmp"
          "/private/var/tmp"
          "/usr/bin/env"
        ];

        # Limit HTTP connections to prevent networking issues on Darwin
        http-connections = lib.mkForce 25;

        # Use relaxed sandbox mode due to known issues on Darwin
        sandbox = lib.mkForce "relaxed";
      };
    };
  };
}
