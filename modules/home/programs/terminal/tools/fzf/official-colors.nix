# Official FZF color maps vendored verbatim from the resource each provider
# integration pins. FZF has no theme file: upstream ships shell / readline
# fragments that export `FZF_DEFAULT_OPTS` with `--color=<name>:<hex>`
# specifiers. These maps transcribe exactly those specifiers; the integration
# carries the provenance and revision, this file only pins the color data so
# resolution never fetches at evaluation time. Do not hand-edit a value:
# re-vendor from the URL below at the integration's `source.ref.rev`.
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   provider: sora, integration `fzf` (id "sora", dark only)
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/fzf/sora.sh
{
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
