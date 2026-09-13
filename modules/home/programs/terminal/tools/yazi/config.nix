# Yazi theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. An official resource
# is used only when the active family ships a Yazi integration that covers the
# active variant; otherwise a flavor generated from the shared palette takes
# over. A malformed integration is passed through to `resolveApp` so the
# declaration fails loudly.
#
# Sora ships a single `theme.toml` (not a per-flavor resource). It is vendored
# verbatim and applied as the base theme, never as a flavor.
{
  lib,
  resolveApp,
}: rec {
  # Palette-generated flavor.toml, parameterized by a variant palette.
  generatedFlavor = import ./flavor.nix;

  # Vendored per-flavor official resources, keyed by the provider integration
  # id. No family currently ships a per-flavor Yazi resource; generated
  # selections still deploy their generated flavor.
  officialFlavors = {};

  # Vendored single-file official themes, keyed by the provider integration id.
  # Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439,
  # `extras/yazi/sora.toml`, copied unmodified. Sora is a whole theme, not a
  # per-flavor resource, so it is applied as the base theme.
  officialThemes = {
    sora = ./official/sora.toml;
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
    generated ? null,
  }:
    resolveApp {
      app = "yazi";
      inherit variant override generated;
      official = selectOfficial {inherit integration variant;};
    };

  # `programs.yazi.flavors` entries for a resolution. A generated selection
  # deploys the generated flavor; an official or explicit selection deploys the
  # matching vendored flavor when the id names one. Theme-shaped resources
  # (Sora) and opt-outs contribute no flavor.
  flavorEntries = {
    resolution,
    generatedFlavor,
  }:
    if resolution.kind == "generated"
    then {${resolution.id} = generatedFlavor;}
    else if resolution.kind == "official" || resolution.kind == "explicit"
    then
      lib.optionalAttrs (officialFlavors ? ${resolution.id}) {
        ${resolution.id} = officialFlavors.${resolution.id};
      }
    else {};

  # `programs.yazi.theme` for a resolution. `none` emits nothing; a theme-shaped
  # official/explicit selection replaces the base theme with the vendored file
  # (never a flavor); every other selection pins both background polarities to
  # the resolved flavor.
  themeSelection = {resolution}:
    if resolution.kind == "none"
    then {}
    else if officialThemes ? ${resolution.id}
    then lib.importTOML officialThemes.${resolution.id}
    else {
      flavor = {
        dark = resolution.id;
        light = resolution.id;
      };
    };
}
