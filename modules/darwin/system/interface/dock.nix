{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.system.interface;
  mkHotCorners = corners: lib.mapAttrs' (pos: action: lib.nameValuePair "wvous-${pos}-corner" action) corners;
in {
  config = lib.mkIf cfg.enable {
    system.defaults.dock =
      {
        autohide = true;
        autohide-delay = 0.20;
        autohide-time-modifier = 1.0;
        enable-spring-load-actions-on-all-items = false;
        show-process-indicators = true;
        show-recents = false;
        showhidden = true;
        slow-motion-allowed = false;
        largesize = 16;
        mineffect = "genie";
        orientation = "left";
        tilesize = 43;
        persistent-apps = [
          "/System/Applications/Apps.app"
          "/Applications/Ghostty.app"
        ];
        persistent-others = [
          "/System/Applications/System Settings.app"
        ];
      }
      // mkHotCorners {
        bl = 2;
        br = 12;
        tl = 14;
        tr = 4;
      };
  };
}
