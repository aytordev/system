# Zed theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. An official resource
# is used only when the active family ships a Zed integration that covers the
# active variant; otherwise a theme JSON generated from the shared palette (and
# ANSI table) takes over. A malformed integration is passed through to
# `resolveApp` so the declaration fails loudly.
#
# Zed matches the `theme` setting against a theme's own `name` (see
# `crates/theme/src/registry.rs`), so the generated family and its single theme
# share `generatedId`. The adapter never writes a file for an official,
# explicit or opt-out selection: extension themes are installed by Zed itself.
{
  lib,
  resolveApp,
}: rec {
  # Stable XDG id for the generated theme, used as file stem, family name,
  # theme name and `theme` setting value. Must not collide with an extension
  # theme that ships with the configured extensions.
  generatedId = "aytordev";

  author = "aytordev";

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

  # Zed terminal style keys for the variant ANSI table, so generated Zed
  # terminals match the shared palette. `dim` exists only for providers whose
  # upstream defines it (Sora).
  ansiStyle = ansi:
    lib.mapAttrs' (slot: color: lib.nameValuePair "terminal.ansi.${slot}" color.hex) ansi.normal
    // lib.mapAttrs' (
      slot: color: lib.nameValuePair "terminal.ansi.bright_${slot}" color.hex
    )
    ansi.bright
    // lib.mapAttrs' (slot: color: lib.nameValuePair "terminal.ansi.dim_${slot}" color.hex) (
      ansi.dim or {}
    );

  # Semantic palette to Zed style keys. Zed defaults any omitted key, but a
  # complete mapping keeps the generated theme from inheriting arbitrary colors
  # from whatever was active before.
  paletteStyle = palette: {
    # Surfaces
    background = palette.bg.hex;
    "surface.background" = palette.bg.hex;
    "elevated_surface.background" = palette.bg_float.hex;
    "element.background" = palette.bg_dim.hex;
    "element.hover" = palette.bg_visual.hex;
    "element.active" = palette.selection.hex;
    "element.selected" = palette.bg_visual.hex;
    "element.disabled" = palette.bg_dim.hex;
    "ghost_element.background" = palette.bg.hex;
    "ghost_element.hover" = palette.bg_visual.hex;
    "ghost_element.active" = palette.selection.hex;
    "ghost_element.selected" = palette.bg_visual.hex;
    "ghost_element.disabled" = palette.bg_dim.hex;

    # Borders
    border = palette.border.hex;
    "border.variant" = palette.bg_gutter.hex;
    "border.focused" = palette.accent.hex;
    "border.selected" = palette.accent.hex;
    "border.disabled" = palette.bg_gutter.hex;
    "border.transparent" = palette.transparent.hex;

    # Text
    text = palette.fg.hex;
    "text.muted" = palette.fg_dim.hex;
    "text.placeholder" = palette.fg_dim.hex;
    "text.disabled" = palette.fg_dim.hex;
    "text.accent" = palette.accent.hex;

    # Icons
    icon = palette.fg.hex;
    "icon.muted" = palette.fg_dim.hex;
    "icon.disabled" = palette.fg_dim.hex;
    "icon.placeholder" = palette.fg_dim.hex;
    "icon.accent" = palette.accent.hex;

    # Editor
    "editor.background" = palette.bg.hex;
    "editor.foreground" = palette.fg.hex;
    "editor.gutter.background" = palette.bg.hex;
    "editor.line_number" = palette.fg_dim.hex;
    "editor.active_line_number" = palette.accent.hex;
    "editor.active_line.background" = palette.bg_visual.hex;
    "editor.highlighted_line.background" = palette.bg_visual.hex;
    "editor.invisible" = palette.fg_dim.hex;
    "editor.indent_guide" = palette.bg_gutter.hex;
    "editor.indent_guide_active" = palette.fg_dim.hex;
    "editor.document_highlight.read_background" = palette.bg_visual.hex;
    "editor.document_highlight.write_background" = palette.bg_visual.hex;
    "editor.document_highlight.bracket_background" = palette.bg_visual.hex;
    "editor.active_wrap_guide" = palette.bg_gutter.hex;
    "editor.wrap_guide" = palette.bg_gutter.hex;

    # Panels, bars and tabs
    "panel.background" = palette.bg.hex;
    "panel.focused_border" = palette.accent.hex;
    "pane.focused_border" = palette.accent.hex;
    "pane_group.border" = palette.bg_gutter.hex;
    "status_bar.background" = palette.bg_dim.hex;
    "title_bar.background" = palette.bg_dim.hex;
    "title_bar.inactive_background" = palette.bg_dim.hex;
    "toolbar.background" = palette.bg_dim.hex;
    "tab_bar.background" = palette.bg_dim.hex;
    "tab.active_background" = palette.bg.hex;
    "tab.inactive_background" = palette.bg_dim.hex;

    # Scrollbar
    "scrollbar.thumb.background" = palette.bg_gutter.hex;
    "scrollbar.thumb.hover_background" = palette.fg_dim.hex;
    "scrollbar.thumb.border" = palette.bg.hex;
    "scrollbar.track.background" = palette.bg.hex;
    "scrollbar.track.border" = palette.border.hex;

    # Diagnostics and git status
    error = palette.red.hex;
    "error.background" = palette.red_dim.hex;
    "error.border" = palette.red.hex;
    warning = palette.yellow.hex;
    "warning.background" = palette.bg_visual.hex;
    "warning.border" = palette.yellow.hex;
    success = palette.green.hex;
    "success.background" = palette.bg_visual.hex;
    "success.border" = palette.green.hex;
    info = palette.blue.hex;
    "info.background" = palette.bg_visual.hex;
    "info.border" = palette.blue.hex;
    hint = palette.cyan.hex;
    "hint.background" = palette.bg_visual.hex;
    "hint.border" = palette.cyan.hex;
    conflict = palette.orange.hex;
    "conflict.background" = palette.bg_visual.hex;
    "conflict.border" = palette.orange.hex;
    created = palette.green.hex;
    "created.background" = palette.bg_visual.hex;
    "created.border" = palette.green.hex;
    deleted = palette.red.hex;
    "deleted.background" = palette.bg_visual.hex;
    "deleted.border" = palette.red.hex;
    modified = palette.blue.hex;
    "modified.background" = palette.bg_visual.hex;
    "modified.border" = palette.blue.hex;
    renamed = palette.blue_bright.hex;
    "renamed.background" = palette.bg_visual.hex;
    "renamed.border" = palette.blue_bright.hex;
    ignored = palette.fg_dim.hex;
    "ignored.background" = palette.bg_dim.hex;
    "ignored.border" = palette.bg_gutter.hex;
    hidden = palette.fg_dim.hex;
    "hidden.background" = palette.bg_dim.hex;
    "hidden.border" = palette.bg_gutter.hex;
    unreachable = palette.fg_dim.hex;
    "unreachable.background" = palette.bg_dim.hex;
    "unreachable.border" = palette.bg_gutter.hex;
    predictive = palette.fg_dim.hex;
    "predictive.background" = palette.bg_visual.hex;
    "predictive.border" = palette.bg_gutter.hex;
    "link_text.hover" = palette.cyan.hex;
    "search.match_background" = palette.selection.hex;
    "drop_target.background" = palette.bg_visual.hex;

    # Terminal chrome
    "terminal.background" = palette.bg.hex;
    "terminal.foreground" = palette.fg.hex;
    "terminal.bright_foreground" = palette.fg.hex;
    "terminal.dim_foreground" = palette.fg_dim.hex;
    "terminal.ansi.background" = palette.bg.hex;

    # Accent picker
    accents = [
      palette.accent.hex
      palette.cyan.hex
      palette.green.hex
      palette.yellow.hex
      palette.orange.hex
      palette.pink.hex
      palette.violet.hex
    ];
  };

  # Zed theme-family JSON text. `isLight` selects the appearance; passing the
  # variant ANSI table adds the terminal slots. `builtins.toJSON` guarantees the
  # emitted artifact parses.
  render = {
    palette,
    ansi ? null,
    isLight ? false,
  }:
    builtins.toJSON {
      "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
      name = generatedId;
      inherit author;
      themes = [
        {
          name = generatedId;
          appearance =
            if isLight
            then "light"
            else "dark";
          style = paletteStyle palette // lib.optionalAttrs (ansi != null) (ansiStyle ansi);
        }
      ];
    };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise generation wins. A malformed integration passes through so
  # `resolveApp` can report it.
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
      app = "zed";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # The `theme` setting for a resolution: the resolved id for an explicit,
  # official or generated selection; `none` opts out entirely.
  themeSetting = resolution:
    if resolution.kind == "none"
    then {}
    else {theme = resolution.id;};

  # `xdg.configFile` entries for the generated theme. Materialized only when
  # the resolver selected generated (never for official, explicit or none).
  themeFiles = {
    resolution,
    text,
  }:
    lib.optionalAttrs (resolution.kind == "generated") {
      "zed/themes/${resolution.id}.json".text = text;
    };
}
