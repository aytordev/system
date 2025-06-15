# System Interface Configuration Module for Darwin (macOS)
#
# Version: 2.0.0
# Last Updated: 2025-06-15
#
# This module provides comprehensive configuration for the macOS system interface,
# including Dock, Finder, and system-wide appearance settings.
{
  config,
  lib,
  ...
}:
with lib; let
  # Type definitions for better type safety and documentation
  interfaceTypes = with types; {
    # Activity Monitor configuration type
    activityMonitorType = submodule {
      options = {
        iconType = mkOption {
          type = ints.between 0 7;
          default = 6; # CPU History
          description = "Activity Monitor icon type (0-7)";
        };
        openMainWindow = mkOption {
          type = bool;
          default = true;
          description = "Whether to open the main window on launch";
        };
        showCategory = mkOption {
          type = ints.positive;
          default = 101; # All Processes
          description = "Which processes to show";
        };
        sortColumn = mkOption {
          type = str;
          default = "CPUUsage";
          description = "Column to sort by";
        };
        sortDirection = mkOption {
          type = ints.between 0 1;
          default = 0; # Descending
          description = "Sort direction (0 = descending, 1 = ascending)";
        };
      };
    };

    # Dock configuration type
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
        # Hot corners (0 = no-op, 2 = Mission Control, 4 = Desktop, etc.)
        hotCorners = mkOption {
          type = attrsOf int;
          default = {
            bl = 2; # Bottom left: Mission Control
            br = 12; # Bottom right: Notification Center
            tl = 14; # Top left: Quick Notes
            tr = 4; # Top right: Desktop
          };
          description = "Hot corner actions";
        };
      };
    };

    # Finder configuration type
    finderType = submodule {
      options = {
        fxPreferredViewStyle = mkOption {
          type = enum ["Nlsv" "icnv" "clmv" "Flwv"];
          default = "clmv"; # Column View
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

    # Global domain configuration type
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

  # Default configurations
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
        bl = 2; # Mission Control
        br = 12; # Notification Center
        tl = 14; # Quick Notes
        tr = 4; # Desktop
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

  # Helper function to map hot corners to wvous-* settings
  mkHotCorners = corners: mapAttrs' (pos: action: nameValuePair "wvous-${pos}-corner" action) corners;
in {
  options.system.interface = {
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

  config = {
    system.activationScripts.extraActivation.text = ''
      # Create screenshots directory
      echo "Creating screenshots directory..."
      mkdir -p "$HOME/Pictures/screenshots"
      touch "$HOME/Pictures/screenshots/.keep"
      chown "$USER" "$HOME/Pictures/screenshots"
      chown "$USER" "$HOME/Pictures/screenshots/.keep"
      
      # Activate system settings
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    system = {

      defaults = mkMerge [
        # Activity Monitor Configuration
        #
        # Controls the behavior and appearance of the Activity Monitor application
        # - IconType: Dock icon representation (0 = CPU, 1 = Memory, 2 = Energy, etc.)
        # - OpenMainWindow: Whether to open the main window on launch
        # - ShowCategory: Default process category to display (0 = All, 1 = My, 2 = System, etc.)
        # - SortColumn: Column to sort by (e.g., "CPUUsage", "ProcessName")
        # - SortDirection: Sort order (0 = ascending, 1 = descending)
        {
          ActivityMonitor = {
            IconType = config.system.interface.activityMonitor.iconType; # Default: 6 (Network)
            OpenMainWindow = config.system.interface.activityMonitor.openMainWindow; # Default: false
            ShowCategory = config.system.interface.activityMonitor.showCategory; # Default: 0 (All Processes)
            SortColumn = config.system.interface.activityMonitor.sortColumn; # Default: "CPUUsage"
            SortDirection = config.system.interface.activityMonitor.sortDirection; # Default: 1 (descending)
          };
        }

        # Dock Configuration
        #
        # Controls the behavior and appearance of the macOS Dock
        # - autohide: Automatically hide/show the Dock
        # - autohide-delay: Delay before hiding the Dock (seconds)
        # - autohide-time-modifier: Animation speed (1.0 = normal, <1.0 = faster, >1.0 = slower)
        # - enable-spring-load-actions: Enable spring-loading for Dock items
        # - largesize: Size of magnified icons (pixels)
        # - mineffect: Animation effect for minimizing windows (genie, scale, suck)
        # - orientation: Dock position (left, bottom, right)
        # - persistent-apps: List of apps to keep in the Dock
        # - show-process-indicators: Show app indicators for running applications
        # - show-recents: Show recent applications in Dock
        # - tilesize: Default icon size (pixels, 16-128)
        # - hotCorners: Configure hot corner actions (see hot corner mapping below)
        {
          dock =
            {
              # Dock Behavior
              autohide = config.system.interface.dock.autohide; # Default: true
              autohide-delay = config.system.interface.dock.autohideDelay; # Default: 0.2s
              autohide-time-modifier = config.system.interface.dock.autohideTimeModifier; # Default: 1.0
              enable-spring-load-actions-on-all-items = config.system.interface.dock.enableSpringLoadActions; # Default: false
              show-process-indicators = config.system.interface.dock.showProcessIndicators; # Default: true
              show-recents = config.system.interface.dock.showRecents; # Default: false
              showhidden = true; # Show hidden apps as translucent
              slow-motion-allowed = false; # Disable slow-motion Dock animations

              # Dock Appearance
              largesize = config.system.interface.dock.largesize; # Default: 16 (magnified size)
              mineffect = config.system.interface.dock.mineffect; # Default: "genie"
              orientation = config.system.interface.dock.orientation; # Default: "left"
              tilesize = config.system.interface.dock.tilesize; # Default: 43

              # Dock Contents
              persistent-apps = [
                "/System/Applications/Launchpad.app"
                "/System/Applications/Utilities/Terminal.app"
              ];
              persistent-others = []; # Other persistent items (e.g., folders, stacks)
            }
            // mkHotCorners config.system.interface.dock.hotCorners; # Apply hot corner configurations
        }

        # Finder Configuration
        #
        # Controls the behavior and appearance of the macOS Finder
        # - AppleShowAllExtensions: Show all file extensions
        # - AppleShowAllFiles: Show hidden files and folders
        # - CreateDesktop: Show/hide desktop icons
        # - FXDefaultSearchScope: Default search scope (SCcf = Current Folder)
        # - FXPreferredViewStyle: Default view style (Nlsv, icnv, clmv, Flwv, glyv)
        # - ShowPathbar: Show path bar at bottom of window
        # - ShowStatusBar: Show status bar at bottom of window
        # - _FXShowPosixPathInTitle: Show full POSIX path in window title
        # - _FXSortFoldersFirst: Sort folders before files in list views
        {
          finder = {
            # File Visibility
            AppleShowAllExtensions = config.system.interface.finder.showAllExtensions; # Default: true
            AppleShowAllFiles = config.system.interface.finder.showHiddenFiles; # Default: false
            CreateDesktop = true; # Show desktop icons (true) or hide them (false)

            # Search and Navigation
            FXDefaultSearchScope = "SCcf"; # Search current folder by default
            FXEnableExtensionChangeWarning = false; # Disable extension change warnings

            # View Options
            FXPreferredViewStyle = config.system.interface.finder.fxPreferredViewStyle; # Default: "Nlsv" (List View)
            ShowPathbar = config.system.interface.finder.showPathbar; # Default: true
            ShowStatusBar = config.system.interface.finder.showStatusBar; # Default: true
            _FXShowPosixPathInTitle = false; # Don't show full path in window title
            _FXSortFoldersFirst = config.system.interface.finder.sortFoldersFirst; # Default: true

            # Advanced Options
            QuitMenuItem = false; # Disable Cmd+Q to quit Finder (prevents accidental quitting)
          };
        }

        # Global Domain Configuration
        #
        # Controls system-wide behaviors and defaults that apply across applications
        {
          NSGlobalDomain = {
            # Appearance Settings
            # - AppleInterfaceStyle: System-wide appearance (Dark, Light, or Auto)
            # - AppleShowScrollBars: When to show scrollbars
            AppleInterfaceStyle = config.system.interface.globalDomain.appleInterfaceStyle;
            AppleShowScrollBars = config.system.interface.globalDomain.appleShowScrollBars;

            # Keyboard Behavior
            # - InitialKeyRepeat: Delay before key repeat starts (ms, lower = faster)
            # - KeyRepeat: Key repeat rate (lower = faster)
            InitialKeyRepeat = config.system.interface.globalDomain.initialKeyRepeat;
            KeyRepeat = config.system.interface.globalDomain.keyRepeat;

            # Trackpad and Mouse
            # - enableSecondaryClick: Enable right-click with two fingers
            # - forceClick: Enable Force Click and haptic feedback
            # - scaling: Trackpad tracking speed (0.0 to 3.0)
            "com.apple.trackpad.enableSecondaryClick" = true;
            "com.apple.trackpad.forceClick" = false;
            "com.apple.trackpad.scaling" = 2.0;

            # Function Key Behavior
            # - fnState: Use F1-F12 as standard function keys when true
            "com.apple.keyboard.fnState" = false;

            # Mouse Settings
            # - tapBehavior: Enable tap to click (1 = enabled, 0 = disabled)
            "com.apple.mouse.tapBehavior" = 1;

            # Scrolling
            # - swipescrolldirection: Natural scrolling direction
            "com.apple.swipescrolldirection" = true;

            # Menu Bar
            # - _HIHideMenuBar: Auto-hide menu bar in fullscreen
            _HIHideMenuBar = true;

            # Window Management
            # - NSAutomaticWindowAnimationsEnabled: Enable window animations
            # - NSDocumentSaveNewDocumentsToCloud: Default save location
            # - NSNavPanelExpandedStateForSaveMode: Expanded save dialog state
            # - NSScrollAnimationEnabled: Smooth scrolling
            # - NSTableViewDefaultSizeMode: Table view sizing mode
            # - NSWindowShouldDragOnGesture: Window dragging behavior
            NSAutomaticWindowAnimationsEnabled = true;
            NSDocumentSaveNewDocumentsToCloud = false;
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
            NSScrollAnimationEnabled = true;
            NSTableViewDefaultSizeMode = 3;
            NSWindowShouldDragOnGesture = false;
          };

          # System Services Configuration
          #
          # Controls various system services and security settings
          # - LSQuarantine: Show warning for downloaded files (false = disable)
          LaunchServices.LSQuarantine = false;

          # Login Window Settings
          #
          # Controls the behavior of the login window and system access
          # - DisableConsoleAccess: Prevent direct console access for security
          # - GuestEnabled: Allow guest user access to the system
          loginwindow = {
            DisableConsoleAccess = true; # Prevent console access at login
            GuestEnabled = false; # Disable guest account for better security
          };

          # Menu Bar Clock Configuration
          #
          # Controls the display of the time and date in the menu bar
          # - IsAnalog: Show analog clock (true) or digital (false)
          # - Show24Hour: Use 24-hour time format (true) or 12-hour (false)
          # - ShowAMPM: Show AM/PM indicator (only in 12-hour mode)
          # - ShowDate: Show the date (0 = no date, 1 = short date, 2 = full date)
          # - ShowDayOfMonth: Show the day of the month
          # - ShowDayOfWeek: Show the day of the week
          # - ShowSeconds: Show seconds in the time display
          menuExtraClock = {
            IsAnalog = false; # Digital clock
            Show24Hour = true; # 24-hour format
            ShowAMPM = false; # No AM/PM indicator
            ShowDate = 1; # Short date format
            ShowDayOfMonth = true;
            ShowDayOfWeek = true;
            ShowSeconds = false; # Hide seconds for cleaner display
          };

          # Screenshot Configuration
          #
          # Controls the behavior of screenshots:
          # - show-thumbnail: Show thumbnail preview after taking a screenshot
          # - type: Default image format (png, jpg, tiff, pdf, etc.)
          # - location: Directory where screenshots are saved
          # - disable-shadow: Remove window shadows from screenshots for cleaner captures
          screencapture = {
            show-thumbnail = false; # Disable thumbnail for faster workflow
            type = "png"; # Use PNG for lossless quality
            location = "~/Pictures/screenshots/";  # Using ~ for home directory
            disable-shadow = true; # Remove shadows for professional-looking screenshots
          };

          # Screensaver Settings
          #
          # Controls screensaver behavior
          # - askForPassword: Require password when waking from screensaver
          screensaver.askForPassword = true; # Enable password for security

          # Spaces Configuration
          #
          # Controls how Spaces (virtual desktops) behave
          # - spans-displays: Allow windows to span across multiple displays
          spaces.spans-displays = true; # Enable window spanning

          # Software Update Settings
          #
          # Controls automatic system updates
          # - AutomaticallyInstallMacOSUpdates: Automatically download and install updates
          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true; # Keep system updated
        }
      ];
    };
  };
}
