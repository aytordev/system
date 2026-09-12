# Official Starship module styles, keyed by palette id.
#
# A resource may ship module configuration in addition to its palette. Those
# entries are vendored here from the same upstream resource pinned in
# `official-palettes.nix`. They are deep-merged over the repository prompt when
# the resolver selects that resource (`config.nix:styleOverrides`), so the
# prompt keeps its own layout, glyphs and formats and only the color-bearing
# fields change. Colors reference the resource's own palette keys.
#
# Only resources that ship module styles appear here. Catppuccin themes are
# palette-only, so the base prompt already matches upstream; no entry needed.
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/starship/sora.toml
{
  sora = {
    directory.style = "cyan";
    git_branch.style = "purple";
    git_status.style = "rose";
    cmd_duration.style = "gold";
    time.style = "fg_dim";
    username = {
      style_user = "steel";
      style_root = "rose bold";
    };
    character = {
      vimcmd_symbol = "[N](bold purple)";
      vimcmd_replace_one_symbol = "[R](bold purple)";
      vimcmd_replace_symbol = "[R](bold purple)";
      vimcmd_visual_symbol = "[V](bold purple)";
    };
    nodejs.style = "sage";
    rust.style = "peach";
    python.style = "gold";
    golang.style = "cyan";
    lua.style = "purple";
    docker_context = {
      disabled = false;
      style = "teal";
    };
  };
}
