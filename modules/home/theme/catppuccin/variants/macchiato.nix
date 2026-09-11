# Catppuccin Macchiato - medium dark variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#f4dbd6";
    flamingo = mkColor "#f0c6c6";
    pink = mkColor "#f5bde6";
    mauve = mkColor "#c6a0f6";
    red = mkColor "#ed8796";
    maroon = mkColor "#ee99a0";
    peach = mkColor "#f5a97f";
    yellow = mkColor "#eed49f";
    green = mkColor "#a6da95";
    teal = mkColor "#8bd5ca";
    sky = mkColor "#91d7e3";
    sapphire = mkColor "#7dc4e4";
    blue = mkColor "#8aadf4";
    lavender = mkColor "#b7bdf8";
    text = mkColor "#cad3f5";
    subtext1 = mkColor "#b8c0e0";
    subtext0 = mkColor "#a5adcb";
    overlay2 = mkColor "#939ab7";
    overlay1 = mkColor "#8087a2";
    overlay0 = mkColor "#6e738d";
    surface2 = mkColor "#5b6078";
    surface1 = mkColor "#494d64";
    surface0 = mkColor "#363a4f";
    base = mkColor "#24273a";
    mantle = mkColor "#1e2030";
    crust = mkColor "#181926";
  };
in {
  isLight = false;
  rawColors = raw;
  palette = (import ../palette.nix {inherit transparent;}) raw;
}
