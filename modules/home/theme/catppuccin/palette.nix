# Catppuccin role mapping.
# Maps the official Catppuccin palette onto the shared semantic roles.
# The mapping is identical across variants, so variant files share this helper.
# Bright roles come from the upstream `ansiColors.bright` set, which diverges
# from the named palette colors (for example mocha bright red is #f37799, not
# the `maroon`/`red` palette entries).
{transparent}: c: ansi: {
  # ─── Backgrounds ──────────────────────────────────────────────────
  bg = c.base;
  bg_dim = c.mantle;
  bg_gutter = c.surface0;
  bg_float = c.surface1;
  bg_visual = c.surface2;

  # ─── Foregrounds ──────────────────────────────────────────────────
  fg = c.text;
  fg_dim = c.subtext0;
  fg_reverse = c.subtext1;

  # ─── UI Elements ──────────────────────────────────────────────────
  accent = c.blue;
  accent_dim = c.lavender;
  border = c.surface1;
  selection = c.surface2;
  overlay = c.overlay0;

  # ─── Semantic Colors ──────────────────────────────────────────────
  inherit (c) red;
  red_bright = ansi.bright.red;
  # Catppuccin has no dim red; the dim role intentionally reuses `red`.
  red_dim = c.red;
  inherit (c) green;
  inherit (c) yellow;
  yellow_bright = ansi.bright.yellow;
  inherit (c) blue;
  blue_bright = ansi.bright.blue;
  orange = c.peach;
  violet = c.mauve;
  inherit (c) pink;
  cyan = c.teal;

  # ─── Special ──────────────────────────────────────────────────────
  inherit transparent;
}
