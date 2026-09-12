# Palette-generated Warp theme plus the adapter's hybrid resolution.
#
# `resolve` prefers the family's exact official Warp resource when it covers the
# active variant and otherwise falls back to a YAML generated from the shared
# palette and ANSI table. A family may ship an official resource for only some
# variants; an integration that does not cover the active variant is treated as
# absent so generation takes over. A malformed integration still reaches
# `resolveApp` and throws, keeping broken declarations loud.
#
# Warp has no documented config-file selection: it scans its themes directory
# and the user picks a theme in Settings > Appearance. This adapter therefore
# only materializes resource files (vendored official YAMLs plus a generated
# fallback) and never writes a selection setting.
{
  lib,
  resolveApp,
}: rec {
  # Stable filename for the generated YAML. Must not collide with a vendored
  # theme stem, and is the name Warp shows in the theme picker.
  generatedId = "aytordev";

  # Vendored official Warp theme YAMLs, keyed by the file stem Warp shows in
  # the picker. Catppuccin ships all four flavors; Kanagawa ships all three
  # variants. Kanagawa's provider currently declares no `warp` integration, so
  # its files are kept available even though the resolver does not select them.
  vendoredThemes = {
    catppuccin_latte = ./themes/catppuccin_latte.yaml;
    catppuccin_frappe = ./themes/catppuccin_frappe.yaml;
    catppuccin_macchiato = ./themes/catppuccin_macchiato.yaml;
    catppuccin_mocha = ./themes/catppuccin_mocha.yaml;
    kanagawa_wave = ./themes/kanagawa_wave.yaml;
    kanagawa_dragon = ./themes/kanagawa_dragon.yaml;
    kanagawa_lotus = ./themes/kanagawa_lotus.yaml;
  };

  # The 16 ANSI terminal slots, in the order Warp's theme schema lists them.
  ansiOrder = [
    "black"
    "red"
    "green"
    "yellow"
    "blue"
    "magenta"
    "cyan"
    "white"
  ];

  # ANSI slot hex values for a `normal`/`bright` group, keyed by slot name.
  slotColors = group: lib.genAttrs ansiOrder (name: group.${name}.hex);

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated YAML win. Malformed integrations pass through so
  # `resolveApp` can report them.
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
      app = "warp";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Warp's documented theme schema as plain data: chrome from the semantic
  # palette, the 16 ANSI slots from the variant's ANSI table. `details`
  # reflects the variant polarity (`darker` for dark themes, `lighter` for
  # light ones).
  renderData = {
    palette,
    ansi,
    isLight ? false,
  }: {
    name = generatedId;
    background = palette.bg.hex;
    accent = palette.accent.hex;
    foreground = palette.fg.hex;
    details =
      if isLight
      then "lighter"
      else "darker";
    terminal_colors = {
      normal = slotColors ansi.normal;
      bright = slotColors ansi.bright;
    };
  };

  # Render Warp YAML. Colors are single-quoted because an unquoted `#` starts a
  # YAML comment, which would silently drop the value.
  render = args: let
    data = renderData args;
    slotLines = group: lib.concatMapStrings (name: "    ${name}: '${group.${name}}'\n") ansiOrder;
  in
    "name: ${data.name}\n"
    + "background: '${data.background}'\n"
    + "accent: '${data.accent}'\n"
    + "foreground: '${data.foreground}'\n"
    + "details: ${data.details}\n"
    + "terminal_colors:\n"
    + "  normal:\n"
    + slotLines data.terminal_colors.normal
    + "  bright:\n"
    + slotLines data.terminal_colors.bright;

  # XDG entries for the Warp themes directory, keyed by deployed path. Every
  # vendored YAML is materialized so it is available in the picker; the
  # generated YAML is added only when the resolver selected it. There is no
  # selection entry, since the user chooses in Warp's UI.
  entries = {
    resolution,
    generatedText,
  }:
    lib.mapAttrs' (
      name: path: lib.nameValuePair "warp/themes/${name}.yaml" {source = path;}
    )
    vendoredThemes
    // lib.optionalAttrs (resolution.kind == "generated") {
      "warp/themes/${generatedId}.yaml".text = generatedText;
    };
}
