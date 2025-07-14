{
  pkgs,
  self,
  lib ? pkgs.lib,
  ...
}: let
  alejandra = self.formatter.${pkgs.system};
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
  checkScript = pkgs.writeShellScript "check-format" ''
    set -euo pipefail
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    checked=0
    failed=0
    error() {
      echo -e "''${RED}Error:''${NC} $1"
    }
    echo "Checking Nix file formatting..."
    for file in ${toString filesToCheck}; do
      rel_path="''${file
      echo "Checking $rel_path"
      if ! ${alejandra}/bin/alejandra --check "$file"; then
        error "File requires formatting: $rel_path"
        echo "  Run: nix fmt"
        failed=$((failed + 1))
      fi
      checked=$((checked + 1))
    done
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
    ${checkScript}
  ''
