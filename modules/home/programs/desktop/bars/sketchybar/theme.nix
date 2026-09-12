# Sketchybar theme adapter.
#
# Sketchybar ships no upstream theme resource for any family, so it is a
# palette-generated hybrid consumer: the strict `resolveApp` policy would always
# select generation. The constants therefore come from the active variant's
# semantic palette plus its verbatim ANSI table, and `themes` carries every
# registered family/variant so the Lua runtime picker can switch without a Nix
# rebuild.
#
# Chrome/neutral roles come from the semantic palette; the standard ANSI slot
# names (red/green/yellow/blue/magenta/cyan and their bright counterparts) come
# from the variant's ANSI table, matching the Ghostty/Starship/bat convention.
# `themes` and `colors` are derived by the same function, so a runtime switch
# yields exactly the colors a rebuild would have produced.
{lib}: rec {
  # ANSI terminal slots in index order: 0-7 normal, 8-15 bright.
  ansiSlots = [
    "black"
    "red"
    "green"
    "yellow"
    "blue"
    "magenta"
    "cyan"
    "white"
  ];

  # Map one variant (palette + ANSI table) to the flat structure the Lua config
  # expects. ANSI-named slots come from the ANSI table; everything else from the
  # semantic palette.
  colors = {
    palette,
    ansi,
  }: {
    default = palette.fg.sketchybar;
    black = palette.bg_dim.sketchybar;
    white = palette.fg.sketchybar;
    red = ansi.normal.red.sketchybar;
    red_bright = ansi.bright.red.sketchybar;
    green = ansi.normal.green.sketchybar;
    blue = ansi.normal.blue.sketchybar;
    blue_bright = ansi.bright.blue.sketchybar;
    yellow = ansi.normal.yellow.sketchybar;
    orange = palette.orange.sketchybar;
    magenta = ansi.normal.magenta.sketchybar;
    grey = palette.fg_dim.sketchybar;
    transparent = palette.transparent.sketchybar;

    bar = {
      bg = builtins.replaceStrings ["0xff"] ["0xf0"] palette.bg.sketchybar;
      border = palette.border.sketchybar;
    };

    popup = {
      bg = palette.bg.sketchybar;
      border = palette.border.sketchybar;
    };

    bg1 = palette.bg.sketchybar;
    bg2 = palette.border.sketchybar;

    accent = palette.accent.sketchybar;
    accent_bright = palette.accent_dim.sketchybar;

    pink = palette.pink.sketchybar;
    cyan = ansi.normal.cyan.sketchybar;

    spotify_green = ansi.normal.green.sketchybar;
  };

  # Every registered family/variant, keyed "<family>/<variant>". `providers` is
  # `aytordev.theme.providers`: each family exposes `variants` (palettes) and
  # `ansi` (per-variant ANSI tables).
  themes = providers:
    lib.concatMapAttrs (
      family: provider:
        lib.mapAttrs' (
          variant: palette:
            lib.nameValuePair "${family}/${variant}" (colors {
              inherit palette;
              ansi = provider.ansi.${variant};
            })
        )
        provider.variants
    )
    providers;

  # The generated constants consumed by `nix_constants.lua`: the active
  # variant's colors, every variant palette, and the active "<family>/<variant>"
  # key. `theme` is `aytordev.theme`.
  constants = {
    theme,
    providers,
  }: {
    colors = colors {inherit (theme) palette ansi;};
    themes = themes providers;
    active_theme = "${theme.name}/${theme.variant}";
  };
}
