{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  nodePackages = with pkgs; [
    nodejs_24
    yarn
    pnpm
  ];
in
  mkShell {
    packages = nodePackages;

    shellHook = ''
      echo -e "\n\033[1;32m🎯 Node.js 24 LTS Shell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        nodePackages}
    '';
  }
