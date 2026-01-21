{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) enum float nullOr;

  cfg = config.aytordev.services.jankyborders;
  themeCfg = config.aytordev.theme;

  # Get colors from central theme palette
  palette = themeCfg.palette;
in
{
  options.aytordev.services.jankyborders = {
    enable = mkEnableOption "JankyBorders window border highlighting";

    # Theme override (optional - uses global theme by default)
    themeOverride = mkOption {
      type = nullOr (enum ["wave" "dragon" "lotus"]);
      default = null;
      description = ''
        Override the global Kanagawa theme variant for JankyBorders only.
        If null (default), uses the global theme from aytordev.theme.variant.
      '';
    };

    width = mkOption {
      type = float;
      default = 6.0;
      description = "Border width in pixels.";
    };

    style = mkOption {
      type = enum ["round" "square"];
      default = "round";
      description = "Border corner style.";
    };
  };

  config = mkIf cfg.enable {
    services.jankyborders = {
      enable = true;

      settings = {
        style = cfg.style;
        width = cfg.width;
        hidpi = "off";
        # Use accent color for active, border color for inactive
        active_color = palette.accent.sketchybar;
        inactive_color = palette.border.sketchybar;
      };
    };
  };
}
