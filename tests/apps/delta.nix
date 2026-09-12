{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig;

  delta = import ../../modules/home/programs/terminal/tools/git/delta-theme.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    delta.resolve {
      inherit variant override;
      integration = integrations.${family}.delta or null;
    };

  optionsFor = family: variant: override:
    delta.optionsFor {
      resolution = resolveFor family variant override;
      palette = theme.providers.${family}.variants.${variant};
    };

  kanagawaDragon = theme.providers.kanagawa.variants.dragon;
in {
  # ─── Resolution ───────────────────────────────────────────────────────────

  testDeltaSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testDeltaSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testDeltaKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  # ─── Official Sora styles ─────────────────────────────────────────────────

  testDeltaSoraDarkUsesOfficialStyles = {
    expr = let
      options = optionsFor "sora" "dark" null;
    in {
      minus = options.minus-style;
      plus = options.plus-style;
      plusEmph = options.plus-emph-style;
      commit = options.commit-style;
      blame = options.blame-palette;
    };
    expected = {
      minus = "syntax #1c1014";
      plus = "syntax #0e1c16";
      plusEmph = "syntax bold #142c1c";
      commit = "#d4b878 bold";
      blame = "#0e1018 #14161e #171a24 #1e2430";
    };
  };

  # ─── Generated fallback ───────────────────────────────────────────────────

  testDeltaGeneratedPlusStyleUsesBlendedGreen = {
    expr = (optionsFor "kanagawa" "dragon" null).plus-style;
    expected = "syntax ${delta.blend kanagawaDragon.bg.hex kanagawaDragon.green.hex 0.12}";
  };

  testDeltaGeneratedMinusStyleUsesBlendedRed = {
    expr = (optionsFor "kanagawa" "dragon" null).minus-emph-style;
    expected = "syntax bold ${delta.blend kanagawaDragon.bg.hex kanagawaDragon.red.hex 0.22}";
  };

  testDeltaBlendIsDeterministic = {
    expr = delta.blend "#000000" "#ffffff" 0.5;
    expected = "#808080";
  };

  # ─── Opt out ──────────────────────────────────────────────────────────────

  testDeltaNoneEmitsNothing = {
    expr = optionsFor "kanagawa" "dragon" {mode = "none";};
    expected = {};
  };
}
