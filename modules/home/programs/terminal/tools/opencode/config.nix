# OpenCode theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. An official resource
# is used only when the active family ships an OpenCode integration that covers
# the active variant (Sora is dark-only; Kanagawa ships none); otherwise a theme
# generated from the shared palette/ANSI table takes over. A malformed
# integration is passed through to `resolveApp` so the declaration fails loudly.
#
# Upstream OpenCode themes are JSON documents under the app config `themes/`
# directory and are selected by name (`tui.theme`). The official ports are
# vendored verbatim under `themes/`; the generated theme uses the same 52-key
# schema so official and generated resources stay interchangeable.
{
  lib,
  resolveApp,
}: rec {
  # Stable theme name for the generated JSON. Must not collide with a vendored
  # official theme id.
  generatedId = "aytordev";

  # Vendored official theme JSONs, keyed by the exact id the integration
  # declares and OpenCode selects via `tui.theme`.
  # Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439,
  # `extras/opencode/sora.json`.
  officialThemes = {
    sora = ./themes/sora.json;
  };

  # ANSI terminal slots in index order.
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
      app = "opencode";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Build a `{ dark = ref; light = ref; }` color reference. OpenCode resolves a
  # reference against `defs`; the active variant provides one color set, so both
  # terminal polarities use it.
  both = ref: {
    inherit ref;
    dark = ref;
    light = ref;
  };

  # Render the OpenCode theme schema from a variant palette and ANSI table.
  # `defs` carries the concrete hexes and `theme` names the roles, mirroring the
  # upstream port shape so the file is valid standalone JSON.
  render = {
    palette,
    ansi,
  }: let
    slot = group: name: ansi.${group}.${name}.hex;
    defs = {
      # Chrome
      background = palette.bg.hex;
      backgroundPanel = palette.bg_dim.hex;
      backgroundElement = palette.bg_float.hex;
      backgroundGutter = palette.bg_gutter.hex;
      text = palette.fg.hex;
      textMuted = palette.fg_dim.hex;
      textReverse = palette.fg_reverse.hex;
      primary = palette.accent.hex;
      secondary = palette.violet.hex;
      accent = palette.pink.hex;
      border = palette.border.hex;
      selection = palette.selection.hex;
      # Semantic
      error = palette.red.hex;
      warning = palette.yellow.hex;
      success = palette.green.hex;
      info = palette.cyan.hex;
      orange = palette.orange.hex;
      # ANSI terminal table
      ansiBlack = slot "normal" "black";
      ansiRed = slot "normal" "red";
      ansiGreen = slot "normal" "green";
      ansiYellow = slot "normal" "yellow";
      ansiBlue = slot "normal" "blue";
      ansiMagenta = slot "normal" "magenta";
      ansiCyan = slot "normal" "cyan";
      ansiWhite = slot "normal" "white";
      ansiBrightBlack = slot "bright" "black";
      ansiBrightRed = slot "bright" "red";
      ansiBrightGreen = slot "bright" "green";
      ansiBrightYellow = slot "bright" "yellow";
      ansiBrightBlue = slot "bright" "blue";
      ansiBrightMagenta = slot "bright" "magenta";
      ansiBrightCyan = slot "bright" "cyan";
      ansiBrightWhite = slot "bright" "white";
    };
  in {
    "$schema" = "https://opencode.ai/theme.json";
    inherit defs;
    theme = {
      primary = both "primary";
      secondary = both "secondary";
      accent = both "accent";
      error = both "error";
      warning = both "warning";
      success = both "success";
      info = both "info";
      text = both "text";
      textMuted = both "textMuted";
      selectedListItemText = both "textReverse";
      background = both "background";
      backgroundPanel = both "backgroundPanel";
      backgroundElement = both "backgroundElement";
      backgroundMenu = both "backgroundPanel";
      border = both "border";
      borderActive = both "primary";
      borderSubtle = both "backgroundGutter";
      diffAdded = both "ansiGreen";
      diffRemoved = both "ansiRed";
      diffContext = both "textMuted";
      diffHunkHeader = both "secondary";
      diffHighlightAdded = both "success";
      diffHighlightRemoved = both "error";
      diffAddedBg = both "backgroundGutter";
      diffRemovedBg = both "backgroundGutter";
      diffContextBg = both "background";
      diffLineNumber = both "textMuted";
      diffAddedLineNumberBg = both "backgroundGutter";
      diffRemovedLineNumberBg = both "backgroundGutter";
      markdownText = both "text";
      markdownHeading = both "primary";
      markdownLink = both "ansiBlue";
      markdownLinkText = both "ansiCyan";
      markdownCode = both "ansiGreen";
      markdownBlockQuote = both "ansiYellow";
      markdownEmph = both "ansiYellow";
      markdownStrong = both "orange";
      markdownHorizontalRule = both "textMuted";
      markdownListItem = both "ansiBlue";
      markdownListEnumeration = both "ansiCyan";
      markdownImage = both "ansiBlue";
      markdownImageText = both "ansiCyan";
      markdownCodeBlock = both "text";
      syntaxComment = both "textMuted";
      syntaxKeyword = both "ansiMagenta";
      syntaxFunction = both "ansiBlue";
      syntaxVariable = both "ansiRed";
      syntaxString = both "ansiGreen";
      syntaxNumber = both "ansiYellow";
      syntaxType = both "ansiYellow";
      syntaxOperator = both "ansiCyan";
      syntaxPunctuation = both "text";
    };
  };

  # `programs.opencode.tui` entry for a resolution. `none` must not write a
  # theme selection so OpenCode keeps its own default theme.
  themeEntry = resolution:
    lib.optionalAttrs (resolution.kind != "none") {
      theme = resolution.id;
    };
}
