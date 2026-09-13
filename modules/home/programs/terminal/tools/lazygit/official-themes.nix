# Official Lazygit `gui` theme fragments vendored from the resource pinned by
# the matching provider integration. Structure and hex values are copied
# unmodified from the upstream YAML; only the top-level `gui:` wrapper is
# dropped (the fragment is merged under `programs.lazygit.settings.gui`). Do not
# hand-edit a value: re-vendor from the URL below at `source.ref.rev`.
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   provider: sora, integration `lazygit` (id "sora")
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/lazygit/sora.yml
{
  sora = {
    sora = {
      theme = {
        activeBorderColor = [
          "#80c8e0"
          "bold"
        ];
        inactiveBorderColor = ["#586478"];
        searchingActiveBorderColor = [
          "#d4b878"
          "bold"
        ];
        optionsTextColor = ["#80c8e0"];
        selectedLineBgColor = ["#283448"];
        inactiveViewSelectedLineBgColor = ["#1e2430"];
        cherryPickedCommitFgColor = ["#80c8e0"];
        cherryPickedCommitBgColor = ["#b0a0d8"];
        markedBaseCommitFgColor = ["#80c8e0"];
        markedBaseCommitBgColor = ["#d4b878"];
        unstagedChangesColor = ["#c46c78"];
        defaultFgColor = ["#c8d0e0"];
      };
    };
  };
}
