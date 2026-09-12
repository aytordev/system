# Official Lazygit `gui` theme fragments vendored from the resource pinned by
# the matching provider integration. Structure and hex values are copied
# unmodified from the upstream YAML; only the top-level `gui:` wrapper is
# dropped (the fragment is merged under `programs.lazygit.settings.gui`). Do not
# hand-edit a value: re-vendor from the URL below at `source.ref.rev`.
#
# catppuccin/lazygit @ 798ad2e75a11766e9ba50e76e59aea6a81eb4866
#   provider: catppuccin, integration `lazygit` (port "lazygit")
#   https://raw.githubusercontent.com/catppuccin/lazygit/798ad2e75a11766e9ba50e76e59aea6a81eb4866/themes-mergable/<flavor>/mauve.yml
#   -> ids catppuccin-<flavor>-mauve
#
# Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439
#   provider: sora, integration `lazygit` (id "sora")
#   https://raw.githubusercontent.com/Aejkatappaja/sora/504df4913c55dd9ad658e331b172f86b0537b439/extras/lazygit/sora.yml
{
  catppuccin = {
    catppuccin-latte-mauve = {
      theme = {
        activeBorderColor = [
          "#8839ef"
          "bold"
        ];
        inactiveBorderColor = ["#6c6f85"];
        searchingActiveBorderColor = ["#df8e1d"];
        optionsTextColor = ["#1e66f5"];
        selectedLineBgColor = ["#ccd0da"];
        inactiveViewSelectedLineBgColor = ["#9ca0b0"];
        cherryPickedCommitFgColor = ["#8839ef"];
        cherryPickedCommitBgColor = ["#bcc0cc"];
        markedBaseCommitFgColor = ["#1e66f5"];
        markedBaseCommitBgColor = ["#df8e1d"];
        unstagedChangesColor = ["#d20f39"];
        defaultFgColor = ["#4c4f69"];
      };
      authorColors."*" = "#7287fd";
    };

    catppuccin-frappe-mauve = {
      theme = {
        activeBorderColor = [
          "#ca9ee6"
          "bold"
        ];
        inactiveBorderColor = ["#a5adce"];
        searchingActiveBorderColor = ["#e5c890"];
        optionsTextColor = ["#8caaee"];
        selectedLineBgColor = ["#414559"];
        inactiveViewSelectedLineBgColor = ["#737994"];
        cherryPickedCommitFgColor = ["#ca9ee6"];
        cherryPickedCommitBgColor = ["#51576d"];
        markedBaseCommitFgColor = ["#8caaee"];
        markedBaseCommitBgColor = ["#e5c890"];
        unstagedChangesColor = ["#e78284"];
        defaultFgColor = ["#c6d0f5"];
      };
      authorColors."*" = "#babbf1";
    };

    catppuccin-macchiato-mauve = {
      theme = {
        activeBorderColor = [
          "#c6a0f6"
          "bold"
        ];
        inactiveBorderColor = ["#a5adcb"];
        searchingActiveBorderColor = ["#eed49f"];
        optionsTextColor = ["#8aadf4"];
        selectedLineBgColor = ["#363a4f"];
        inactiveViewSelectedLineBgColor = ["#6e738d"];
        cherryPickedCommitFgColor = ["#c6a0f6"];
        cherryPickedCommitBgColor = ["#494d64"];
        markedBaseCommitFgColor = ["#8aadf4"];
        markedBaseCommitBgColor = ["#eed49f"];
        unstagedChangesColor = ["#ed8796"];
        defaultFgColor = ["#cad3f5"];
      };
      authorColors."*" = "#b7bdf8";
    };

    catppuccin-mocha-mauve = {
      theme = {
        activeBorderColor = [
          "#cba6f7"
          "bold"
        ];
        inactiveBorderColor = ["#a6adc8"];
        searchingActiveBorderColor = ["#f9e2af"];
        optionsTextColor = ["#89b4fa"];
        selectedLineBgColor = ["#313244"];
        inactiveViewSelectedLineBgColor = ["#6c7086"];
        cherryPickedCommitFgColor = ["#cba6f7"];
        cherryPickedCommitBgColor = ["#45475a"];
        markedBaseCommitFgColor = ["#89b4fa"];
        markedBaseCommitBgColor = ["#f9e2af"];
        unstagedChangesColor = ["#f38ba8"];
        defaultFgColor = ["#cdd6f4"];
      };
      authorColors."*" = "#b4befe";
    };
  };

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
