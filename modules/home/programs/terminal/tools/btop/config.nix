# Palette-generated btop theme plus the adapter's hybrid resolution.
#
# `resolve` prefers the family's exact official `.theme` when it covers the
# active variant and otherwise falls back to a theme generated from the shared
# palette and ANSI table. A family may ship an official resource for only some
# variants (Sora is dark-only); an integration that does not cover the active
# variant is treated as absent so generation takes over. A malformed integration
# still reaches `resolveApp` and throws, keeping broken declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable theme id for the generated `.theme`. Must not collide with a vendored
  # official theme id.
  generatedId = "aytordev";

  # Vendored official `.theme` files, keyed by the exact id the integration
  # declares and btop selects via `color_theme` (btop reads
  # `$XDG_CONFIG_HOME/btop/themes/<id>.theme`). Sora's comes from
  # `Aejkatappaja/sora` @ 504df4913c55dd9ad658e331b172f86b0537b439.
  officialThemes = {
    sora = ./themes/sora.theme;
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated theme win. Malformed integrations pass through
  # so `resolveApp` can report them.
  selectOfficial = {
    integration,
    variant,
  }:
    if integration == null
    then null
    else if !(builtins.isAttrs integration)
    then integration
    else if !(integration ? variants)
    then integration
    else if (integration.variants or {}) ? ${variant}
    then integration
    else null;

  resolve = {
    variant,
    override ? null,
    integration ? null,
  }:
    resolveApp {
      app = "btop";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # btop theme key -> color, in the upstream `.theme` order. Chrome and the box
  # outlines come from the semantic palette; the graph gradients come from the
  # variant's ANSI table, the colors btop actually paints.
  entries = {
    palette,
    ansi,
  }: [
    {
      key = "main_bg";
      color = palette.bg;
    }
    {
      key = "main_fg";
      color = palette.fg;
    }
    {
      key = "title";
      color = palette.fg;
    }
    {
      key = "hi_fg";
      color = palette.accent;
    }
    {
      key = "selected_bg";
      color = palette.selection;
    }
    {
      key = "selected_fg";
      color = palette.accent;
    }
    {
      key = "inactive_fg";
      color = palette.fg_dim;
    }
    {
      key = "graph_text";
      color = ansi.normal.white;
    }
    {
      key = "meter_bg";
      color = palette.bg_gutter;
    }
    {
      key = "proc_misc";
      color = palette.accent;
    }
    {
      key = "cpu_box";
      color = palette.blue;
    }
    {
      key = "mem_box";
      color = palette.green;
    }
    {
      key = "net_box";
      color = palette.red;
    }
    {
      key = "proc_box";
      color = palette.accent;
    }
    {
      key = "div_line";
      color = palette.border;
    }
    {
      key = "temp_start";
      color = palette.green;
    }
    {
      key = "temp_mid";
      color = palette.yellow;
    }
    {
      key = "temp_end";
      color = palette.red;
    }
    {
      key = "cpu_start";
      color = ansi.normal.cyan;
    }
    {
      key = "cpu_mid";
      color = ansi.normal.blue;
    }
    {
      key = "cpu_end";
      color = ansi.bright.blue;
    }
    {
      key = "free_start";
      color = palette.violet;
    }
    {
      key = "free_mid";
      color = palette.blue;
    }
    {
      key = "free_end";
      color = palette.blue_bright;
    }
    {
      key = "cached_start";
      color = palette.cyan;
    }
    {
      key = "cached_mid";
      color = palette.blue;
    }
    {
      key = "cached_end";
      color = palette.violet;
    }
    {
      key = "available_start";
      color = palette.orange;
    }
    {
      key = "available_mid";
      color = palette.red;
    }
    {
      key = "available_end";
      color = palette.red_bright;
    }
    {
      key = "used_start";
      color = palette.green;
    }
    {
      key = "used_mid";
      color = palette.cyan;
    }
    {
      key = "used_end";
      color = palette.cyan;
    }
    {
      key = "download_start";
      color = palette.orange;
    }
    {
      key = "download_mid";
      color = palette.red;
    }
    {
      key = "download_end";
      color = palette.red_bright;
    }
    {
      key = "upload_start";
      color = palette.green;
    }
    {
      key = "upload_mid";
      color = palette.cyan;
    }
    {
      key = "upload_end";
      color = palette.cyan;
    }
    {
      key = "process_start";
      color = palette.cyan;
    }
    {
      key = "process_mid";
      color = palette.blue;
    }
    {
      key = "process_end";
      color = palette.violet;
    }
  ];

  # btop `.theme` text: one `theme[key]="#rrggbb"` line per entry.
  render = {
    palette,
    ansi,
  }:
    lib.concatStringsSep "\n" (
      map (entry: "theme[${entry.key}]=\"${entry.color.hex}\"") (entries {
        inherit palette ansi;
      })
    )
    + "\n";

  # The `programs.btop.themes` view for the resolved selection: the vendored
  # official file for an official id (including a manual override), or the
  # generated theme text for the generated id. `none` (and an unknown manual id)
  # emits nothing.
  themeSources = {
    resolution,
    generatedText,
  }:
    if resolution.kind == "none"
    then {}
    else if resolution.id == generatedId
    then {"${generatedId}" = generatedText;}
    else if builtins.hasAttr resolution.id officialThemes
    then {"${resolution.id}" = officialThemes.${resolution.id};}
    else {};

  # `programs.btop.settings` composition. The caller's base settings are left
  # untouched (truecolor, theme_background and every other option survive); the
  # resolved theme is layered on as `color_theme`, or omitted for `none` so btop
  # keeps its own default.
  settings = {
    base,
    resolution,
  }:
    base
    // lib.optionalAttrs (resolution.kind != "none") {
      color_theme = resolution.id;
    };
}
