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
  # Upstream ansiColors (catppuccin/palette palette.json). Bright entries are
  # upstream-only, so they are created here rather than taken from `raw`.
  ansi = {
    normal = {
      black = raw.surface1;
      inherit (raw) red;
      inherit (raw) green;
      inherit (raw) yellow;
      inherit (raw) blue;
      magenta = raw.pink;
      cyan = raw.teal;
      white = raw.subtext0;
    };
    bright = {
      black = raw.surface2;
      red = mkColor "#f37799";
      green = mkColor "#89d88b";
      yellow = mkColor "#ebd391";
      blue = mkColor "#74a8fc";
      magenta = mkColor "#f2aede";
      cyan = mkColor "#6bd7ca";
      white = raw.subtext1;
    };
  };
in {
  isLight = false;
  rawColors = raw;
  inherit ansi;
  palette = (import ../palette.nix {inherit transparent;}) raw ansi;
}
