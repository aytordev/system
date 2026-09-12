# Palette-generated Zellij theme plus the adapter's hybrid resolution.
#
# `resolve` prefers the active family's exact official resource when it covers
# the active variant and otherwise falls back to a theme generated from the
# shared palette. A family may ship no Zellij resource at all (Sora, Kanagawa);
# an integration that does not cover the active variant is treated as absent so
# generation takes over. A malformed integration still reaches `resolveApp` and
# throws, keeping broken declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable theme name for the generated palette theme. Never collides with a
  # vendored upstream theme name.
  generatedId = "aytordev";

  # Vendored upstream theme files, keyed by family. catppuccin/zellij ships one
  # `catppuccin.kdl` registering all four flavors, under the exact names the
  # integration declares (`catppuccin-<flavor>`), so a single file serves every
  # variant. `officialName` is the file stem Zellij loads from
  # `$XDG_CONFIG_HOME/zellij/themes/<name>.kdl`.
  officialThemeFiles = {
    catppuccin = ./themes/catppuccin.kdl;
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
      app = "zellij";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # `settings.theme = <name>` when a theme is selected; no key for an opt-out,
  # so `none` leaves the app on its own default theme.
  themeSetting = resolution:
    lib.optionalAttrs (resolution.kind != "none") {
      theme = resolution.id;
    };

  # Palette -> Zellij theme keys, kept identical to the previously inlined
  # theme so the extraction is behavior-preserving.
  themeColors = palette: {
    bg = palette.bg.hex;
    fg = palette.fg.hex;
    red = palette.red.hex;
    green = palette.green.hex;
    yellow = palette.yellow.hex;
    blue = palette.accent.hex;
    magenta = palette.violet.hex;
    orange = palette.orange.hex;
    cyan = palette.cyan.hex;
    black = palette.bg_dim.hex;
    white = palette.fg_reverse.hex;
  };

  # Standalone theme-file text: `themes { aytordev { ... } }`, the shape Zellij
  # loads from `$XDG_CONFIG_HOME/zellij/themes/*.kdl`.
  render = {palette}: let
    colors = themeColors palette;
    lines = map (name: "    ${name} \"${colors.${name}}\"") (builtins.attrNames colors);
  in "themes {\n  ${generatedId} {\n${lib.concatStringsSep "\n" lines}\n  }\n}\n";

  # `programs.zellij.themes` entries: the active family's vendored file when it
  # has one, plus the generated theme only when the resolver selected it.
  themeFiles = {
    officialName ? null,
    officialFile ? null,
    resolution,
    generatedText ? "",
  }:
    lib.optionalAttrs (resolution.kind != "none" && officialName != null && officialFile != null) {
      ${officialName} = officialFile;
    }
    // lib.optionalAttrs (resolution.kind == "generated") {
      ${resolution.id} = generatedText;
    };
}
