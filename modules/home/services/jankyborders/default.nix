{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) enum float;

  cfg = config.aytordev.services.jankyborders;

  # Kanagawa color schemes for borders
  themes = {
    wave = {
      active = "0xff7e9cd8";   # crystalBlue
      inactive = "0xff2a2a37"; # sumiInk4
    };
    dragon = {
      active = "0xff8ba4b0";   # dragonBlue2
      inactive = "0xff282727"; # dragonBlack4
    };
    lotus = {
      active = "0xff4d699b";   # lotusBlue4
      inactive = "0xffe7dba0"; # lotusWhite4
    };
  };

  selectedTheme = themes.${cfg.theme};
in
{
  options.aytordev.services.jankyborders = {
    enable = mkEnableOption "JankyBorders window border highlighting";

    theme = mkOption {
      type = enum ["wave" "dragon" "lotus"];
      default = "wave";
      description = "Kanagawa theme variant to use for border colors.";
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
        active_color = selectedTheme.active;
        inactive_color = selectedTheme.inactive;
      };
    };
  };
}
