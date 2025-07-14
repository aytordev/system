{
  pkgs,
  ...
}: let
  statix = pkgs.statix;
  checkPath = ".";
  checkScript = pkgs.writeShellScript "check-statix" ''
    set -euo pipefail
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    checked=0
    failed=0
    echo "Running statix checks..."
    if ! ${statix}/bin/statix check ${checkPath}; then
      echo -e "\n''${RED}✗ Statix found issues in one or more files''${NC}"
      echo -e "To fix issues, run: nix run github:nerdypepper/statix
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
    ${checkScript}
  ''
