# Official FZF color maps vendored verbatim from the resource each provider
# integration pins. FZF has no theme file: upstream ships shell / readline
# fragments that export `FZF_DEFAULT_OPTS` with `--color=<name>:<hex>`
# specifiers. These maps transcribe exactly those specifiers; the integration
# carries the provenance and revision, this file only pins the color data so
# resolution never fetches at evaluation time. Do not hand-edit a value:
# re-vendor from the URL below at the integration's `source.ref.rev`.
#
# catppuccin/fzf @ 7508f8141286fb95249100a2b5325960320dcf32
#   provider: catppuccin, integration `fzf` (ids "catppuccin-fzf-<flavor>")
#   https://raw.githubusercontent.com/catppuccin/fzf/7508f8141286fb95249100a2b5325960320dcf32/themes/catppuccin-fzf-<flavor>.rc
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   provider: sora, integration `fzf` (id "sora", dark only)
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/fzf/sora.sh
{
  catppuccin-fzf-latte = {
    "bg+" = "#CCD0DA";
    bg = "#EFF1F5";
    spinner = "#DC8A78";
    hl = "#D20F39";
    fg = "#4C4F69";
    header = "#D20F39";
    info = "#8839EF";
    pointer = "#DC8A78";
    marker = "#7287FD";
    "fg+" = "#4C4F69";
    prompt = "#8839EF";
    "hl+" = "#D20F39";
    "selected-bg" = "#BCC0CC";
    border = "#9CA0B0";
    label = "#4C4F69";
  };
  catppuccin-fzf-frappe = {
    "bg+" = "#414559";
    bg = "#303446";
    spinner = "#F2D5CF";
    hl = "#E78284";
    fg = "#C6D0F5";
    header = "#E78284";
    info = "#CA9EE6";
    pointer = "#F2D5CF";
    marker = "#BABBF1";
    "fg+" = "#C6D0F5";
    prompt = "#CA9EE6";
    "hl+" = "#E78284";
    "selected-bg" = "#51576D";
    border = "#737994";
    label = "#C6D0F5";
  };
  catppuccin-fzf-macchiato = {
    "bg+" = "#363A4F";
    bg = "#24273A";
    spinner = "#F4DBD6";
    hl = "#ED8796";
    fg = "#CAD3F5";
    header = "#ED8796";
    info = "#C6A0F6";
    pointer = "#F4DBD6";
    marker = "#B7BDF8";
    "fg+" = "#CAD3F5";
    prompt = "#C6A0F6";
    "hl+" = "#ED8796";
    "selected-bg" = "#494D64";
    border = "#6E738D";
    label = "#CAD3F5";
  };
  catppuccin-fzf-mocha = {
    "bg+" = "#313244";
    bg = "#1E1E2E";
    spinner = "#F5E0DC";
    hl = "#F38BA8";
    fg = "#CDD6F4";
    header = "#F38BA8";
    info = "#CBA6F7";
    pointer = "#F5E0DC";
    marker = "#B4BEFE";
    "fg+" = "#CDD6F4";
    prompt = "#CBA6F7";
    "hl+" = "#F38BA8";
    "selected-bg" = "#45475A";
    border = "#6C7086";
    label = "#CDD6F4";
  };
  sora = {
    "bg+" = "#1e2430";
    bg = "#0e1018";
    border = "#364050";
    fg = "#c8d0e0";
    "fg+" = "#dce4f0";
    gutter = "#0e1018";
    header = "#80c8e0";
    hl = "#80c8e0";
    "hl+" = "#98d8f0";
    info = "#586478";
    marker = "#90c8a0";
    pointer = "#80c8e0";
    prompt = "#b0a0d8";
    query = "#c8d0e0";
    scrollbar = "#364050";
    separator = "#364050";
    spinner = "#80c8e0";
  };
}
