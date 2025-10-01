{
  config,
  lib,
  ...
}:
with lib; let
  inputTypes = {
    trackpad = {
      actuationStrength = mkOption {
        type = types.ints.between 0 1;
        default = 0;
        description = "Trackpad pressure sensitivity (0 = silent clicking, 1 = default)";
      };
      tapToClick = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tap-to-click functionality";
      };
      dragging = mkOption {
        type = types.bool;
        default = false;
        description = "Enable dragging via trackpad";
      };
      clickFirmness = mkOption {
        type = types.ints.between 0 2;
        default = 1;
        description = "Click firmness (0 = lightest, 2 = heaviest)";
      };
      enableRightClick = mkOption {
        type = types.bool;
        default = true;
        description = "Enable right-click functionality";
      };
      threeFingerTapGesture = mkOption {
        type = types.ints.between 0 1;
        default = 0;
        description = "Three-finger tap gesture (0 = disabled, 1 = enabled)";
      };
    };
    mouse = {
      trackingSpeed = mkOption {
        type = types.float;
        default = 1.0;
        description = "Mouse tracking speed (0.0 to 3.0)";
      };
    };
    keyboard = {
      enableKeyRepeat = mkOption {
        type = types.bool;
        default = true;
        description = "Enable key repeat";
      };
      keyRepeatDelay = mkOption {
        type = types.ints.unsigned;
        default = 15;
        description = "Delay before key repeat starts (in ms)";
      };
      keyRepeatRate = mkOption {
        type = types.ints.positive;
        default = 2;
        description = "Key repeat rate (in ms)";
      };
      pressAndHold = mkOption {
        type = types.bool;
        default = true;
        description = "Enable press-and-hold for accented characters";
      };
      fullKeyboardControl = mkOption {
        type = types.bool;
        default = true;
        description = "Enable full keyboard control";
      };
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
  options.system.input =
    inputTypes
    // {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system input configuration (auto-enabled when module is imported)";
      };
    };
  config = mkIf config.system.input.enable {
    system.defaults = {
      trackpad = {
        Clicking = mkDefault config.system.input.trackpad.tapToClick;
        TrackpadThreeFingerDrag = mkDefault config.system.input.trackpad.dragging;
        TrackpadRightClick = mkDefault config.system.input.trackpad.enableRightClick;
        TrackpadThreeFingerTapGesture = mkDefault config.system.input.trackpad.threeFingerTapGesture;
      };
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = mkDefault config.system.input.mouse.trackingSpeed;
      };
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = mkDefault config.system.input.keyboard.pressAndHold;
        AppleKeyboardUIMode =
          if config.system.input.keyboard.fullKeyboardControl
          then 3
          else 0;
        InitialKeyRepeat = mkDefault config.system.input.keyboard.keyRepeatDelay;
        KeyRepeat = mkDefault config.system.input.keyboard.keyRepeatRate;
        NSAutomaticCapitalizationEnabled = mkDefault config.system.input.keyboard.textInput.autoCapitalization;
        NSAutomaticDashSubstitutionEnabled = mkDefault config.system.input.keyboard.textInput.smartDashes;
        NSAutomaticQuoteSubstitutionEnabled = mkDefault config.system.input.keyboard.textInput.smartQuotes;
        NSAutomaticSpellingCorrectionEnabled = mkDefault config.system.input.keyboard.textInput.autoCorrection;
        NSAutomaticInlinePredictionEnabled = mkDefault config.system.input.keyboard.textInput.textPrediction;
      };
    };
  };
}
