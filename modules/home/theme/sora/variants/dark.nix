# Sora Dark - the official Sora palette
# Based on Aejkatappaja/sora (MIT), lua/sora/palette.lua.
# https://github.com/Aejkatappaja/sora
{
  mkColor,
  transparent,
}: let
  raw = {
    # ─── Backgrounds ───────────────────────────────────────────────────
    bg = mkColor "#0e1018";
    bg_float = mkColor "#0a0c12";
    bg_elevated = mkColor "#14161e";
    bg_cursorline = mkColor "#171a24";
    bg_selection = mkColor "#1e2430";
    bg_search = mkColor "#1a3050";
    bg_statusline = mkColor "#0a0c12";

    # ─── Foregrounds ───────────────────────────────────────────────────
    fg = mkColor "#c8d0e0";
    fg_dim = mkColor "#9aa4b8";
    fg_bright = mkColor "#dce4f0";
    fg_comment = mkColor "#586478";
    fg_gutter = mkColor "#364050";
    fg_gutter_active = mkColor "#6a7890";

    # ─── Syntax ────────────────────────────────────────────────────────
    cyan = mkColor "#80c8e0";
    purple = mkColor "#b0a0d8";
    sage = mkColor "#90c8a0";
    rose = mkColor "#d0909c";
    gold = mkColor "#d4b878";
    peach = mkColor "#d0a888";
    teal = mkColor "#78b8b0";
    steel = mkColor "#8898b8";

    # ─── UI ────────────────────────────────────────────────────────────
    border = mkColor "#364050";
    separator = mkColor "#222838";
    match_paren = mkColor "#d4b878";
    guide = mkColor "#181c26";
    guide_active = mkColor "#282e3c";
    nontext = mkColor "#222838";
    bg_selected = mkColor "#283448";

    # ─── Diagnostics ───────────────────────────────────────────────────
    error = mkColor "#c46c78";
    warning = mkColor "#c8a860";
    info = mkColor "#5ca8c8";
    hint = mkColor "#78b0a0";
    ok = mkColor "#68a888";

    # ─── Git ───────────────────────────────────────────────────────────
    git_add = mkColor "#68b080";
    git_change = mkColor "#6898b8";
    git_delete = mkColor "#b86068";
    git_ignore = mkColor "#586478";

    # ─── Terminal ──────────────────────────────────────────────────────
    terminal_black = mkColor "#0e1018";
    terminal_red = mkColor "#c46c78";
    terminal_green = mkColor "#90c8a0";
    terminal_yellow = mkColor "#d4b878";
    terminal_blue = mkColor "#80c8e0";
    terminal_magenta = mkColor "#b0a0d8";
    terminal_cyan = mkColor "#78b8b0";
    terminal_white = mkColor "#c8d0e0";
    terminal_bright_black = mkColor "#4a5468";
    terminal_bright_red = mkColor "#d88898";
    terminal_bright_green = mkColor "#a8d8b4";
    terminal_bright_yellow = mkColor "#e0c888";
    terminal_bright_blue = mkColor "#98d8f0";
    terminal_bright_magenta = mkColor "#c4b4e8";
    terminal_bright_cyan = mkColor "#90d0c8";
    terminal_bright_white = mkColor "#dce4f0";
    terminal_dim_red = mkColor "#9a5660";
    terminal_dim_green = mkColor "#6a9878";
    terminal_dim_yellow = mkColor "#a89060";
    terminal_dim_blue = mkColor "#6098b0";
    terminal_dim_magenta = mkColor "#8878a8";
    terminal_dim_cyan = mkColor "#588880";
  };
  # Upstream terminal_* sets from Aejkatappaja/sora palette.lua.
  ansi = {
    normal = {
      black = raw.terminal_black;
      red = raw.terminal_red;
      green = raw.terminal_green;
      yellow = raw.terminal_yellow;
      blue = raw.terminal_blue;
      magenta = raw.terminal_magenta;
      cyan = raw.terminal_cyan;
      white = raw.terminal_white;
    };
    bright = {
      black = raw.terminal_bright_black;
      red = raw.terminal_bright_red;
      green = raw.terminal_bright_green;
      yellow = raw.terminal_bright_yellow;
      blue = raw.terminal_bright_blue;
      magenta = raw.terminal_bright_magenta;
      cyan = raw.terminal_bright_cyan;
      white = raw.terminal_bright_white;
    };
    # Zed's dimmed ANSI set; Sora is the only upstream that defines it.
    dim = {
      red = raw.terminal_dim_red;
      green = raw.terminal_dim_green;
      yellow = raw.terminal_dim_yellow;
      blue = raw.terminal_dim_blue;
      magenta = raw.terminal_dim_magenta;
      cyan = raw.terminal_dim_cyan;
    };
  };
in {
  isLight = false;
  rawColors = raw;
  inherit ansi;
  palette = {
    # ─── Backgrounds ──────────────────────────────────────────────────
    inherit (raw) bg;
    bg_dim = raw.bg_float;
    bg_gutter = raw.bg_cursorline;
    bg_float = raw.bg_elevated;
    bg_visual = raw.bg_selection;

    # ─── Foregrounds ──────────────────────────────────────────────────
    inherit (raw) fg;
    inherit (raw) fg_dim;
    fg_reverse = raw.fg_bright;

    # ─── UI Elements ──────────────────────────────────────────────────
    accent = raw.cyan;
    accent_dim = raw.steel;
    inherit (raw) border;
    selection = raw.bg_selection;
    overlay = raw.fg_comment;

    # ─── Semantic Colors ──────────────────────────────────────────────
    red = raw.error;
    red_bright = raw.terminal_bright_red;
    red_dim = raw.terminal_dim_red;
    # `green` stays the semantic success color; the ANSI green (sage) is
    # available through `ansi.normal.green`.
    green = raw.ok;
    yellow = raw.gold;
    yellow_bright = raw.terminal_bright_yellow;
    blue = raw.terminal_blue;
    blue_bright = raw.terminal_bright_blue;
    orange = raw.peach;
    violet = raw.purple;
    pink = raw.rose;
    cyan = raw.teal;

    # ─── Special ──────────────────────────────────────────────────────
    inherit transparent;
  };
}
