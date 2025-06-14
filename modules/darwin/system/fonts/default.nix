# System Fonts Module for Darwin (macOS)
#
# Version: 2.0.0
# Last Updated: 2025-06-15
#
# This module provides a flexible and organized way to manage system fonts on Darwin systems.
# It groups fonts into logical collections and provides configuration options for font smoothing
# and default font settings.
#
# Example usage:
# ```nix
# system.fonts = {
#   enable = true;
#   default = "MonaspaceNe";
#   collections = [ "system" "developer" ];
#   smoothing = {
#     enable = true;
#     level = 1;  # Light smoothing
#   };
# };
# ```
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Font package collections following Interface Segregation Principle.
  # Each collection has a single responsibility.
  fontCollections = {
    # System fonts - basic fonts that should be available on all systems.
    system = with pkgs; [
      corefonts # Microsoft core fonts
      b612 # High legibility font
      source-sans
      inter
      lexend
      monaspace # Modern monospace font
    ];

    # UI/Icon fonts - for applications and UI elements.
    ui = with pkgs; [
      material-icons
      material-design-icons
      work-sans
      comic-neue
    ];

    # Emoji fonts - for emoji support.
    emoji = with pkgs; [
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
    ];

    # Developer fonts - monospace fonts for coding.
    developer = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
      cascadia-code # Modern monospace font
    ];
  };

  # Default font name to use system-wide.
  defaultFont = "MonaspaceNe";

  # Default font collections to enable.
  defaultEnabledCollections = [
    "system"
    "ui"
    "emoji"
    "developer"
  ];

  # Darwin-specific font configuration.
  cfg = config.system.fonts;

  # Helper function to get enabled font packages.
  #
  # Type: listOf str -> listOf package
  getEnabledFontPackages = collections: let
    # Filter out non-existent collections.
    validCollections = filter (name: hasAttr name fontCollections) collections;
  in
    concatMap (name: getAttr name fontCollections) validCollections;
in {
  options.system = {
    fonts = {
      enable = mkEnableOption "system font configuration";

      default = mkOption {
        type = types.str;
        default = defaultFont;
        description = ''
          The default system font to be used by applications.

          Note: The specified font must be present in one of the enabled
          collections or in extraPackages. The font name should exactly match
          the system's font name (case-sensitive).

          Common font names:
          - MonaspaceNe (default)
          - SF Pro
          - Helvetica Neue
          - Arial
        '';
        example = "MonaspaceNe";
      };

      collections = mkOption {
        type = with types; listOf (enum (attrNames fontCollections));
        default = defaultEnabledCollections;
        description = ''
          List of font collections to enable. Collections group related fonts
          for specific use cases, making it easy to manage font categories.

          Available collections:

          - system: Basic system fonts
            - corefonts (Arial, Times New Roman, etc.)
            - Inter, Lexend (modern UI fonts)
            - Monaspace (default monospace)

          - ui: UI and icon fonts
            - Material Icons
            - Work Sans
            - Comic Neue

          - emoji: Emoji support
            - Noto Color Emoji
            - Noto Emoji (monochrome)

          - developer: Developer/monospace fonts
            - Fira Code (with ligatures)
            - Hack
            - Sauce Code Pro
            - Nerd Fonts symbols
            - Cascadia Code
        '';
        example = literalExpression ''          [
                    "system"    # Core system fonts
                    "developer" # Developer fonts
                  ]'';
      };

      extraPackages = mkOption {
        type = with types; listOf package;
        default = [];
        description = ''
          Additional font packages to install beyond the defined collections.

          Use this for:
          - Custom fonts not in any collection
          - Specific font variants
          - Experimental or temporary font installations

          Example:
          ```nix
          extraPackages = with pkgs; [
            fira-code
            jetbrains-mono
          ];
          ```
        '';
        example = literalExpression "[
          pkgs.fira-code
          pkgs.jetbrains-mono
        ]";
      };

      smoothing = {
        enable =
          mkEnableOption "font smoothing"
          // {
            default = true;
            description = "Enable macOS font smoothing (subpixel antialiasing)";
          };

        level = mkOption {
          type = types.ints.between 0 3;
          default = 1;
          description = ''
            Controls the level of font smoothing (subpixel antialiasing) on macOS.

            Available levels:
            - 0: No smoothing (crisp, may appear jagged on non-retina displays)
            - 1: Light smoothing (default, good balance for most displays)
            - 2: Medium smoothing (smoother, may appear slightly blurry)
            - 3: Strong smoothing (maximum, may appear too soft)

            Note: The effect is most noticeable on non-retina displays. On Retina
            displays, the difference between levels is subtle.
          '';
          example = 1;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      fonts.packages =
        (getEnabledFontPackages cfg.collections)
        ++ cfg.extraPackages;

      environment.variables = {
        LOG_ICONS = "true";
        XDG_DEFAULT_FONT = cfg.default;
      };

      system.defaults.NSGlobalDomain = mkIf cfg.smoothing.enable {
        AppleFontSmoothing = cfg.smoothing.level;
      };

      assertions = optionals cfg.smoothing.enable [
        {
          assertion = config.system.primaryUser != null;
          message = ''
            The option `system.fonts.smoothing.enable` requires `system.primaryUser` to be set.
            Please set `system.primaryUser` to the name of the primary user.
          '';
        }
      ];
    }
  ]);
}
