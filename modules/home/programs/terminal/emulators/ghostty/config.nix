# Palette-generated Ghostty theme plus the adapter's hybrid resolution.
#
# `resolve` prefers the family's exact official resource when it covers the
# active variant and otherwise falls back to a conf generated from the shared
# palette and ANSI table. A family may ship an official resource for only some
# variants (Sora dark); an integration that does not cover the active variant is
# treated as absent so generation takes over. A malformed integration still
# reaches `resolveApp` and throws, keeping broken declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable XDG id for the generated conf. Must not collide with a vendored
  # theme basename.
  generatedId = "aytordev";

  # Ghostty's cursor-smear shader. The adapter mirrors it under
  # `xdg.configFile."ghostty/shaders/<id>"` and points `custom-shader` at it.
  cursorShader = "cursor_smear.glsl";

  # ANSI terminal slots in index order: 0-7 normal, 8-15 bright.
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

  slotColor = ansi: index: let
    group =
      if index < 8
      then ansi.normal
      else ansi.bright;
    name = builtins.elemAt ansiOrder (lib.mod index 8);
  in
    group.${name}.hex;

  # Ghostty conf text: semantic palette for chrome, ANSI table for slots 0-15.
  render = {
    palette,
    ansi,
  }: let
    chrome = [
      "background = ${palette.bg.hex}"
      "foreground = ${palette.fg.hex}"
      "cursor-color = ${palette.fg_dim.hex}"
      "cursor-text = ${palette.bg.hex}"
      "selection-background = ${palette.selection.hex}"
      "selection-foreground = ${palette.fg.hex}"
    ];
    slots = map (index: "palette = ${toString index}=${slotColor ansi index}") (lib.range 0 15);
  in
    lib.concatStringsSep "\n" (chrome ++ slots) + "\n";

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated conf win. Malformed integrations pass through so
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
      app = "ghostty";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # XDG entry for the generated conf, materialized only when the resolution
  # selected it (never for an official or opted-out selection).
  generatedFile = {
    resolution,
    text,
  }:
    lib.optionalAttrs (resolution.kind == "generated") {
      "ghostty/themes/${resolution.id}.conf".text = text;
    };

  # Compose the extra XDG config entries. Pure (plain attrset composition) so
  # tests can assert which artifacts deploy under each flag. `enableThemes` is
  # the master switch for cosmetic files, so `enableThemes = false` leaves no
  # dangling `theme`/`custom-shader` setting. The previous
  # `lib.mkIf condition attrs // shaderSymlinks` form silently dropped every
  # key except the `mkIf` content, which is why shaders never reached disk.
  xdgEntries = {
    enableThemes,
    themeEntries ? {},
    generated ? {},
    shaderEntries ? {},
  }:
    lib.optionalAttrs enableThemes themeEntries
    // lib.optionalAttrs enableThemes generated
    // lib.optionalAttrs enableThemes shaderEntries;
}
