# Starship theme adapter.
#
# `resolve` implements the hybrid policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. An official resource
# is used only when the active family ships a Starship integration that covers
# the active variant (Sora is dark-only); otherwise the palette generated from
# the shared palette and ANSI table takes over. A malformed integration is
# passed through to `resolveApp` so the declaration fails loudly.
#
# The generated palette keeps this repository's prompt (`format`, modules and
# segments in `default.nix`) and only supplies color names: the standard ANSI
# slots come from the variant's upstream-verbatim ANSI table, the chrome roles
# from the semantic palette. Official selection replaces the palette (and name)
# with the vendored upstream block; it never replaces the prompt itself.
{
  lib,
  resolveApp,
}: rec {
  # Stable name of the palette generated from the shared palette/ANSI table.
  # Must not collide with a vendored official palette id.
  generatedId = "aytordev";

  # Vendored official `[palettes.<name>]` blocks, keyed by family then id.
  officialPalettes = import ./official-palettes.nix;

  # Palette id -> block, flattened across families so an explicit override can
  # name any vendored official palette regardless of the active family.
  officialById = lib.foldl' (acc: family: acc // family) {} (builtins.attrValues officialPalettes);

  # Palette id -> official module-style overlay. A resource that ships module
  # configuration (Sora) contributes its color-bearing fields; resources that
  # are palette-only (Catppuccin) have no entry. `styleOverrides` is deep-merged
  # over the base prompt so its layout and glyphs are preserved.
  officialStyles = import ./official-styles.nix;

  styleOverrides = {resolution}:
    if resolution.kind == "none"
    then {}
    else officialStyles.${resolution.id} or {};

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

  # Generated fallback palette: standard ANSI names (normal + bright) from the
  # variant ANSI table, semantic/chrome names from the shared palette.
  generated = {
    palette,
    ansi,
  }: let
    slots = group: lib.genAttrs ansiSlots (slot: ansi.${group}.${slot}.hex);
    bright = lib.mapAttrs' (name: color: lib.nameValuePair "bright_${name}" color) (slots "bright");
  in
    (slots "normal")
    // bright
    // {
      text = palette.fg.hex;
      teal = palette.cyan.hex;
      peach = palette.orange.hex;
      mauve = palette.accent_dim.hex;
      pink = palette.pink.hex;
      subtext0 = palette.fg_dim.hex;
      subtext1 = palette.fg_reverse.hex;
      overlay0 = palette.bg_gutter.hex;
      overlay1 = palette.bg_visual.hex;
      overlay2 = palette.overlay.hex;
      surface0 = palette.bg_dim.hex;
      surface1 = palette.bg.hex;
      surface2 = palette.bg_gutter.hex;
      base = palette.bg.hex;
      mantle = palette.bg_dim.hex;
      crust = palette.bg_float.hex;
      lavender = palette.blue_bright.hex;
      rosewater = palette.yellow_bright.hex;
      flamingo = palette.red_bright.hex;
      maroon = palette.red_dim.hex;
    };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise generation wins. Malformed integrations pass through so
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
      app = "starship";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Compose the `palette`/`palettes` settings for a resolution. `none` emits
  # nothing; `generated` and `official` point `palette` at the resolved name and
  # define that palette. An explicit override points at the requested name and
  # reuses a vendored/generated block when it is known, otherwise it leaves the
  # palette undefined for the user's own `settings` to supply.
  paletteSelection = {
    resolution,
    palette,
    ansi,
  }: let
    generatedBlock = generated {inherit palette ansi;};
    # Official blocks only name a subset of keys; layer them over the generated
    # (upstream-faithful) block so every key the prompt references resolves to a
    # theme color instead of a terminal default.
    withGenerated = block: generatedBlock // block;
    explicitBlock =
      if resolution.kind == "explicit"
      then
        if resolution.id == generatedId
        then generatedBlock
        else if officialById ? ${resolution.id}
        then withGenerated officialById.${resolution.id}
        else null
      else null;
  in
    if resolution.kind == "none"
    then {}
    else if resolution.kind == "explicit"
    then
      {
        palette = resolution.id;
      }
      // lib.optionalAttrs (explicitBlock != null) {
        palettes.${resolution.id} = explicitBlock;
      }
    else {
      palette = resolution.id;
      palettes.${resolution.id} =
        if resolution.kind == "generated"
        then generatedBlock
        else
          withGenerated (
            officialById.${resolution.id}
                or (throw "starship: no vendored palette for official id '${resolution.id}'")
          );
    };
}
