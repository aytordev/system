# System Input Configuration Module for Darwin (macOS)
#
# Version: 2.2.0
# Last Updated: 2025-06-15
#
# This module provides comprehensive configuration for input devices on Darwin systems,
# including trackpad, mouse, and keyboard settings. The settings are organized into
# logical sections for better maintainability and clarity.
#
# ## Features
# - Configure trackpad gestures and sensitivity
# - Customize mouse behavior and scrolling
# - Set keyboard repeat rate and key mappings
# - Configure input device acceleration and sensitivity
#
# ## Example Usage
# ```nix
# {
#   system.input = {
#     # Trackpad configuration
#     trackpad = {
#       tapToClick = true;
#       clickFirmness = 1;
#       trackpadThreeFingerDrag = true;
#     };
#
#     # Keyboard configuration
#     keyboard = {
#       keyRepeat = true;
#       keyRepeatDelay = 15;  # ms
#       keyRepeatRate = 2;    # characters per second
#     };
#
#     # Mouse configuration
#     mouse = {
#       trackingSpeed = 3.0;  # 0-3.0 (slowest to fastest)
#       scrollSpeed = 1.0;    # 0.0-3.0 (slowest to fastest)
#     };
#   };
# }
# ```
{
  config,
  lib,
  ...
}:
with lib; let
  # Define input configuration types for better type safety
  inputTypes = {
    # Trackpad Configuration
    #
    # Controls the behavior and sensitivity of the built-in trackpad.
    # These settings affect gestures, clicking, and scrolling behavior.
    trackpad = {
      # Pressure sensitivity (0 = silent clicking, 1 = default)
      actuationStrength = mkOption {
        type = types.ints.between 0 1;
        default = 0;
        description = "Trackpad pressure sensitivity (0 = silent clicking, 1 = default)";
      };

      # Tap to click (true/false)
      tapToClick = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tap-to-click functionality";
      };

      # Dragging (true/false)
      dragging = mkOption {
        type = types.bool;
        default = false;
        description = "Enable dragging via trackpad";
      };

      # Click firmness (0-2)
      clickFirmness = mkOption {
        type = types.ints.between 0 2;
        default = 1;
        description = "Click firmness (0 = lightest, 2 = heaviest)";
      };

      # Enable right-click
      enableRightClick = mkOption {
        type = types.bool;
        default = true;
        description = "Enable right-click functionality";
      };

      # Three-finger tap gesture (0 = disabled, 1 = enabled)
      threeFingerTapGesture = mkOption {
        type = types.ints.between 0 1;
        default = 0;
        description = "Three-finger tap gesture (0 = disabled, 1 = enabled)";
      };
    };

    # Mouse Configuration
    #
    # Controls the behavior of external mice connected to the system.
    # Includes settings for tracking speed, scrolling, and button behavior.
    mouse = {
      # Mouse speed (0.0 to 3.0)
      trackingSpeed = mkOption {
        type = types.float;
        default = 1.0;
        description = "Mouse tracking speed (0.0 to 3.0)";
      };
    };

    # Keyboard Configuration
    #
    # Controls keyboard behavior including key repeat, modifier keys,
    # and special key mappings.
    keyboard = {
      # Key repeat (true/false)
      enableKeyRepeat = mkOption {
        type = types.bool;
        default = true;
        description = "Enable key repeat";
      };

      # Key repeat delay (in ms)
      keyRepeatDelay = mkOption {
        type = types.ints.unsigned;
        default = 15;
        description = "Delay before key repeat starts (in ms)";
      };

      # Key repeat rate (in ms)
      keyRepeatRate = mkOption {
        type = types.ints.positive;
        default = 2;
        description = "Key repeat rate (in ms)";
      };

      # Enable press-and-hold
      pressAndHold = mkOption {
        type = types.bool;
        default = true;
        description = "Enable press-and-hold for accented characters";
      };

      # Full keyboard control mode
      fullKeyboardControl = mkOption {
        type = types.bool;
        default = true;
        description = "Enable full keyboard control";
      };

      # Text input settings
      textInput = {
        autoCapitalization = mkOption {
          type = types.bool;
          default = false;
          description = "Enable auto-capitalization";
        };
        autoCorrection = mkOption {
          type = types.bool;
          default = false;
          description = "Enable auto-correction";
        };
        smartDashes = mkOption {
          type = types.bool;
          default = false;
          description = "Enable smart dashes";
        };
        smartQuotes = mkOption {
          type = types.bool;
          default = false;
          description = "Enable smart quotes";
        };
        textPrediction = mkOption {
          type = types.bool;
          default = true;
          description = "Enable text prediction";
        };
      };
    };
  };
in {
  # Main module options
  #
  # These options are available under `system.input` in the system configuration.
  options.system.input =
    inputTypes
    // {
      # Whether to enable the input module
      #
      # Type: boolean
      # Default: true
      enable = mkEnableOption "system input configuration";
    };

  # Module implementation
  #
  # This section applies the input configuration to the system by generating the
  # appropriate `defaults` commands and system settings.
  config = mkIf config.system.input.enable {
    system.defaults = {
      # Trackpad settings
      trackpad = {
        Clicking = mkDefault config.system.input.trackpad.tapToClick;
        TrackpadThreeFingerDrag = mkDefault config.system.input.trackpad.dragging;
        TrackpadRightClick = mkDefault config.system.input.trackpad.enableRightClick;
        TrackpadThreeFingerTapGesture = mkDefault config.system.input.trackpad.threeFingerTapGesture;
      };

      # Mouse settings
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = mkDefault config.system.input.mouse.trackingSpeed;
      };

      # Keyboard and system settings
      NSGlobalDomain = {
        # Basic keyboard behavior
        ApplePressAndHoldEnabled = mkDefault config.system.input.keyboard.pressAndHold;
        AppleKeyboardUIMode =
          if config.system.input.keyboard.fullKeyboardControl
          then 3
          else 0;

        # Key repeat settings
        InitialKeyRepeat = mkDefault config.system.input.keyboard.keyRepeatDelay;
        KeyRepeat = mkDefault config.system.input.keyboard.keyRepeatRate;

        # Text input settings
        NSAutomaticCapitalizationEnabled = mkDefault config.system.input.keyboard.textInput.autoCapitalization;
        NSAutomaticDashSubstitutionEnabled = mkDefault config.system.input.keyboard.textInput.smartDashes;
        NSAutomaticQuoteSubstitutionEnabled = mkDefault config.system.input.keyboard.textInput.smartQuotes;
        NSAutomaticSpellingCorrectionEnabled = mkDefault config.system.input.keyboard.textInput.autoCorrection;
        NSAutomaticInlinePredictionEnabled = mkDefault config.system.input.keyboard.textInput.textPrediction;
      };
    };
  };
}
