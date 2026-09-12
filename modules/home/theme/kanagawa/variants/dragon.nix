# Kanagawa Dragon - darker, more muted variant
# Based on rebelot/kanagawa.nvim
{
  mkColor,
  transparent,
}: let
  raw = {
    # ─── Black (Background shades) ─────────────────────────────────────────
    dragonBlack0 = mkColor "#0d0c0c";
    dragonBlack1 = mkColor "#12120f";
    dragonBlack2 = mkColor "#1d1c19";
    dragonBlack3 = mkColor "#181616";
    dragonBlack4 = mkColor "#282727";
    dragonBlack5 = mkColor "#393836";
    dragonBlack6 = mkColor "#625e5a";

    # ─── Foreground Colors ─────────────────────────────────────────────────
    dragonWhite = mkColor "#c5c9c5";
    dragonGreen = mkColor "#87a987";
    dragonGreen2 = mkColor "#8a9a7b";
    dragonPink = mkColor "#a292a3";
    dragonOrange = mkColor "#b6927b";
    dragonOrange2 = mkColor "#b98d7b";
    dragonGray = mkColor "#a6a69c";
    dragonGray2 = mkColor "#9e9b93";
    dragonGray3 = mkColor "#7a8382";
    dragonBlue = mkColor "#658594";
    dragonBlue2 = mkColor "#8ba4b0";
    dragonViolet = mkColor "#8992a7";
    dragonRed = mkColor "#c4746e";
    dragonAqua = mkColor "#8ea4a2";
    dragonAsh = mkColor "#737c73";
    dragonTeal = mkColor "#949fb5";
    dragonYellow = mkColor "#c4b28a";

    # ─── Shared with Wave ──────────────────────────────────────────────────
    waveBlue1 = mkColor "#223249";
    waveBlue2 = mkColor "#2d4f67";
    waveRed = mkColor "#e46876";
    waveAqua2 = mkColor "#7aa89f";
    springBlue = mkColor "#7fb4ca";
    springViolet1 = mkColor "#938aa9";
    carpYellow = mkColor "#e6c384";
    oldWhite = mkColor "#c8c093";
  };
in {
  isLight = false;
  rawColors = raw;
  # Upstream term[] order from rebelot/kanagawa.nvim themes.lua.
  ansi = {
    normal = {
      black = raw.dragonBlack0;
      red = raw.dragonRed;
      green = raw.dragonGreen2;
      yellow = raw.dragonYellow;
      blue = raw.dragonBlue2;
      magenta = raw.dragonPink;
      cyan = raw.dragonAqua;
      white = raw.oldWhite;
    };
    bright = {
      black = raw.dragonGray;
      red = raw.waveRed;
      green = raw.dragonGreen;
      yellow = raw.carpYellow;
      blue = raw.springBlue;
      magenta = raw.springViolet1;
      cyan = raw.waveAqua2;
      white = raw.dragonWhite;
    };
  };
  palette = {
    # ─── Backgrounds ──────────────────────────────────────────────────
    bg = raw.dragonBlack3;
    bg_dim = raw.dragonBlack1;
    bg_gutter = raw.dragonBlack4;
    bg_float = raw.dragonBlack0;
    bg_visual = raw.waveBlue1;

    # ─── Foregrounds ──────────────────────────────────────────────────
    fg = raw.dragonWhite;
    fg_dim = raw.oldWhite;
    fg_reverse = raw.waveBlue1;

    # ─── UI Elements ──────────────────────────────────────────────────
    accent = raw.dragonBlue2;
    accent_dim = raw.dragonViolet;
    border = raw.dragonBlack4;
    selection = raw.waveBlue1;
    overlay = raw.dragonBlack6;

    # ─── Semantic Colors ──────────────────────────────────────────────
    red = raw.dragonRed;
    red_bright = raw.waveRed;
    red_dim = raw.waveRed;
    green = raw.dragonGreen2;
    yellow = raw.dragonYellow;
    # Dragon has no dedicated bright yellow; reuse Wave's carpYellow so the
    # bright role stays brighter than `yellow` (find highlight, active border).
    yellow_bright = raw.carpYellow;
    blue = raw.dragonBlue2;
    blue_bright = raw.springBlue;
    orange = raw.dragonOrange;
    violet = raw.dragonViolet;
    pink = raw.dragonPink;
    cyan = raw.dragonAqua;

    # ─── Special ──────────────────────────────────────────────────────
    inherit transparent;
  };
}
