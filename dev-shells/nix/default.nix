{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  nixPackages = with pkgs; [
    just
  ];
in
  mkShell {
    packages = nixPackages;

    shellHook = ''
      echo -e "\n\033[1;32m🎯 Nix Runner Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        nixPackages}
      echo ""
      if [ -f "Justfile" ] || [ -f "justfile" ]; then
        just --list
      else
        echo -e "\033[33mℹ️  No Justfile found in current directory\033[0m"
      fi
    '';
  }
