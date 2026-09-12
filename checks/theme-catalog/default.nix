# Theme support catalog: derives the family × app matrix from the provider
# registry and the consuming-adapter inventory, then fails if the committed
# `docs/theme-support-matrix.md` drifts from the generator.
#
# Mirrors the golden-file diff pattern of `checks/docs-generation`. The matrix is
# available as `passthru.matrix` so it can be regenerated without running the
# drift check (see `regenerate.sh`).
{pkgs, ...}: let
  inherit (pkgs) lib;

  # Evaluate the pure-data theme module standalone, exactly like the theme unit
  # tests do, so the catalog sees the live registry rather than a hand-copied
  # snapshot.
  theme =
    (lib.evalModules {
      modules = [
        ../../modules/home/theme
        {
          options.assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [];
          };
        }
      ];
    }).config.aytordev.theme;

  generate = import ./generate.nix {inherit lib theme;};

  generated = pkgs.writeText "theme-support-matrix.md" generate.markdown;
  committed = ../../docs/theme-support-matrix.md;
in
  pkgs.runCommand "theme-catalog-check"
  {
    passthru.matrix = generated;
    nativeBuildInputs = [pkgs.diffutils];
  }
  ''
    set -euo pipefail
    if ! diff -u ${committed} ${generated} > "$TMPDIR/theme-catalog.diff"; then
      echo "ERROR: docs/theme-support-matrix.md is stale; regenerate it with 'bash checks/theme-catalog/regenerate.sh'." >&2
      cat "$TMPDIR/theme-catalog.diff" >&2
      exit 1
    fi
    touch "$out"
  ''
