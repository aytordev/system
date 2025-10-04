{
  config,
  lib,
  ...
}:
with lib; let
  interfaceTypes = with types; {
    activityMonitorType = submodule {
      options = {
        iconType = mkOption {
          type = ints.between 0 7;
          default = 6;
          description = "Activity Monitor icon type (0-7)";
        };
        openMainWindow = mkOption {
          type = bool;
          default = true;
          description = "Whether to open the main window on launch";
        };
        showCategory = mkOption {
          type = ints.positive;
          default = 101;
          description = "Which processes to show";
        };
        sortColumn = mkOption {
          type = str;
          default = "CPUUsage";
          description = "Column to sort by";
        };
        sortDirection = mkOption {
          type = ints.between 0 1;
          default = 0;
          description = "Sort direction (0 = descending, 1 = ascending)";
        };
      };
    };
    dockType = submodule {
      options = {
        autohide = mkOption {
          type = bool;
          default = true;
          description = "Automatically hide the dock";
        };
        autohideDelay = mkOption {
          type = float;
          default = 0.20;
          description = "Delay before dock hides in seconds";
        };
        autohideTimeModifier = mkOption {
          type = float;
          default = 1.0;
          description = "Animation speed modifier for hiding the dock";
        };
        enableSpringLoadActions = mkOption {
          type = bool;
          default = false;
          description = "Enable spring-load actions on all dock items";
        };
        largesize = mkOption {
          type = ints.positive;
          default = 16;
          description = "Size of magnified icons";
        };
        mineffect = mkOption {
          type = enum ["genie" "scale" "suck"];
          default = "genie";
          description = "Minimize/maximize effect";
        };
        orientation = mkOption {
          type = enum ["left" "bottom" "right"];
          default = "left";
          description = "Dock position";
        };
        showProcessIndicators = mkOption {
          type = bool;
          default = true;
          description = "Show process indicators for running applications";
        };
        showRecents = mkOption {
          type = bool;
          default = false;
          description = "Show recent applications";
        };
        tilesize = mkOption {
          type = ints.positive;
          default = 43;
          description = "Size of dock icons";
        };
        hotCorners = mkOption {
          type = attrsOf int;
          default = {
            bl = 2;
            br = 12;
            tl = 14;
            tr = 4;
          };
          description = "Hot corner actions";
        };
      };
    };
    finderType = submodule {
      options = {
        fxPreferredViewStyle = mkOption {
          type = enum ["Nlsv" "icnv" "clmv" "Flwv"];
          default = "clmv";
          description = "Default Finder view style";
        };
        showAllExtensions = mkOption {
          type = bool;
          default = true;
          description = "Show all file extensions in Finder";
        };
        showHiddenFiles = mkOption {
          type = bool;
          default = false;
          description = "Show hidden files in Finder";
        };
        showPathbar = mkOption {
          type = bool;
          default = true;
          description = "Show path bar in Finder windows";
        };
        showStatusBar = mkOption {
          type = bool;
          default = true;
          description = "Show status bar in Finder windows";
        };
        sortFoldersFirst = mkOption {
          type = bool;
          default = true;
          description = "Sort folders before files";
        };
      };
    };
    globalDomainType = submodule {
      options = {
        appleInterfaceStyle = mkOption {
          type = enum ["Dark" "Light" "Auto"];
          default = "Dark";
          description = "System-wide appearance";
        };
        appleShowScrollBars = mkOption {
          type = enum ["Automatic" "WhenScrolling" "Always"];
          default = "WhenScrolling";
          description = "When to show scrollbars";
        };
        initialKeyRepeat = mkOption {
          type = ints.positive;
          default = 25;
          description = "Initial key repeat delay (ms)";
        };
        keyRepeat = mkOption {
          type = ints.positive;
          default = 2;
          description = "Key repeat rate (lower is faster)";
        };
      };
    };
  };
  defaults = {
    activityMonitor = {
      iconType = 6;
      openMainWindow = true;
      showCategory = 101;
      sortColumn = "CPUUsage";
      sortDirection = 0;
    };
    dock = {
      autohide = true;
      autohideDelay = 0.20;
      autohideTimeModifier = 1.0;
      enableSpringLoadActions = false;
      largesize = 16;
      mineffect = "genie";
      orientation = "left";
      showProcessIndicators = true;
      showRecents = false;
      tilesize = 43;
      hotCorners = {
        bl = 2;
        br = 12;
        tl = 14;
        tr = 4;
      };
    };
    finder = {
      fxPreferredViewStyle = "clmv";
      showAllExtensions = true;
      showHiddenFiles = false;
      showPathbar = true;
      showStatusBar = true;
      sortFoldersFirst = true;
    };
    globalDomain = {
      appleInterfaceStyle = "Dark";
      appleShowScrollBars = "WhenScrolling";
      initialKeyRepeat = 25;
      keyRepeat = 2;
    };
  };
  mkHotCorners = corners: mapAttrs' (pos: action: nameValuePair "wvous-${pos}-corner" action) corners;
in {
  options.system.interface = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system interface configuration (auto-enabled when module is imported)";
    };
    activityMonitor = mkOption {
      type = interfaceTypes.activityMonitorType;
      default = defaults.activityMonitor;
      description = "Activity Monitor settings";
    };
    dock = mkOption {
      type = interfaceTypes.dockType;
      default = defaults.dock;
      description = "Dock configuration";
    };
    finder = mkOption {
      type = interfaceTypes.finderType;
      default = defaults.finder;
      description = "Finder settings";
    };
    globalDomain = mkOption {
      type = interfaceTypes.globalDomainType;
      default = defaults.globalDomain;
      description = "Global domain settings";
    };
  };
  config = mkIf config.system.interface.enable {
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
            IconType = config.system.interface.activityMonitor.iconType;
            OpenMainWindow = config.system.interface.activityMonitor.openMainWindow;
            ShowCategory = config.system.interface.activityMonitor.showCategory;
            SortColumn = config.system.interface.activityMonitor.sortColumn;
            SortDirection = config.system.interface.activityMonitor.sortDirection;
          };
        }
        {
          dock =
            {
              autohide = config.system.interface.dock.autohide;
              autohide-delay = config.system.interface.dock.autohideDelay;
              autohide-time-modifier = config.system.interface.dock.autohideTimeModifier;
              enable-spring-load-actions-on-all-items = config.system.interface.dock.enableSpringLoadActions;
              show-process-indicators = config.system.interface.dock.showProcessIndicators;
              show-recents = config.system.interface.dock.showRecents;
              showhidden = true;
              slow-motion-allowed = false;
              largesize = config.system.interface.dock.largesize;
              mineffect = config.system.interface.dock.mineffect;
              orientation = config.system.interface.dock.orientation;
              tilesize = config.system.interface.dock.tilesize;
              persistent-apps = [
                "/System/Applications/Apps.app"
                "/Applications/Ghostty.app"
              ];
              persistent-others = [
                "/System/Applications/System Settings.app"
              ];
            }
            // mkHotCorners config.system.interface.dock.hotCorners;
        }
        {
          finder = {
            AppleShowAllExtensions = config.system.interface.finder.showAllExtensions;
            AppleShowAllFiles = config.system.interface.finder.showHiddenFiles;
            CreateDesktop = true;
            FXDefaultSearchScope = "SCcf";
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = config.system.interface.finder.fxPreferredViewStyle;
            ShowPathbar = config.system.interface.finder.showPathbar;
            ShowStatusBar = config.system.interface.finder.showStatusBar;
            _FXShowPosixPathInTitle = false;
            _FXSortFoldersFirst = config.system.interface.finder.sortFoldersFirst;
            QuitMenuItem = false;
          };
        }
        {
          NSGlobalDomain = {
            AppleInterfaceStyle = config.system.interface.globalDomain.appleInterfaceStyle;
            AppleShowScrollBars = config.system.interface.globalDomain.appleShowScrollBars;
            InitialKeyRepeat = config.system.interface.globalDomain.initialKeyRepeat;
            KeyRepeat = config.system.interface.globalDomain.keyRepeat;
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
