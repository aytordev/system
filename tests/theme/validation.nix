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
    inherit integrations;
  };

  withIntegration = integration: baseProvider {ghostty = integration;};

  providerWith = baseProvider;
in {
  # ─── Existing contract tests ──────────────────────────────────────────────

  testValidateProviderAcceptsKanagawa = {
    expr =
      (themeLib.validateProvider (
        import ../../modules/home/theme/kanagawa/provider.nix {
          inherit (themeLib) mkColor transparent;
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
        })
        true
      )).success;
    expected = false;
  };

  # ─── Integration acceptance ───────────────────────────────────────────────

  testValidateProviderAcceptsIntegration = {
    expr = let
      provider = themeLib.validateProvider (withIntegration validIntegration);
    in
      provider.name;
    expected = "broken";
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

  # A non-vendored community port pins a rev; a content hash is not applicable
  # (the consumer fetches the artifact through its own package manager).
  testValidateProviderAllowsCommunityPortWithoutHash = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider (
          withIntegration (
            validIntegration
            // {
              source = {
                provenance = "community-port";
                inherit (validSource) ref;
              };
            }
          )
        ))
        true
      )).success;
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

  # ─── Vendored resources must pin every artifact with an SRI hash ──────────

  testValidateProviderAcceptsVendoredIntegrationWithHashes = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (themeLib.validateProvider (
          withIntegration (
            validIntegration
            // {
              source =
                validSource
                // {
                  vendored = true;
                  ref =
                    validSource.ref
                    // {
                      hash = "sha256-SRC";
                    };
                };
              variants = {
                dark = {
                  id = "broken-dark";
                  hash = "sha256-AAAA";
                };
                light = {
                  id = "broken-light";
                  hash = "sha256-BBBB";
                };
              };
            }
          )
        ))
        true
      )).success;
    expected = true;
  };

  testValidateProviderAcceptsVendoredIntegrationWithoutVariantHash = {
    expr =
      !(throws (
        themeLib.validateProvider (
          withIntegration (
            validIntegration
            // {
              source =
                validSource
                // {
                  vendored = true;
                  ref =
                    validSource.ref
                    // {
                      hash = "sha256-SRC";
                    };
                };
              variants = {
                dark = {
                  id = "broken-dark";
                  hash = "sha256-AAAA";
                };
                light = {
                  id = "broken-light";
                };
              };
            }
          )
        )
      ));
    expected = true;
  };

  testValidateProviderRejectsVendoredIntegrationWithoutSourceHash = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                vendored = true;
              };
            variants = {
              dark = {
                id = "broken-dark";
                hash = "sha256-AAAA";
              };
              light = {
                id = "broken-light";
                hash = "sha256-BBBB";
              };
            };
          }
        )
      )
    );
    expected = true;
  };

  testValidateProviderRejectsNonBooleanVendored = {
    expr = throws (
      themeLib.validateProvider (
        withIntegration (
          validIntegration
          // {
            source =
              validSource
              // {
                vendored = "yes";
              };
          }
        )
      )
    );
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
}
