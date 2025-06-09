# Format checking using alejandra
# Verifies that all Nix files in the repository are properly formatted
# according to the project's style guidelines.
#
# This check ensures consistent code style by running alejandra on all Nix files.
# It's automatically included in the flake's checks when running `nix flake check`.
#
# To fix formatting issues, run `nix fmt` from the repository root.
{
  # Standard flake inputs
  pkgs,
  self,
  lib ? pkgs.lib,
  ...
} @ args: let
  # Get the alejandra formatter
  alejandra = self.formatter.${pkgs.system};

  # Directories to check for Nix files
  # These paths are relative to the flake root
  directories = [
    "." # Root directory
    "./checks" # Check definitions
    "./dev-shells" # Development shells
    "./outputs" # Output definitions
  ];

  # Find all Nix files in the specified directories
  filesToCheck = lib.lists.flatten (map (
      dir:
        if builtins.pathExists (self + "/${dir}")
        then let
          allFiles = lib.filesystem.listFilesRecursive (self + "/${dir}");
        in
          builtins.filter (f: lib.strings.hasSuffix ".nix" f) allFiles
        else []
    )
    directories);

  # Create a shell script to run the checks
  checkScript = pkgs.writeShellScript "check-format" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ANSI color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    # Initialize counters
    checked=0
    failed=0

    # Function to print error
    error() {
      echo -e "''${RED}Error:''${NC} $1"
    }

    # Main execution
    echo "Checking Nix file formatting..."

    # Check each file
    for file in ${toString filesToCheck}; do
      rel_path="''${file#$PWD/}"
      echo "Checking $rel_path"

      if ! ${alejandra}/bin/alejandra --check "$file"; then
        error "File requires formatting: $rel_path"
        echo "  Run: nix fmt"
        failed=$((failed + 1))
      fi

      checked=$((checked + 1))
    done

    # Summary
    echo -e "\n=== Format Check Summary ==="
    echo -e "''${GREEN}✓ Checked: $checked files''${NC}"

    if [ $failed -gt 0 ]; then
      echo -e "''${RED}✗ Failed: $failed files need formatting''${NC}"
      echo -e "\nTo fix formatting issues, run: nix fmt"
      exit 1
    else
      echo -e "''${GREEN}✓ All files are properly formatted!''${NC}"
      touch $out
    fi
  '';
in
  pkgs.runCommand "check-format" {
    buildInputs = [alejandra];
    meta = {
      description = "Check Nix code formatting with alejandra";
      longDescription = ''
        This check ensures that all Nix files in the repository are properly
        formatted according to the alejandra formatter's style.
      '';
    };
  } ''
    # Run the check script
    ${checkScript}
  ''
