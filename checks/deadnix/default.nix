{
  pkgs,
  self,
  lib ? pkgs.lib,
  ...
} @ args: let
  deadnix = pkgs.deadnix;
  directories = [
    "."
    "./checks"
    "./dev-shells"
    "./homes"
    "./libraries"
    "./modules"
    "./outputs"
    "./supported-systems"
    "./variables"
  ];
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
  filesToCheckStr = builtins.concatStringsSep " " filesToCheck;
  checkScript = pkgs.writeShellScript "check-deadnix" ''
    set -euo pipefail
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    echo "Checking for dead Nix code..."
    if [ -z "${filesToCheckStr}" ]; then
      echo -e "''${GREEN}✓ No Nix files found to check''${NC}"
      touch $out
      exit 0
    fi
    if ! ${deadnix}/bin/deadnix --quiet ${filesToCheckStr}; then
      echo -e "\n''${RED}✗ Deadnix found unused code in one or more files''${NC}"
      echo -e "To fix issues, run: nix run github:astro/deadnix
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
    ${checkScript}
  ''
