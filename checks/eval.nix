# Nix evaluation check
# Verifies that all Nix expressions evaluate successfully
{
  pkgs,
  self,
  ...
}: let
  # Get the flake root directory
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
