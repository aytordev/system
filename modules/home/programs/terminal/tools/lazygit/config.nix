# Lazygit theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. An official resource
# is used only when the active family ships a Lazygit integration that covers
# the active variant (Sora is dark-only; Kanagawa ships none); otherwise a theme
# generated from the shared palette takes over. A malformed integration is
# passed through to `resolveApp` so the declaration fails loudly.
#
# Upstream Lazygit themes are YAML fragments merged under `gui`. They are
# vendored as Nix data (`official-themes.nix`) so resolution never parses YAML
# at evaluation time; the integration carries the provenance and revision.
{
  lib,
  resolveApp,
}: rec {
  # Stable name of the palette-generated theme. Never collides with a vendored
  # upstream theme id.
  generatedId = "aytordev";

  # Vendored upstream `gui` fragments, keyed by family then integration id.
  officialThemes = import ./official-themes.nix;

  # Integration id -> gui fragment flattened across families, so an explicit
  # override can name any vendored theme regardless of the active family.
  officialById = lib.foldl' (acc: family: acc // family) {} (builtins.attrValues officialThemes);

  # Palette -> Lazygit theme map. Mirrors the exact keys the upstream ports
  # define so official and generated resources stay interchangeable.
  generatedTheme = palette: {
    activeBorderColor = [
      palette.accent.hex
      "bold"
    ];
    inactiveBorderColor = [palette.fg_dim.hex];
    searchingActiveBorderColor = [
      palette.yellow.hex
      "bold"
    ];
    optionsTextColor = [palette.blue.hex];
    selectedLineBgColor = [palette.bg_visual.hex];
    inactiveViewSelectedLineBgColor = [palette.bg_dim.hex];
    cherryPickedCommitFgColor = [palette.accent.hex];
    cherryPickedCommitBgColor = [palette.bg_gutter.hex];
    markedBaseCommitFgColor = [palette.blue.hex];
    markedBaseCommitBgColor = [palette.yellow.hex];
    unstagedChangesColor = [palette.red.hex];
    defaultFgColor = [palette.fg.hex];
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated theme win. Malformed integrations pass through so
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
      app = "lazygit";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # `gui` fragment for a resolution. `none` emits nothing so Lazygit keeps its
  # own default theme; `generated` emits the palette theme; an official or
  # explicit selection emits the vendored upstream fragment (theme plus any
  # authorColors the port ships). An unknown explicit id emits nothing.
  guiSelection = {
    resolution,
    palette,
  }:
    if resolution.kind == "none"
    then {}
    else if resolution.kind == "generated" || resolution.id == generatedId
    then {theme = generatedTheme palette;}
    else officialById.${resolution.id} or {};
}
