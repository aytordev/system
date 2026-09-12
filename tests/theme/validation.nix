{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeLib throws;

  validSource = {
    provenance = "official-upstream";
    ref = {
      url = "https://example.test/theme";
      rev = "0000000000000000000000000000000000000000";
    };
  };

  validIntegration = {
    source = validSource;
    complete = true;
    variants = {
      dark = {
        id = "broken-dark";
      };
      light = {
        id = "broken-light";
        variantProvenance = "synthetic";
      };
    };
  };

  baseProvider = integrations: {
    name = "broken";
    displayName = "Broken";
    defaultVariant = "dark";
    darkVariant = "dark";
    lightVariant = "light";
    variants = {
      dark = {
        isLight = false;
      };
      light = {
        isLight = true;
      };
    };
    appTheme = _: {};
    inherit integrations;
  };

  withIntegration = integration: baseProvider {ghostty = integration;};

  providerWith = baseProvider;
in {
  # ─── Existing contract tests ──────────────────────────────────────────────

  testValidateProviderRejectsNonListNativeApps = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider {
          name = "broken";
          displayName = "Broken";
          defaultVariant = "dark";
          darkVariant = "dark";
          lightVariant = "light";
          variants = {
            dark = {
              isLight = false;
            };
            light = {
              isLight = true;
            };
          };
          appTheme = _: {};
          nativeApps = "ghostty";
        })
        true
      )).success;
    expected = false;
  };

  testValidateProviderAcceptsKanagawa = {
    expr =
      (themeLib.validateProvider (
        import ../../modules/home/theme/kanagawa/provider.nix {
          inherit (themeLib) mkColor transparent capitalize;
        }
      )).name;
    expected = "kanagawa";
  };

  testValidateProviderRejectsMissingContract = {
    expr =
      (builtins.tryEval (builtins.deepSeq (themeLib.validateProvider {name = "broken";}) true)).success;
    expected = false;
  };

  testValidateProviderRejectsUnknownVariantReference = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider {
          name = "broken";
          displayName = "Broken";
          defaultVariant = "missing";
          darkVariant = "missing";
          lightVariant = "missing";
          variants = {};
          appTheme = _: {};
        })
        true
      )).success;
    expected = false;
  };

  testValidateProviderRejectsInconsistentPolarity = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider {
          name = "broken";
          displayName = "Broken";
          defaultVariant = "dark";
          darkVariant = "dark";
          lightVariant = "light";
          variants = {
            dark = {
              isLight = true;
            };
            light = {
              isLight = true;
            };
          };
          appTheme = _: {};
        })
        true
      )).success;
    expected = false;
  };

  # ─── Integration acceptance and projection ────────────────────────────────

  testValidateProviderAcceptsIntegration = {
    expr = let
      provider = themeLib.validateProvider (withIntegration validIntegration);
    in {
      inherit (provider) nativeApps;
      inherit (provider) name;
    };
    expected = {
      nativeApps = ["ghostty"];
      name = "broken";
    };
  };

  testValidateProviderProjectsNativeAppsFromIntegrations = {
    expr =
      (themeLib.validateProvider (baseProvider {
        ghostty = validIntegration;
        zed = validIntegration;
      })).nativeApps;
    expected = [
      "ghostty"
      "zed"
    ];
  };

  testValidateProviderAcceptsNativeAppsSameSetDifferentOrder = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider (
          baseProvider {
            ghostty = validIntegration;
            zed = validIntegration;
          }
          // {
            nativeApps = [
              "zed"
              "ghostty"
            ];
          }
        ))
        true
      )).success;
    expected = true;
  };

  # ─── Integration validation, one independent fault per test ───────────────

  testValidateProviderRejectsIntegrationsNotAttrset = {
    expr = throws (themeLib.validateProvider (providerWith "not-an-attrset"));
    expected = true;
  };

  testValidateProviderRejectsIntegrationWithoutSource = {
    expr = throws (
      themeLib.validateProvider (withIntegration {
        complete = true;
        variants = {
          dark = {
            id = "broken-dark";
          };
          light = {
            id = "broken-light";
          };
        };
      })
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationInvalidProvenance = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                provenance = "bogus";
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationNonStringRefUrl = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                ref =
                  validSource.ref
                  // {
                    url = 1;
                  };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationMissingRev = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                ref = {
                  url = "https://example.test/theme";
                };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationNonStringHash = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                ref =
                  validSource.ref
                  // {
                    hash = 1;
                  };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsCommunityPortWithoutHash = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source = {
              provenance = "community-port";
              inherit (validSource) ref;
            };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderAcceptsCommunityPortWithHash = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider (
          withIntegration (
            validIntegration
            // {
              source = {
                provenance = "community-port";
                ref =
                  validSource.ref
                  // {
                    hash = "sha256-AAAA";
                  };
              };
            }
          )
        ))
        true
      )).success;
    expected = true;
  };

  testValidateProviderRejectsIntegrationUnknownVariant = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants =
              validIntegration.variants
              // {
                bogus = {
                  id = "broken-bogus";
                };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationMissingVariantId = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants =
              validIntegration.variants
              // {
                dark = {};
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationEmptyVariantId = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants =
              validIntegration.variants
              // {
                dark = {
                  id = "";
                };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationNonStringVariantId = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants =
              validIntegration.variants
              // {
                dark = {
                  id = 1;
                };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIntegrationInvalidVariantProvenance = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants =
              validIntegration.variants
              // {
                dark = {
                  id = "broken-dark";
                  variantProvenance = "bogus";
                };
              };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsIncompleteIntegration = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            variants = {
              dark = {
                id = "broken-dark";
              };
            };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderAllowsIncompleteWhenNotComplete = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider (
          withIntegration (
            validIntegration
            // {
              complete = false;
              variants = {
                dark = {
                  id = "broken-dark";
                };
              };
            }
          )
        ))
        true
      )).success;
    expected = true;
  };

  testValidateProviderRejectsNativeAppsDesync = {
    expr = throws (
      themeLib.validateProvider (
        baseProvider {
          ghostty = validIntegration;
          zed = validIntegration;
        }
        // {
          nativeApps = ["ghostty"];
        }
      )
    );
    expected = true;
  };
}
