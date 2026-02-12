# Centralized Theme Module
# Generic theming orchestrator that delegates to theme providers.
#
# Usage:
#   aytordev.theme = {
#     enable = true;
#     name = "kanagawa";    # Theme to use
#     variant = "wave";     # Theme-specific variant
#   };
#
# Access colors in other modules:
#   config.aytordev.theme.palette.accent.hex
#   config.aytordev.theme.palette.bg.sketchybar
{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  themeLib = import ./lib.nix {inherit lib;};

  # ─── Theme Providers ─────────────────────────────────────────────────────
  # Each provider is a data attrset (not a module) conforming to the contract.
  # To add a new theme, import it here and add to this attrset.
  themeProviders = {
    kanagawa = import ./kanagawa/provider.nix {
      inherit (themeLib) mkColor transparent capitalize;
    };
  };

  cfg = config.aytordev.theme;

  activeTheme = themeProviders.${cfg.name};
  activeVariant = activeTheme.variants.${cfg.variant};

  # ─── Palette Contract Type ──────────────────────────────────────────────
  # Every theme must provide these 26 semantic colors.
  # Each color is an attrset with: hex, rgb, sketchybar, raw.
  colorType = types.submodule {
    options = {
      hex = mkOption {type = types.str;};
      rgb = mkOption {type = types.str;};
      sketchybar = mkOption {type = types.str;};
      raw = mkOption {type = types.str;};
    };
  };

  paletteType = types.submodule {
    options = {
      # Backgrounds
      bg = mkOption {type = colorType;};
      bg_dim = mkOption {type = colorType;};
      bg_gutter = mkOption {type = colorType;};
      bg_float = mkOption {type = colorType;};
      bg_visual = mkOption {type = colorType;};

      # Foregrounds
      fg = mkOption {type = colorType;};
      fg_dim = mkOption {type = colorType;};
      fg_reverse = mkOption {type = colorType;};

      # UI Elements
      accent = mkOption {type = colorType;};
      accent_dim = mkOption {type = colorType;};
      border = mkOption {type = colorType;};
      selection = mkOption {type = colorType;};
      overlay = mkOption {type = colorType;};

      # Semantic Colors
      red = mkOption {type = colorType;};
      red_bright = mkOption {type = colorType;};
      red_dim = mkOption {type = colorType;};
      green = mkOption {type = colorType;};
      yellow = mkOption {type = colorType;};
      yellow_bright = mkOption {type = colorType;};
      blue = mkOption {type = colorType;};
      blue_bright = mkOption {type = colorType;};
      orange = mkOption {type = colorType;};
      violet = mkOption {type = colorType;};
      pink = mkOption {type = colorType;};
      cyan = mkOption {type = colorType;};

      # Special
      transparent = mkOption {type = colorType;};
    };
  };
in {
  options.aytordev.theme = {
    enable = mkEnableOption "centralized theming";

    name = mkOption {
      type = types.enum (builtins.attrNames themeProviders);
      default = "kanagawa";
      description = ''
        Which theme to use globally.
        Available themes: ${toString (builtins.attrNames themeProviders)}
      '';
    };

    variant = mkOption {
      type = types.str;
      default = activeTheme.defaultVariant;
      description = ''
        Theme variant. Valid values depend on the selected theme.
        For Kanagawa: wave, dragon, lotus.
      '';
    };

    # ─── Read-only Computed Values ──────────────────────────────────────────

    palette = mkOption {
      type = paletteType;
      readOnly = true;
      default = activeVariant.palette;
      description = ''
        The active semantic color palette based on current theme and variant.
        Each color has: hex, rgb, sketchybar, and raw formats.
        Example: config.aytordev.theme.palette.accent.hex
      '';
    };

    isLight = mkOption {
      type = types.bool;
      readOnly = true;
      default = activeVariant.isLight;
      description = "Whether the current variant is a light theme.";
    };

    appTheme = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = activeTheme.appTheme cfg.variant;
      description = ''
        Pre-formatted theme names for application configs.
        Available formats: capitalized, kebab, underscore, raw.
      '';
    };

    appThemeLight = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = activeTheme.appTheme activeTheme.lightVariant;
      description = ''
        Pre-formatted theme names for the light variant.
        Useful for apps that need both dark and light theme names.
      '';
    };

    raw = mkOption {
      type = types.attrsOf types.anything;
      readOnly = true;
      default = activeVariant.rawColors;
      description = ''
        Theme-specific raw colors for advanced use.
        Prefer palette for standard consumption.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.variant activeTheme.variants;
        message = "Theme '${cfg.name}' does not have variant '${cfg.variant}'. Available: ${toString (builtins.attrNames activeTheme.variants)}";
      }
    ];
  };
}
