{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkOption;
  sharedFonts = import (lib.getFile "modules/shared/system/fonts");
  cfg = config.system.fonts;
in {
  imports = [sharedFonts];
  options.system.fonts = {
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
    environment.variables = {
      "INFINALITY_FT_FILTER_PARAMS" = "truetype:interpreter-version=35";
    };
    system.defaults.NSGlobalDomain = mkIf (cfg.smoothing != null) {
      AppleFontSmoothing =
        if cfg.smoothing.enable
        then cfg.smoothing.level
        else 0;
    };
    fonts.packages = lib.optionals (cfg != null && cfg.fonts != null) cfg.fonts;
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
