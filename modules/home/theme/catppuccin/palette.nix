# Catppuccin role mapping.
# Maps the official Catppuccin palette onto the shared semantic roles.
# The mapping is identical across variants, so variant files share this helper.
{transparent}: c: {
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
  red_bright = c.maroon;
  red_dim = c.red;
  inherit (c) green;
  inherit (c) yellow;
  yellow_bright = c.yellow;
  inherit (c) blue;
  blue_bright = c.sky;
  orange = c.peach;
  violet = c.mauve;
  inherit (c) pink;
  cyan = c.teal;

  # ─── Special ──────────────────────────────────────────────────────
  inherit transparent;
}
