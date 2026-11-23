{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  nodePackages = catalog.node.toolchain "27";
in
  mkShell {
    packages = nodePackages;

    shellHook = ''
      echo -e "\n\033[1;32m🎯 Node.js 27 Shell\033[0m"
      echo ""
      echo "⚠️  Node 27 is the Current (odd) line; the pinned nixpkgs carries a"
      echo "    pre-release build, so the reported version is not a stable tag."
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        nodePackages}
    '';
  }
