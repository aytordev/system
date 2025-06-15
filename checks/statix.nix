# Statix Nix linter check
# Verifies that Nix code follows best practices and catches common mistakes.
#
# This check runs statix to identify potential issues in Nix expressions.
# It's automatically included in the flake's checks when running `nix flake check`.
#
# To fix issues, run `nix run github:nerdypepper/statix#statix -- check .`
# and follow the suggestions.
{
  # Standard flake inputs
  pkgs,
  ...
}: let
  # Get the statix package
  statix = pkgs.statix;

  # We'll check the current directory recursively
  checkPath = ".";

  # Create a shell script to run the checks
  checkScript = pkgs.writeShellScript "check-statix" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ANSI color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    # Initialize counters
    checked=0
    failed=0

    echo "Running statix checks..."

    # Run statix check on the current directory
    if ! ${statix}/bin/statix check ${checkPath}; then
      echo -e "\n''${RED}✗ Statix found issues in one or more files''${NC}"
      echo -e "To fix issues, run: nix run github:nerdypepper/statix#statix -- fix ."
      exit 1
    else
      echo -e "''${GREEN}✓ No statix issues found''${NC}"
      touch $out
    fi
  '';
in
  pkgs.runCommand "check-statix" {
    buildInputs = [statix];
    meta = {
      description = "Check Nix code with statix linter";
      longDescription = ''
        This check uses statix to identify potential issues in Nix expressions,
        following Nix best practices and catching common mistakes.
        It checks all .nix files in the repository recursively.
      '';
    };
  } ''
    # Run the check script
    ${checkScript}
  ''
