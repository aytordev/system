{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) enum float;

  cfg = config.aytordev.services.jankyborders;
  themeCfg = config.aytordev.theme;

  # JankyBorders is a palette-generated hybrid consumer: it has no upstream
  # resource for any family, so the resolver always selects the palette-derived
  # colors. See ./theme.nix for the active/inactive semantic role contract.
  jankybordersTheme = import ./theme.nix {
    inherit (lib.aytordev) resolveApp;
  };

  themeResolution = jankybordersTheme.resolve {
    inherit (themeCfg) variant;
  };
in {
  options.aytordev.services.jankyborders = {
    enable = mkEnableOption "JankyBorders window border highlighting";
    package = lib.mkPackageOption pkgs "jankyborders" {};

    width = mkOption {
      type = float;
      default = 6.0;
      description = "Border width in pixels.";
    };

    style = mkOption {
      type = enum [
        "round"
        "square"
      ];
      default = "round";
      description = "Border corner style.";
    };
  };

  config = mkIf cfg.enable {
    services.jankyborders = {
      enable = true;
      inherit (cfg) package;

      settings =
        {
          inherit (cfg) style;
          inherit (cfg) width;
          hidpi = "off";
        }
        // lib.optionalAttrs (themeResolution.kind == "generated") (
          jankybordersTheme.colors {inherit (themeCfg) palette;}
        );
    };
  };
}
