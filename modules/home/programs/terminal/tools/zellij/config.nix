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

  # Vendored upstream theme files, keyed by family. No family currently ships a
  # Zellij resource; any selection falls back to the generated theme.
  # `officialName` is the file stem Zellij loads from
  # `$XDG_CONFIG_HOME/zellij/themes/<name>.kdl`.
  officialThemeFiles = {};

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

  # Map semantic roles directly to Zellij's component schema, avoiding the
  # legacy palette parser's lossy conversion of text and frame colors.
  themeComponents = palette: let
    commonEmphases = ["orange" "cyan" "green" "violet"];
    component = base: background: emphases: let
      roles =
        {inherit base background;}
        // builtins.listToAttrs (lib.imap0 (index: role: {
            name = "emphasis_${toString index}";
            value = role;
          })
          emphases);
    in
      lib.mapAttrs (_: role: palette.${role}.hex) roles;
  in {
    text_unselected = component "fg" "bg" commonEmphases;
    text_selected = component "fg" "selection" commonEmphases;
    ribbon_unselected = component "fg_dim" "bg_dim" ["red" "fg" "accent" "violet"];
    ribbon_selected = component "bg" "accent" ["red" "orange" "violet" "accent"];
    table_title = component "accent" "bg_dim" commonEmphases;
    table_cell_unselected = component "fg_dim" "bg" commonEmphases;
    table_cell_selected = component "fg" "selection" commonEmphases;
    list_unselected = component "fg_dim" "bg_dim" commonEmphases;
    list_selected = component "fg" "selection" commonEmphases;
    frame_unselected = component "border" "bg" commonEmphases;
    frame_selected = component "accent" "bg" commonEmphases;
    frame_highlight = component "yellow" "bg" commonEmphases;
    exit_code_success = component "green" "bg" ["cyan" "green" "accent" "violet"];
    exit_code_error = component "red" "bg" ["yellow" "red" "orange" "violet"];
    multiplayer_user_colors = builtins.listToAttrs (lib.imap0 (index: role: {
        name = "player_${toString (index + 1)}";
        value = palette.${role}.hex;
      })
      ["accent" "blue" "violet" "yellow" "cyan" "orange" "red" "fg_dim" "pink" "green"]);
  };

  # Standalone component theme loaded from
  # `$XDG_CONFIG_HOME/zellij/themes/*.kdl`; every color is a quoted hex string.
  render = {palette}: let
    colors = themeComponents palette;
    renderComponent = name: let
      keys =
        if name == "multiplayer_user_colors"
        then map (index: "player_${toString index}") (lib.range 1 10)
        else ["base" "background" "emphasis_0" "emphasis_1" "emphasis_2" "emphasis_3"];
      lines = map (key: "      ${key} \"${colors.${name}.${key}}\"") keys;
    in "    ${name} {\n${lib.concatStringsSep "\n" lines}\n    }";
    components = map renderComponent (builtins.attrNames colors);
  in "themes {\n  ${generatedId} {\n${lib.concatStringsSep "\n" components}\n  }\n}\n";

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
