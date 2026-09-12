# Sora integration registry: presence, provenance, pins, coverage and ids.
{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig themeLib throws;

  theme = themeConfig {aytordev.theme.name = "sora";};
  integrations = theme.providers.sora.integrations;

  expectedApps = [
    "bat"
    "btop"
    "eza"
    "firefox"
    "fzf"
    "ghostty"
    "lazygit"
    "opencode"
    "starship"
    "yazi"
    "zed"
  ];

  # Sora's default variant is `dark`; every official resource is dark-only.
  defaultIds = {
    bat = "Sora";
    btop = "sora";
    eza = "sora";
    firefox = "Sora";
    fzf = "sora";
    ghostty = "sora";
    lazygit = "sora";
    opencode = "sora";
    starship = "sora";
    yazi = "sora";
    zed = "Sora";
  };

  provider = import ../../modules/home/theme/sora/provider.nix {
    inherit (themeLib) mkColor transparent;
  };
in {
  testSoraDeclaresEveryOfficialApp = {
    expr = builtins.attrNames integrations;
    expected = expectedApps;
  };

  testSoraEveryIntegrationIsPinnedOfficialAndDarkOnly = {
    expr =
      map (
        app: let
          integration = integrations.${app};
        in {
          provenance = integration.source.provenance;
          hasUrl = (integration.source.ref.url or "") != "";
          hasRev = (integration.source.ref.rev or "") != "";
          inherit (integration) complete;
          variants = builtins.attrNames integration.variants;
        }
      )
      expectedApps;
    expected = builtins.genList (_: {
      provenance = "official-upstream";
      hasUrl = true;
      hasRev = true;
      complete = false;
      variants = ["dark"];
    }) (builtins.length expectedApps);
  };

  testSoraDefaultVariantIds = {
    expr = lib.genAttrs expectedApps (app: integrations.${app}.variants.${theme.variant}.id);
    expected = defaultIds;
  };

  # Regression: the Zed `sora-theme` rev previously carried a typo and did not
  # resolve to any upstream commit.
  testSoraZedPinsTheCorrectUpstreamCommit = {
    expr = integrations.zed.source.ref.rev;
    expected = "823a786dfea9f2b04e729cdd9ad7f33ecee621c7";
  };

  # A dark-only catalog entry must not claim to cover every provider variant.
  testSoraRejectsIncompleteIntegrationClaimingComplete = {
    expr = throws (
      themeLib.validateProvider (
        provider
        // {
          integrations =
            provider.integrations
            // {
              bat =
                provider.integrations.bat
                // {
                  complete = true;
                };
            };
        }
      )
    );
    expected = true;
  };
}
