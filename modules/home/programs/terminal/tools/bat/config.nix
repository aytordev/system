# Palette-generated bat tmTheme plus the adapter's hybrid resolution.
#
# `resolve` prefers the family's exact official tmTheme when it covers the
# active variant and otherwise falls back to a tmTheme generated from the shared
# palette and ANSI table. A family may ship an official resource for only some
# variants (Kanagawa is wave-only, Sora is dark-only); an integration that does
# not cover the active variant is treated as absent so generation takes over. A
# malformed integration still reaches `resolveApp` and throws, keeping broken
# declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable theme name for the generated tmTheme. Must not collide with a
  # vendored official theme name.
  generatedId = "aytordev";

  # Vendored official tmTheme files, keyed by the exact theme name declared
  # inside each plist (the id bat selects via `--theme`). Kanagawa's upstream
  # file declares the single name "Kanagawa" and matches only the wave palette.
  officialThemes = {
    "Kanagawa" = ./themes/kanagawa-wave.tmTheme;
    "Sora" = ./themes/sora.tmTheme;
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated tmTheme win. Malformed integrations pass through
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
      app = "bat";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };
  # `<key>k</key><string>v</string>` entries, concatenated. Whitespace is
  # irrelevant to the plist parser, so entries stay compact.
  plistEntries = pairs: lib.concatStrings (map (pair: "<key>${pair.key}</key><string>${pair.value}</string>") pairs);

  # A scope entry: a display name, the TextMate scope it targets, and its
  # settings (foreground plus an optional font style).
  scopeEntry = {
    name,
    scope,
    fg,
    fontStyle ? null,
  }:
    "<dict>"
    + "<key>name</key><string>${name}</string>"
    + "<key>scope</key><string>${scope}</string>"
    + "<key>settings</key><dict>"
    + plistEntries (
      [
        {
          key = "foreground";
          value = fg;
        }
      ]
      ++ lib.optional (fontStyle != null) {
        key = "fontStyle";
        value = fontStyle;
      }
    )
    + "</dict></dict>";

  # The global entry (no scope) carries chrome from the semantic palette and
  # the syntax scopes take colors from the variant's ANSI table.
  render = {
    palette,
    ansi,
  }: let
    globalPairs = [
      {
        key = "background";
        value = palette.bg.hex;
      }
      {
        key = "foreground";
        value = palette.fg.hex;
      }
      {
        key = "caret";
        value = palette.fg_dim.hex;
      }
      {
        key = "selection";
        value = palette.selection.hex;
      }
      {
        key = "lineHighlight";
        value = palette.bg_visual.hex;
      }
      {
        key = "gutter";
        value = palette.bg_gutter.hex;
      }
      {
        key = "gutterForeground";
        value = palette.fg_dim.hex;
      }
    ];
    scopes = [
      {
        name = "Comment";
        scope = "comment";
        fg = palette.fg_dim.hex;
        fontStyle = "italic";
      }
      {
        name = "String";
        scope = "string";
        fg = ansi.normal.green.hex;
      }
      {
        name = "Constant";
        scope = "constant";
        fg = ansi.normal.yellow.hex;
      }
      {
        name = "Number";
        scope = "constant.numeric";
        fg = ansi.normal.yellow.hex;
      }
      {
        name = "Keyword";
        scope = "keyword";
        fg = ansi.normal.magenta.hex;
      }
      {
        name = "Storage";
        scope = "storage";
        fg = ansi.normal.magenta.hex;
      }
      {
        name = "Function";
        scope = "entity.name.function";
        fg = ansi.normal.blue.hex;
      }
      {
        name = "Type";
        scope = "entity.name.type";
        fg = ansi.normal.yellow.hex;
      }
      {
        name = "Variable";
        scope = "variable";
        fg = ansi.normal.cyan.hex;
      }
      {
        name = "Operator";
        scope = "keyword.operator";
        fg = ansi.normal.cyan.hex;
      }
      {
        name = "Invalid";
        scope = "invalid";
        fg = palette.red.hex;
      }
    ];
    globalEntry = "<dict><key>settings</key><dict>${plistEntries globalPairs}</dict></dict>";
  in
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    + "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
    + "<plist version=\"1.0\">\n"
    + "<dict>\n"
    + "<key>name</key><string>${generatedId}</string>\n"
    + "<key>settings</key>\n"
    + "<array>\n"
    + globalEntry
    + "\n"
    + lib.concatMapStrings (scope: scopeEntry scope + "\n") scopes
    + "</array>\n"
    + "</dict>\n"
    + "</plist>\n";

  # The `programs.bat.themes` src for the resolved selection: the vendored
  # official file for an official id (including a manual override), or the
  # generated tmTheme for the generated id. `none` (and a manual id with no
  # resource) emits nothing.
  themeSources = {
    resolution,
    generatedSource,
  }:
    if resolution.kind == "none"
    then {}
    else if resolution.id == generatedId
    then {"${generatedId}" = generatedSource;}
    else if builtins.hasAttr resolution.id officialThemes
    then {"${resolution.id}" = officialThemes.${resolution.id};}
    else {};
}
