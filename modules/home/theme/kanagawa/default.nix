# Kanagawa Theme Module
# Centralized theming for all applications using Kanagawa color scheme
#
# Usage:
#   aytordev.theme = {
#     enable = true;
#     variant = "wave";  # or "dragon", "lotus"
#   };
#
# Access colors in other modules:
#   config.aytordev.theme.palette.accent.hex
#   config.aytordev.theme.palette.bg.sketchybar

{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  colors = import ./colors.nix;
  themeLib = import ./lib.nix { inherit lib; };

  cfg = config.aytordev.theme;
in
{
  options.aytordev.theme = {
    enable = mkEnableOption "centralized Kanagawa theming";

    variant = mkOption {
      type = types.enum [ "wave" "dragon" "lotus" ];
      default = "wave";
      description = ''
        Kanagawa theme variant to use globally.

        - wave: Default dark theme with blue accents (ink/ocean inspired)
        - dragon: Darker, more muted variant with warmer tones
        - lotus: Light theme variant
      '';
      example = "dragon";
    };

    polarity = mkOption {
      type = types.enum [ "dark" "light" ];
      default = "dark";
      description = ''
        Theme polarity. When set to "light", lotus variant is used regardless
        of the variant setting. When set to "dark", the configured variant is used.
      '';
    };

    # ─── Readonly Computed Values ───────────────────────────────────────────

    palette = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      default = themeLib.getThemeForPolarity {
        inherit colors;
        inherit (cfg) variant polarity;
      };
      description = ''
        The active color palette based on current variant and polarity settings.
        This is a read-only option that exposes colors in multiple formats.

        Each color has: hex, rgb, sketchybar, and raw formats.
        Example: config.aytordev.theme.palette.accent.hex
      '';
    };

    colors = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      default = colors;
      description = ''
        All available color palettes (wave, dragon, lotus).
        Use this when you need access to multiple variants.
      '';
    };

    lib = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      default = themeLib;
      description = ''
        Theme library functions for color manipulation and format conversion.

        Available functions:
        - hexToSketchybar: Convert #RRGGBB to 0xffRRGGBB
        - hexToSketchybarAlpha: Convert with custom alpha
        - toHexOnly: Extract only hex values from palette
        - toSketchybarOnly: Extract only sketchybar values
        - variantToAppTheme: Get app-specific theme name
      '';
    };

    # ─── Convenience Accessors ──────────────────────────────────────────────

    appTheme = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = {
        capitalized = themeLib.variantToAppTheme cfg.variant "capitalized";
        kebab = themeLib.variantToAppTheme cfg.variant "kebab";
        underscore = themeLib.variantToAppTheme cfg.variant "underscore";
      };
      description = ''
        Pre-formatted theme names for application configs.

        - capitalized: "Kanagawa Wave"
        - kebab: "kanagawa-wave"
        - underscore: "kanagawa_wave"
      '';
    };

    isLight = mkOption {
      type = types.bool;
      readOnly = true;
      default = cfg.polarity == "light" || cfg.variant == "lotus";
      description = ''
        Whether the current theme is a light theme.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Theme module doesn't set any direct configuration by itself.
    # It only exposes options for other modules to consume.
    #
    # Individual modules (ghostty, sketchybar, etc.) should read from
    # config.aytordev.theme.palette and config.aytordev.theme.variant
    # to configure their own theming.
  };
}
