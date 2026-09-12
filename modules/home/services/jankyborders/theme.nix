# JankyBorders theme adapter.
#
# JankyBorders ships no upstream theme resource for any family, so it never
# appears in a provider's `integrations`. It is therefore always
# palette-generated: the border colors come from the shared semantic palette,
# and `resolveApp` runs with `official = null` so the resolver reports a
# generated selection and stays consistent with the other hybrid consumers.
#
# Active (focused) window: the family `accent` role. Inactive (unfocused)
# window: the neutral `border` role. These are distinct semantic roles in every
# family; pairing two shades of a single hue (for example `yellow` vs
# `yellow_bright`) risks collapsing to the same color in some variant.
{resolveApp}: rec {
  # Provenance marker for `resolveApp`. JankyBorders consumes raw colors rather
  # than a named theme, so no resource file is generated from this id.
  generatedId = "palette";

  activeRole = "accent";
  inactiveRole = "border";

  resolve = {
    variant,
    override ? null,
  }:
    resolveApp {
      app = "jankyborders";
      inherit variant override;
      official = null;
      generated = generatedId;
    };

  colors = {palette}: {
    active_color = palette.${activeRole}.sketchybar;
    inactive_color = palette.${inactiveRole}.sketchybar;
  };
}
