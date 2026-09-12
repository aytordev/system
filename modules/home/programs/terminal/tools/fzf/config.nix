# FZF theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. FZF has no theme
# *file*: the upstream resources are shell/rc fragments that export
# `FZF_DEFAULT_OPTS` with `--color=<name>:<hex>` specifiers, so the adapter
# yields a color map that the Home Manager `programs.fzf.colors` option renders
# into `--color`. An official map is used only when the active family ships an
# FZF integration that covers the active variant (Sora is dark-only); otherwise
# the map is generated from the shared palette. A malformed integration still
# reaches `resolveApp` and throws, keeping broken declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable id for the palette-generated map. Never collides with a vendored
  # official map key.
  generatedId = "aytordev";

  # Official color maps vendored verbatim from the resource each integration
  # pins; see official-colors.nix for provenance.
  officialColors = import ./official-colors.nix;

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise the generated map wins. Malformed integrations pass through so
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
      app = "fzf";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # FZF color names are semantic, not ANSI slots, so the generated map derives
  # every key from the shared palette (the variant ANSI table is what the
  # terminal renders underneath, not a color FZF names).
  generatedColors = {palette}: {
    bg = palette.bg.hex;
    "bg+" = palette.bg_dim.hex;
    fg = palette.fg.hex;
    "fg+" = palette.fg_reverse.hex;
    hl = palette.red.hex;
    "hl+" = palette.red_bright.hex;
    header = palette.red.hex;
    info = palette.accent.hex;
    prompt = palette.accent.hex;
    pointer = palette.fg_dim.hex;
    marker = palette.accent_dim.hex;
    spinner = palette.fg_dim.hex;
    gutter = palette.bg.hex;
    "selected-bg" = palette.selection.hex;
    border = palette.border.hex;
    label = palette.fg.hex;
  };

  # Color map for a resolution. `none` emits no map (FZF keeps its own
  # defaults); `generated` derives from the palette; an official/explicit
  # selection reuses the vendored map when the id names one. An unknown
  # explicit id emits nothing rather than inventing colors.
  colorsFor = {
    resolution,
    palette,
  }:
    if resolution.kind == "none"
    then {}
    else if resolution.kind == "generated"
    then generatedColors {inherit palette;}
    else lib.attrByPath [resolution.id] {} officialColors;

  # `programs.fzf` settings composition. The caller's base settings are left
  # untouched (existing options, keybindings and shell integration survive);
  # the resolved colors are layered on as `colors`, which Home Manager renders
  # into `FZF_DEFAULT_OPTS`.
  settings = {
    base,
    resolution,
    palette,
  }:
    base // {colors = colorsFor {inherit resolution palette;};};
}
