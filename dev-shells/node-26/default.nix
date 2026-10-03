{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  nodePackages = catalog.node.toolchain "26";
in
  mkShell {
    packages = nodePackages;

    shellHook = ''
      echo -e "\n\033[1;32m🎯 Node.js 26 Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        nodePackages}
    '';
  }
