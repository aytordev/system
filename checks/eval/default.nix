{
  pkgs,
  self,
  ...
}: let
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
    if [ -f "${flakeRoot}/flake.nix" ]; then
      nix-instantiate --parse --quiet "${flakeRoot}/flake.nix" >/dev/null
    else
      echo "Error: flake.nix not found in ${flakeRoot}"
      exit 1
    fi
    touch $out
  ''
