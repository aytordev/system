# Catppuccin Frappe - muted dark variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#f2d5cf";
    flamingo = mkColor "#eebebe";
    pink = mkColor "#f4b8e4";
    mauve = mkColor "#ca9ee6";
    red = mkColor "#e78284";
    maroon = mkColor "#ea999c";
    peach = mkColor "#ef9f76";
    yellow = mkColor "#e5c890";
    green = mkColor "#a6d189";
    teal = mkColor "#81c8be";
    sky = mkColor "#99d1db";
    sapphire = mkColor "#85c1dc";
    blue = mkColor "#8caaee";
    lavender = mkColor "#babbf1";
    text = mkColor "#c6d0f5";
    subtext1 = mkColor "#b5bfe2";
    subtext0 = mkColor "#a5adce";
    overlay2 = mkColor "#949cbb";
    overlay1 = mkColor "#838ba7";
    overlay0 = mkColor "#737994";
    surface2 = mkColor "#626880";
    surface1 = mkColor "#51576d";
    surface0 = mkColor "#414559";
    base = mkColor "#303446";
    mantle = mkColor "#292c3c";
    crust = mkColor "#232634";
  };
in {
  isLight = false;
  rawColors = raw;
  palette = (import ../palette.nix {inherit transparent;}) raw;
}
