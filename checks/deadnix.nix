# Deadnix check for unused Nix code
# Identifies unused let-bindings, arguments, and other dead code in Nix expressions.
#
# This check runs deadnix to find potentially unused code in Nix files.
# It's automatically included in the flake's checks when running `nix flake check`.
#
# To fix issues, run `nix run github:astro/deadnix#deadnix -- --edit .`
{
  # Standard flake inputs
  pkgs,
  self,
  lib ? pkgs.lib,
  ...
} @ args: let
  # Get the deadnix package
  deadnix = pkgs.deadnix;

  # Directories to check for Nix files
  # These paths are relative to the flake root
  directories = [
    "." # Root directory
    "./checks" # Check definitions
    "./dev-shells" # Development shells
    "./libraries" # Libraries
    "./modules" # Module definitions
    "./outputs" # Output definitions
    "./supported-systems" # Supported systems
    "./variables" # Variables
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

  # Convert filesToCheck to a space-separated string
  filesToCheckStr = builtins.concatStringsSep " " filesToCheck;

  # Create a shell script to run the checks
  checkScript = pkgs.writeShellScript "check-deadnix" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # ANSI color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    echo "Checking for dead Nix code..."

    # Check if there are any files to check
    if [ -z "${filesToCheckStr}" ]; then
      echo -e "''${GREEN}✓ No Nix files found to check''${NC}"
      touch $out
      exit 0
    fi

    # Run deadnix on all files at once
    if ! ${deadnix}/bin/deadnix --quiet ${filesToCheckStr}; then
      echo -e "\n''${RED}✗ Deadnix found unused code in one or more files''${NC}"
      echo -e "To fix issues, run: nix run github:astro/deadnix#deadnix -- --edit ."
      exit 1
    else
      echo -e "''${GREEN}✓ No dead code found''${NC}"
      touch $out
    fi
  '';
in
  pkgs.runCommand "check-deadnix" {
    buildInputs = [deadnix];
    meta = {
      description = "Check for unused Nix code with deadnix";
      longDescription = ''
        This check uses deadnix to identify potentially unused let-bindings,
        function arguments, and other dead code in Nix expressions.
      '';
    };
  } ''
    # Run the check script
    ${checkScript}
  ''
