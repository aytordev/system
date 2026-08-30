{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.programs.desktop.communications.thunderbird;
in {
  options.aytordev.programs.desktop.communications.thunderbird = {
    enable = mkEnableOption "Thunderbird email client";
    package = lib.mkPackageOption pkgs "Thunderbird" {
      default = "thunderbird-latest";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs.thunderbird = {
      enable = true;
      inherit (cfg) package;
      profiles = {};
      settings = {
        # Search Settings -> Config Editor to grab these.
        "mail.folder.views.version" = 1;
        "mail.uidensity" = 2;
        "mailnews.default_sort_order" = 2;
        "mailnews.default_sort_type" = 18;
        "mailnews.message_display.disable_remote_image" = false;
        "mailnews.start_page.enabled" = false;
        "widget.use-xdg-desktop-portal" = true;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.wayland.fractional-scale.enabled" = true;
      };
    };
  };
}
