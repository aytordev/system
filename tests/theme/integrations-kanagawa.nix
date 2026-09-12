# Kanagawa integration registry: presence, provenance, pins, coverage and ids.
{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig;

  theme = themeConfig {aytordev.theme.name = "kanagawa";};
  integrations = theme.providers.kanagawa.integrations;

  expectedApps = [
    "bat"
    "ghostty"
    "tmux"
    "vscode"
    "zed"
  ];

  inherit (integrations) bat;
in {
  testKanagawaDeclaresEveryOfficialApp = {
    expr = builtins.attrNames integrations;
    expected = expectedApps;
  };

  testKanagawaBatIsOfficialWaveOnly = {
    expr = {
      inherit (bat.source) provenance;
      url = bat.source.ref.url;
      rev = bat.source.ref.rev;
      inherit (bat) complete;
      variants = builtins.attrNames bat.variants;
      waveId = bat.variants.wave.id;
    };
    expected = {
      provenance = "official-upstream";
      url = "https://github.com/rebelot/kanagawa.nvim";
      rev = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3";
      complete = false;
      variants = ["wave"];
      waveId = "Kanagawa";
    };
  };

  # Every other declared app pins a concrete upstream revision.
  testKanagawaNonBatIntegrationsArePinned = {
    expr = map (
      app: let
        integration = integrations.${app};
      in {
        hasUrl = (integration.source.ref.url or "") != "";
        hasRev = (integration.source.ref.rev or "") != "";
        hasProvenance =
          integration.source ? provenance
          && builtins.elem integration.source.provenance [
            "official-upstream"
            "community-port"
          ];
      }
    ) (builtins.filter (app: app != "bat") expectedApps);
    expected = builtins.genList (_: {
      hasUrl = true;
      hasRev = true;
      hasProvenance = true;
    }) (builtins.length expectedApps - 1);
  };
}
