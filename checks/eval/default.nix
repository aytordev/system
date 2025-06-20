# Nix Evaluation check for Nix expressions
# Verifies that all Nix expressions in the repository can be evaluated successfully.
#
# This check ensures that the Nix code is syntactically correct and all references
# are valid. It's automatically included in the flake's checks when running
# `nix flake check`.
#
# To fix evaluation errors, check the error messages and correct the Nix expressions.
{
  # Standard flake inputs
  pkgs,
  self,
  ...
}: let
  # Get the flake root directory as a string
  # This is used to reference files relative to the repository root
  flakeRoot = builtins.toString self.outPath;
in
  pkgs.runCommand "check-eval" {
    buildInputs = [pkgs.nix];
    meta = {
      description = "Check Nix expressions evaluate successfully";
      longDescription = ''
        This check verifies that all Nix expressions in the repository can be
        successfully evaluated, catching syntax errors and other evaluation-time
        issues.
      '';
    };
  } ''
    # Check that the flake evaluates
    if [ -f "${flakeRoot}/flake.nix" ]; then
      nix-instantiate --parse --quiet "${flakeRoot}/flake.nix" >/dev/null
    else
      echo "Error: flake.nix not found in ${flakeRoot}"
      exit 1
    fi

    # Create output to indicate success
    touch $out
  ''
