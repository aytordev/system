# Catppuccin integration registry: presence, provenance, pins, coverage, ids.
{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig themeLib throws;

  theme = themeConfig {aytordev.theme.name = "catppuccin";};
  integrations = theme.providers.catppuccin.integrations;
  allFlavors = builtins.attrNames theme.providers.catppuccin.variants;

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
    "tmux"
    "vscode"
    "warp"
    "yazi"
    "zed"
    "zellij"
  ];

  # Every declared app resolves an official `catppuccin/*` resource.
  provenance = {
    bat = "official-upstream";
    btop = "official-upstream";
    eza = "official-upstream";
    firefox = "official-upstream";
    fzf = "official-upstream";
    ghostty = "official-upstream";
    lazygit = "official-upstream";
    opencode = "official-upstream";
    starship = "official-upstream";
    tmux = "official-upstream";
    vscode = "official-upstream";
    warp = "official-upstream";
    yazi = "official-upstream";
    zed = "official-upstream";
    zellij = "official-upstream";
  };

  # Catppuccin's default variant is `mocha`; accent-taking ports pin `mauve`.
  defaultIds = {
    bat = "Catppuccin Mocha";
    btop = "catppuccin_mocha";
    eza = "catppuccin-mocha-mauve";
    firefox = "Catppuccin mocha mauve";
    fzf = "catppuccin-fzf-mocha";
    ghostty = "catppuccin-mocha";
    lazygit = "catppuccin-mocha-mauve";
    opencode = "catppuccin-mocha-mauve";
    starship = "catppuccin_mocha";
    tmux = "mocha";
    vscode = "Catppuccin Mocha";
    warp = "catppuccin_mocha";
    yazi = "catppuccin-mocha-mauve";
    zed = "Catppuccin Mocha";
    zellij = "catppuccin-mocha";
  };

  provider = import ../../modules/home/theme/catppuccin/provider.nix {
    inherit (themeLib) mkColor transparent capitalize;
  };
in {
  testCatppuccinDeclaresEveryOfficialApp = {
    expr = builtins.attrNames integrations;
    expected = expectedApps;
  };

  testCatppuccinEveryIntegrationIsPinnedAndCoversEveryFlavor = {
    expr =
      map (
        app: let
          integration = integrations.${app};
        in {
          hasUrl = (integration.source.ref.url or "") != "";
          hasRev = (integration.source.ref.rev or "") != "";
          inherit (integration) complete;
          variants = builtins.attrNames integration.variants;
        }
      )
      expectedApps;
    expected = builtins.genList (_: {
      hasUrl = true;
      hasRev = true;
      complete = true;
      variants = allFlavors;
    }) (builtins.length expectedApps);
  };

  testCatppuccinProvenance = {
    expr = lib.genAttrs expectedApps (app: integrations.${app}.source.provenance);
    expected = provenance;
  };

  testCatppuccinDefaultVariantIds = {
    expr = lib.genAttrs expectedApps (app: integrations.${app}.variants.${theme.variant}.id);
    expected = defaultIds;
  };

  # A complete integration that drops a flavor must be rejected.
  testCatppuccinRejectsCompleteIntegrationMissingAFlavor = {
    expr = throws (
      themeLib.validateProvider (
        provider
        // {
          integrations =
            provider.integrations
            // {
              starship =
                provider.integrations.starship
                // {
                  variants = builtins.removeAttrs provider.integrations.starship.variants ["latte"];
                };
            };
        }
      )
    );
    expected = true;
  };
}
