{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  nodePackages = with pkgs; [
    nodejs_26
    yarn
    pnpm
  ];
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
