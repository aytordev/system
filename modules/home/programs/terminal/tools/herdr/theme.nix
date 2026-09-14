# herdr theme adapter: maps the shared semantic palette onto herdr's
# `[theme.custom]` token map so the UI follows `aytordev.theme` in every family.
#
# herdr has no named-theme registry: `theme.name = "terminal"` follows the host
# terminal's ANSI palette, and `[theme.custom]` overrides individual tokens. The
# generated map is family-agnostic; `auto_switch` stays off because the palette
# is fixed per build.
{
  palette,
  ansi ? null,
}: let
  ansiColor = group: slot: fallback:
    if ansi == null
    then fallback
    else ansi.${group}.${slot}.hex;
in {
  name = "terminal";
  auto_switch = false;
  custom = {
    accent = palette.accent.hex;
    panel_bg = palette.bg.hex;
    surface0 = palette.bg_float.hex;
    surface1 = palette.bg_gutter.hex;
    surface_dim = palette.bg_dim.hex;
    overlay0 = palette.overlay.hex;
    overlay1 = palette.accent_dim.hex;
    text = palette.fg.hex;
    subtext0 = palette.fg_dim.hex;
    mauve = palette.violet.hex;
    green = ansiColor "normal" "green" palette.green.hex;
    yellow = palette.yellow.hex;
    red = palette.pink.hex;
    blue = palette.blue.hex;
    teal = palette.cyan.hex;
    peach = palette.orange.hex;
  };
}
