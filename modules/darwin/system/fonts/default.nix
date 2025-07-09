# System Fonts Module for Darwin (macOS)
#
# Version: 3.0.0
# Last Updated: 2025-06-27
#
# This module extends the shared fonts module with Darwin-specific configurations.
# It maintains backward compatibility with the collections system while using the
# shared fonts implementation.
#
# Example usage:
# ```nix
# system.fonts = {
#   enable = true;
#   default = "MonaspaceNe";
#   collections = [ "system" "developer" ];
#   smoothing = {
#     enable = true;
#     level = 1;  # Light smoothing
#   };
# };
# ```
{
  config,
  lib,
  pkgs,
  libraries,
  ...
}: let
  inherit (lib) types mkIf mkOption;

  # Import shared fonts module
  sharedFonts = import (libraries.relativeToRoot "modules/shared/system/fonts");

  # Darwin-specific font configuration
  cfg = config.system.fonts;
in {
  imports = [sharedFonts];

  options.system.fonts = {
    # Font smoothing configuration for macOS
    smoothing = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font smoothing (subpixel antialiasing) on macOS";
      };

      level = mkOption {
        type = types.ints.between 0 3;
        default = 1;
        description = ''
          Font smoothing level (0-3):
          - 0: No smoothing
          - 1: Light smoothing (default)
          - 2: Medium smoothing
          - 3: Strong smoothing
        '';
      };
    };
  };

  config = {
    # Darwin-specific font configuration
    environment.variables = {
      # Enable subpixel rendering on non-Apple LCDs
      "INFINALITY_FT_FILTER_PARAMS" = "truetype:interpreter-version=35";
      # LOG_ICONS is already set by the shared module
    };

    # Configure font smoothing if enabled
    system.defaults.NSGlobalDomain = mkIf (cfg.smoothing != null) {
      AppleFontSmoothing =
        if cfg.smoothing.enable
        then cfg.smoothing.level
        else 0;
    };

    # Install fonts directly from Nix packages
    fonts.packages = lib.optionals (cfg != null && cfg.fonts != null) cfg.fonts;

    # Add assertions for font smoothing configuration
    assertions =
      (
        if cfg.smoothing != null
        then [
          {
            assertion = cfg.smoothing.level >= 0 && cfg.smoothing.level <= 3;
            message = "Font smoothing level must be between 0 and 3";
          }
        ]
        else []
      )
      ++ (
        if cfg.smoothing != null && cfg.smoothing.enable
        then [
          {
            assertion = config.system.primaryUser != null;
            message = ''
              The option `system.fonts.smoothing.enable` requires `system.primaryUser` to be set.
              Please set `system.primaryUser` to the name of the primary user.
            '';
          }
        ]
        else []
      );
  };
}
