{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkMerge
    mkEnableOption
    ;

  cfg = config.aytordev.system.interface;
  userHome = config.users.users.${config.aytordev.user.name}.home;
in {
  imports = [./dock.nix];

  options.aytordev.system.interface = {
    enable = mkEnableOption "macOS interface";
  };

  config = mkIf cfg.enable {
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
            _HIHideMenuBar = true;
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
            location = "${userHome}/Pictures/screenshots/";
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
