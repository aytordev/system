{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) resolveApp throws;

  integration = {
    source = {
      provenance = "official-upstream";
      ref = {
        url = "https://example.test/theme";
        rev = "0000000000000000000000000000000000000000";
      };
    };
    complete = true;
    variants = {
      dark = {
        id = "official-dark";
      };
      light = {
        id = "official-light";
        variantProvenance = "synthetic";
      };
    };
  };
in {
  # ─── Precedence branches ──────────────────────────────────────────────────

  testResolveAppExplicitOverrideWins = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "manual";
        id = "user-theme";
      };
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "explicit";
      id = "user-theme";
      source = "user";
    };
  };

  testResolveAppBareStringOverrideIsManual = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      override = "user-theme";
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "explicit";
      id = "user-theme";
      source = "user";
    };
  };

  testResolveAppAutoOverrideUsesOfficial = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "auto";
      };
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "official";
      id = "official-dark";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testResolveAppNullOverrideIsAuto = {
    expr = resolveApp {
      app = "ghostty";
      variant = "light";
      override = null;
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "official";
      id = "official-light";
      provenance = "official-upstream";
      variantProvenance = "synthetic";
      source = "official";
    };
  };

  testResolveAppOfficialBeatsGenerated = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "official";
      id = "official-dark";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  testResolveAppGeneratedFallback = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      official = null;
      generated = "generated-theme";
    };
    expected = {
      kind = "generated";
      id = "generated-theme";
      source = "generated";
    };
  };

  testResolveAppNoneWhenNothing = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      official = null;
      generated = null;
    };
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  testResolveAppNoneOverrideOptsOut = {
    expr = resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "none";
      };
      official = integration;
      generated = "generated-theme";
    };
    expected = {
      kind = "none";
      id = null;
      source = "none";
    };
  };

  # ─── Broken declarations and invalid overrides are hard errors ────────────

  testResolveAppDeclaredButMissingVariantThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "missing";
      official = integration;
      generated = "generated-theme";
    });
    expected = true;
  };

  testResolveAppDeclaredVariantWithoutIdThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      official =
        integration
        // {
          variants =
            integration.variants
            // {
              dark = {};
            };
        };
      generated = "generated-theme";
    });
    expected = true;
  };

  testResolveAppDeclaredWithoutSourceThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      official =
        integration
        // {
          source = null;
        };
    });
    expected = true;
  };

  testResolveAppManualNullIdThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "manual";
      };
    });
    expected = true;
  };

  testResolveAppManualEmptyIdThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "manual";
        id = "";
      };
    });
    expected = true;
  };

  testResolveAppManualNonStringIdThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "manual";
        id = 1;
      };
    });
    expected = true;
  };

  testResolveAppUnknownModeThrows = {
    expr = throws (resolveApp {
      app = "ghostty";
      variant = "dark";
      override = {
        mode = "bogus";
      };
    });
    expected = true;
  };

  # ─── Control: the eval-forcing helper really forces nested errors ─────────

  testEvalForceHelperForcesNestedErrors = {
    expr = {
      nested = throws {deep = throw "boom";};
      whnfOnly = (builtins.tryEval {deep = throw "boom";}).success;
    };
    expected = {
      nested = true;
      whnfOnly = true;
    };
  };
}
