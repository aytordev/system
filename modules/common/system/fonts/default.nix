{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption;
  commonFonts = with pkgs; [
    corefonts
    b612
    material-icons
    material-design-icons
    work-sans
    comic-neue
    source-sans
    inter
    lexend
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    cascadia-code
    monaspace
    nerd-fonts.symbols-only
    nerd-fonts.monaspace
    sketchybar-app-font
    maple-mono.variable
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
      LOG_ICONS = "true";
    };
  };
}
