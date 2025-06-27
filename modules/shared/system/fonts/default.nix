{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption;

  # Common fonts that should be available on all systems
  commonFonts = with pkgs; [
    # Desktop Fonts
    corefonts # MS fonts
    b612 # High legibility
    material-icons
    material-design-icons
    work-sans
    comic-neue
    source-sans
    inter
    lexend

    # Emojis
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    # Nerd Fonts
    cascadia-code
    monaspace
    nerd-fonts.symbols-only
  ];
in {
  options.system.fonts = with types; {
    fonts = mkOption {
      type = listOf package;
      default = commonFonts;
      description = "List of font packages to install system-wide";
    };

    default = mkOption {
      type = str;
      default = "MonaspaceNeon";
      description = "Default system font name";
    };

    size = mkOption {
      type = addCheck int (n: n > 0);
      default = 13;
      description = "Default font size in points";
    };
  };

  config = {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts
      LOG_ICONS = "true";
    };
  };
}
