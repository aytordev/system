# Pi theme adapter.
#
# Pi has no upstream official theme resource for any family, so `official` is
# always null and the effective path is the palette-generated theme. Routing
# through `resolveApp` anyway keeps the override contract (`auto` / `manual` /
# `none`) identical to apps that do ship a native resource, and leaves room for
# a future integration without changing callers. A malformed declared
# integration still reaches `resolveApp` and throws, keeping it loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable theme name/id for the generated JSON, and the basename of the file
  # deployed under `<agent-dir>/themes/`. Must not collide with a vendored theme.
  generatedId = "aytordev";

  # Render the Pi theme schema from a palette (and the variant's ANSI table when
  # available). `ansi` is optional so palette-only callers keep working.
  render = {
    palette,
    ansi ? null,
  }:
    import ./theme.nix {inherit palette ansi;};

  # Hybrid resolution: explicit override > official exact > generated fallback.
  # Pi integrations are absent today, so `official` is null in practice; the
  # `generated` fallback is nulled by callers when the generated file is not
  # deployed (shell disabled), which yields an explicit `none`.
  resolve = {
    variant,
    override ? null,
    integration ? null,
    generated ? generatedId,
  }:
    resolveApp {
      app = "pi";
      inherit variant override generated;
      official = integration;
    };

  # settings.json entry for a resolution. `none` must not write a theme
  # selection, so it emits an empty attrset.
  themeEntry = resolution:
    lib.optionalAttrs (resolution.kind != "none") {
      theme = resolution.id;
    };
}
