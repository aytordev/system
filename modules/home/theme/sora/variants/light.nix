# Sora Light - SYNTHETIC companion variant
# Sora ships only a dark palette. This light variant is a locally derived,
# unofficial companion so light/dark-following apps have something coherent.
# It keeps Sora's cool hues but darkens the accents for contrast on a light
# canvas. Treat it as approximate, not as an upstream Sora theme.
{
  mkColor,
  transparent,
}: let
  raw = {
    # ─── Backgrounds ───────────────────────────────────────────────────
    bg = mkColor "#eef1f7";
    bg_float = mkColor "#f6f8fc";
    bg_elevated = mkColor "#ffffff";
    bg_cursorline = mkColor "#e4e8f1";
    bg_selection = mkColor "#d5dcea";
    bg_search = mkColor "#cfe0f5";
    bg_statusline = mkColor "#e8ecf4";

    # ─── Foregrounds ───────────────────────────────────────────────────
    fg = mkColor "#2a3242";
    fg_dim = mkColor "#5c6678";
    fg_bright = mkColor "#161b26";
    fg_comment = mkColor "#7a8496";
    fg_gutter = mkColor "#aeb6c6";
    fg_gutter_active = mkColor "#6a7488";

    # ─── Syntax ────────────────────────────────────────────────────────
    cyan = mkColor "#2f7f9e";
    purple = mkColor "#6a5aa8";
    sage = mkColor "#3f8a5c";
    rose = mkColor "#b0567a";
    gold = mkColor "#9a7a2e";
    peach = mkColor "#b06a3c";
    teal = mkColor "#2f8a86";
    steel = mkColor "#5a6b88";

    # ─── UI ────────────────────────────────────────────────────────────
    border = mkColor "#c6cddb";
    separator = mkColor "#d5dbe6";
    match_paren = mkColor "#9a7a2e";
    guide = mkColor "#e4e8f1";
    guide_active = mkColor "#c9d0de";
    nontext = mkColor "#cdd3df";
    bg_selected = mkColor "#dbe2ee";

    # ─── Diagnostics ───────────────────────────────────────────────────
    error = mkColor "#b04a5a";
    warning = mkColor "#9a7a2e";
    info = mkColor "#2f7f9e";
    hint = mkColor "#2f8a86";
    ok = mkColor "#3f8a5c";

    # ─── Git ───────────────────────────────────────────────────────────
    git_add = mkColor "#3f8a5c";
    git_change = mkColor "#3a6f96";
    git_delete = mkColor "#b04a5a";
    git_ignore = mkColor "#8a94a8";

    # ─── Terminal ──────────────────────────────────────────────────────
    terminal_black = mkColor "#2a3242";
    terminal_red = mkColor "#b04a5a";
    terminal_green = mkColor "#3f8a5c";
    terminal_yellow = mkColor "#9a7a2e";
    terminal_blue = mkColor "#2f7f9e";
    terminal_magenta = mkColor "#6a5aa8";
    terminal_cyan = mkColor "#2f8a86";
    terminal_white = mkColor "#e8ecf4";
    terminal_bright_black = mkColor "#5c6678";
    terminal_bright_red = mkColor "#c85a68";
    terminal_bright_green = mkColor "#4fa06c";
    terminal_bright_yellow = mkColor "#b0903f";
    terminal_bright_blue = mkColor "#4a9cbc";
    terminal_bright_magenta = mkColor "#8a7ac0";
    terminal_bright_cyan = mkColor "#4aa8a2";
    terminal_bright_white = mkColor "#f6f8fc";
    terminal_dim_red = mkColor "#9a5660";
    terminal_dim_green = mkColor "#6a9878";
    terminal_dim_yellow = mkColor "#a89060";
    terminal_dim_blue = mkColor "#6098b0";
    terminal_dim_magenta = mkColor "#8878a8";
    terminal_dim_cyan = mkColor "#588880";
  };
  # SYNTHETIC ANSI set: derived locally so the light companion has terminal
  # data, mirroring the upstream `terminal_*` layout. Not an upstream Sora
  # artifact.
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
  isLight = true;
  rawColors = raw;
  inherit ansi;
  palette = {
    # ─── Backgrounds ──────────────────────────────────────────────────
    inherit (raw) bg;
    bg_dim = raw.bg_cursorline;
    bg_gutter = raw.bg_selection;
    inherit (raw) bg_float;
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
    # `green` stays the semantic success color; the synthetic ANSI green is
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
