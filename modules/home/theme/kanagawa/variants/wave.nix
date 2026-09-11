# Kanagawa Wave - default dark variant
# Based on rebelot/kanagawa.nvim
{
  mkColor,
  transparent,
}: let
  raw = {
    # ─── Ink Colors (Background shades) ────────────────────────────────────
    sumiInk0 = mkColor "#16161d";
    sumiInk1 = mkColor "#181820";
    sumiInk2 = mkColor "#1a1a22";
    sumiInk3 = mkColor "#1f1f28";
    sumiInk4 = mkColor "#2a2a37";
    sumiInk5 = mkColor "#363646";
    sumiInk6 = mkColor "#54546d";

    # ─── Foreground Colors ─────────────────────────────────────────────────
    fujiWhite = mkColor "#dcd7ba";
    oldWhite = mkColor "#c8c093";
    fujiGray = mkColor "#727169";

    # ─── Syntax Colors ─────────────────────────────────────────────────────
    oniViolet = mkColor "#957fb8";
    oniViolet2 = mkColor "#b8b4d0";
    crystalBlue = mkColor "#7e9cd8";
    springViolet1 = mkColor "#938aa9";
    springViolet2 = mkColor "#9cabca";
    springBlue = mkColor "#7fb4ca";
    lightBlue = mkColor "#a3d4d5";
    waveAqua1 = mkColor "#6a9589";
    waveAqua2 = mkColor "#7aa89f";
    springGreen = mkColor "#98bb6c";
    boatYellow1 = mkColor "#938056";
    boatYellow2 = mkColor "#c0a36e";
    carpYellow = mkColor "#e6c384";
    sakuraPink = mkColor "#d27e99";
    waveRed = mkColor "#e46876";
    peachRed = mkColor "#ff5d62";
    surimiOrange = mkColor "#ffa066";
    katanaGray = mkColor "#717c7c";

    # ─── Diff Colors ───────────────────────────────────────────────────────
    winterGreen = mkColor "#2b3328";
    winterYellow = mkColor "#49443c";
    winterRed = mkColor "#43242b";
    winterBlue = mkColor "#252535";

    # ─── Autumn Colors ─────────────────────────────────────────────────────
    autumnGreen = mkColor "#76946a";
    autumnRed = mkColor "#c34043";
    autumnYellow = mkColor "#dca561";

    # ─── Special Colors ────────────────────────────────────────────────────
    samuraiRed = mkColor "#e82424";
    roninYellow = mkColor "#ff9e3b";
  };
in {
  isLight = false;
  rawColors = raw;
  palette = {
    # ─── Backgrounds ──────────────────────────────────────────────────
    bg = raw.sumiInk3;
    bg_dim = raw.sumiInk0;
    bg_gutter = raw.sumiInk4;
    bg_float = raw.sumiInk1;
    bg_visual = raw.sumiInk5;

    # ─── Foregrounds ──────────────────────────────────────────────────
    fg = raw.fujiWhite;
    fg_dim = raw.fujiGray;
    fg_reverse = raw.oldWhite;

    # ─── UI Elements ──────────────────────────────────────────────────
    accent = raw.crystalBlue;
    accent_dim = raw.springViolet2;
    border = raw.sumiInk4;
    selection = raw.sumiInk5;
    overlay = raw.sumiInk6;

    # ─── Semantic Colors ──────────────────────────────────────────────
    red = raw.autumnRed;
    red_bright = raw.samuraiRed;
    red_dim = raw.waveRed;
    green = raw.autumnGreen;
    yellow = raw.boatYellow2;
    yellow_bright = raw.carpYellow;
    blue = raw.crystalBlue;
    blue_bright = raw.springBlue;
    orange = raw.surimiOrange;
    violet = raw.oniViolet;
    pink = raw.sakuraPink;
    cyan = raw.waveAqua1;

    # ─── Special ──────────────────────────────────────────────────────
    inherit transparent;
  };
}
