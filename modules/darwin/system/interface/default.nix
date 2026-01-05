{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption mapAttrs' nameValuePair;

  cfg = config.aytordev.system.interface;

  mkHotCorners = corners: mapAttrs' (pos: action: nameValuePair "wvous-${pos}-corner" action) corners;
in
{
  options.aytordev.system.interface = {
    enable = mkEnableOption "macOS interface";
  };

  config = mkIf cfg.enable {
    system.activationScripts.extraActivation.text = ''
      echo "Creating screenshots directory..."
      mkdir -p "$HOME/Pictures/screenshots"
      touch "$HOME/Pictures/screenshots/.keep"
      chown "$USER" "$HOME/Pictures/screenshots"
      chown "$USER" "$HOME/Pictures/screenshots/.keep"
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    system = {
      defaults = mkMerge [
        {
          ActivityMonitor = {
            IconType = 6;
            OpenMainWindow = true;
            ShowCategory = 101;
            SortColumn = "CPUUsage";
            SortDirection = 0;
          };
        }
        {
          dock =
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
                "/System/programs/Apps.app"
                "/programs/Ghostty.app"
              ];
              persistent-others = [
                "/System/programs/System Settings.app"
              ];
            }
            // mkHotCorners {
              bl = 2;
              br = 12;
              tl = 14;
              tr = 4;
            };
        }
        {
          finder = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = false;
            CreateDesktop = true;
            FXDefaultSearchScope = "SCcf";
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "clmv";
            ShowPathbar = true;
            ShowStatusBar = true;
            _FXShowPosixPathInTitle = false;
            _FXSortFoldersFirst = true;
            QuitMenuItem = false;
          };
        }
        {
          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            AppleShowScrollBars = "WhenScrolling";
            "com.apple.trackpad.enableSecondaryClick" = true;
            "com.apple.trackpad.forceClick" = false;
            "com.apple.trackpad.scaling" = 2.0;
            "com.apple.keyboard.fnState" = false;
            "com.apple.mouse.tapBehavior" = 1;
            "com.apple.swipescrolldirection" = true;
            _HIHideMenuBar = false;
            NSAutomaticWindowAnimationsEnabled = true;
            NSDocumentSaveNewDocumentsToCloud = false;
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
            NSScrollAnimationEnabled = true;
            NSTableViewDefaultSizeMode = 3;
            NSWindowShouldDragOnGesture = false;
          };
          LaunchServices.LSQuarantine = false;
          loginwindow = {
            DisableConsoleAccess = true;
            GuestEnabled = false;
          };
          menuExtraClock = {
            IsAnalog = false;
            Show24Hour = true;
            ShowAMPM = false;
            ShowDate = 1;
            ShowDayOfMonth = true;
            ShowDayOfWeek = true;
            ShowSeconds = false;
          };
          screencapture = {
            show-thumbnail = false;
            type = "png";
            location = "~/Pictures/screenshots/";
            disable-shadow = true;
          };
          screensaver.askForPassword = true;
          spaces.spans-displays = true;
          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        }
      ];
    };
  };
}
