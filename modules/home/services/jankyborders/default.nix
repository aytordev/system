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

  # Get colors from central theme palette
  inherit (themeCfg) palette;
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

      settings = {
        inherit (cfg) style;
        inherit (cfg) width;
        hidpi = "off";
        # Active uses the bright yellow accent; inactive uses the border role.
        # Using two distinct semantic roles keeps active/inactive distinguishable
        # in every theme family (e.g. Kanagawa Dragon, where both yellows match).
        active_color = palette.yellow_bright.sketchybar;
        inactive_color = palette.border.sketchybar;
      };
    };
  };
}
