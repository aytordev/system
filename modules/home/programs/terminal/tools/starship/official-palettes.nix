# Official Starship `[palettes.<name>]` blocks.
#
# Each block is copied unmodified from the resource pinned by the matching
# provider integration (`modules/home/theme/<family>/provider.nix`); the
# integration carries the provenance and revision, this file only pins the
# color data so resolution never fetches at evaluation time. Do not hand-edit
# a value: re-vendor from the URL below at the integration's `source.ref.rev`.
#
# Some resources also ship module styles; those are vendored separately in
# `official-styles.nix` and applied over the repository prompt when the resource
# is resolved (currently only Sora).
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   provider: sora, integration `starship` (id "sora")
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/starship/sora.toml
{
  # Sora ships both a palette and module styles; the palette is vendored here
  # verbatim and the module styles live in `official-styles.nix`.
  sora = {
    sora = {
      bg = "#0e1018";
      fg = "#c8d0e0";
      fg_dim = "#9aa4b8";
      cyan = "#80c8e0";
      purple = "#b0a0d8";
      sage = "#90c8a0";
      rose = "#d0909c";
      gold = "#d4b878";
      peach = "#d0a888";
      teal = "#78b8b0";
      steel = "#8898b8";
      git_add = "#68b080";
      git_change = "#6898b8";
      git_delete = "#b86068";
      error = "#c46c78";
      warning = "#c8a860";
    };
  };
}
