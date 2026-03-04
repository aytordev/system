# Sketchybar option definitions
# All configurable options for the modular sketchybar status bar.
{lib}: let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types) package listOf str int float enum nullOr bool;
in {
  enable = mkEnableOption "Sketchybar status bar";

  package = mkOption {
    type = package;
    description = "The Sketchybar package to use.";
  };

  extraPackages = mkOption {
    type = listOf package;
    default = [];
    description = "Extra packages needed for Sketchybar plugins and functionality.";
  };

  # Theme override (optional - uses global theme by default)
  themeOverride = mkOption {
    type = nullOr (enum ["wave" "dragon" "lotus"]);
    default = null;
    description = ''
      Override the global Kanagawa theme variant for Sketchybar only.
      If null (default), uses the global theme from aytordev.theme.variant.
    '';
  };

  # Font configuration
  fonts = {
    text = mkOption {
      type = str;
      default = "SF Pro";
      description = "Main text font family.";
    };
    icon = mkOption {
      type = str;
      default = "Hack Nerd Font";
      description = "Icon font family (should be a Nerd Font).";
    };
    size = mkOption {
      type = float;
      default = 13.0;
      description = "Base font size.";
    };
  };

  # Icon style
  iconsStyle = mkOption {
    type = enum ["sf_symbols" "nerdfont"];
    default = "nerdfont";
    description = "Icon set to use (SF Symbols or Nerd Font icons).";
  };

  # Bar configuration
  bar = {
    height = mkOption {
      type = int;
      default = 40;
      description = "Height of the bar in pixels.";
    };
    blurRadius = mkOption {
      type = int;
      default = 0;
      description = "Blur radius for the bar background.";
    };
    shadow = mkOption {
      type = bool;
      default = false;
      description = "Whether to show shadow under the bar.";
    };
    sticky = mkOption {
      type = bool;
      default = true;
      description = "Whether the bar stays visible when switching spaces.";
    };
    topmost = mkOption {
      type = enum ["off" "window" "layer"];
      default = "off";
      description = "Bar topmost mode.";
    };
    paddingLeft = mkOption {
      type = int;
      default = 10;
      description = "Left padding of the bar.";
    };
    paddingRight = mkOption {
      type = int;
      default = 10;
      description = "Right padding of the bar.";
    };
    cornerRadius = mkOption {
      type = int;
      default = 0;
      description = "Corner radius for the bar and bracket backgrounds.";
    };
    borderWidth = mkOption {
      type = int;
      default = 0;
      description = "Border width for the bar.";
    };
    color = mkOption {
      type = str;
      default = "0x00000000";
      description = "Background color of the bar (ARGB hex literal, e.g. 0xAARRGGBB).";
    };
    yOffset = mkOption {
      type = int;
      default = 2;
      description = "Vertical offset of the bar in pixels.";
    };
  };

  # ── Items ────────────────────────────────────────────────────────────
  items = {
    # Left side
    menus = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "App menu bar items with curtain effect (shares space with workspaces).";
      };
    };

    workspaces = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "AeroSpace workspace indicators.";
      };
      bounceAnimation = mkOption {
        type = bool;
        default = true;
        description = "Bounce animation on workspace focus change.";
      };
      deferredLoading = mkOption {
        type = bool;
        default = true;
        description = "Poll until AeroSpace is ready before loading workspaces.";
      };
    };

    frontApp = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Show frontmost application name on the left side.";
      };
    };

    # Right side
    calendar = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Date/time display.";
      };
    };

    vpn = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "VPN status indicator (WireGuard, GlobalProtect, F5).";
      };
    };

    media = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Media playback controls.";
      };
      whitelist = mkOption {
        type = listOf str;
        default = ["Spotify" "Music" "Plexamp" "Safari" "Firefox" "Google Chrome"];
        description = "Applications to show media playback info for.";
      };
    };

    themePicker = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Runtime theme variant picker popup.";
      };
    };

    pomodoro = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Pomodoro timer with presets.";
      };
      defaultDuration = mkOption {
        type = int;
        default = 25;
        description = "Default pomodoro duration in minutes.";
      };
    };

    clipboard = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Clipboard history popup.";
      };
      pollInterval = mkOption {
        type = int;
        default = 2;
        description = "Clipboard polling interval in seconds.";
      };
      maxEntries = mkOption {
        type = int;
        default = 10;
        description = "Maximum clipboard entries to track.";
      };
    };

    # ── Widgets (system monitors) ──────────────────────────────────────
    widgets = {
      brew = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Homebrew outdated packages count.";
        };
      };
      volume = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Volume control with device selector popup.";
        };
      };
      battery = {
        enable = mkOption {
          type = bool;
          default = false;
          description = "Battery percentage and time remaining.";
        };
      };
      network = {
        enable = mkOption {
          type = bool;
          default = false;
          description = "Upload/download speeds.";
        };
      };
      ram = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "RAM usage percentage.";
        };
      };
      cpu = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "CPU load percentage.";
        };
      };
    };
  };
}
