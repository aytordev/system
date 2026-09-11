# Catppuccin Mocha - default dark variant
{
  mkColor,
  transparent,
}: let
  raw = {
    rosewater = mkColor "#f5e0dc";
    flamingo = mkColor "#f2cdcd";
    pink = mkColor "#f5c2e7";
    mauve = mkColor "#cba6f7";
    red = mkColor "#f38ba8";
    maroon = mkColor "#eba0ac";
    peach = mkColor "#fab387";
    yellow = mkColor "#f9e2af";
    green = mkColor "#a6e3a1";
    teal = mkColor "#94e2d5";
    sky = mkColor "#89dceb";
    sapphire = mkColor "#74c7ec";
    blue = mkColor "#89b4fa";
    lavender = mkColor "#b4befe";
    text = mkColor "#cdd6f4";
    subtext1 = mkColor "#bac2de";
    subtext0 = mkColor "#a6adc8";
    overlay2 = mkColor "#9399b2";
    overlay1 = mkColor "#7f849c";
    overlay0 = mkColor "#6c7086";
    surface2 = mkColor "#585b70";
    surface1 = mkColor "#45475a";
    surface0 = mkColor "#313244";
    base = mkColor "#1e1e2e";
    mantle = mkColor "#181825";
    crust = mkColor "#11111b";
  };
in {
  isLight = false;
  rawColors = raw;
  palette = (import ../palette.nix {inherit transparent;}) raw;
}
