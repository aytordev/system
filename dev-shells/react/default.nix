{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  reactPackages = with pkgs; [
    nodejs_22
    pnpm
    yarn
    bun
    typescript
    typescript-language-server
  ];
in
  mkShell {
    packages = reactPackages;

    shellHook = ''
      echo -e "\n\033[1;32m⚛️  React DevShell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        reactPackages}
      echo ""
      echo "⚛️  Modern React tooling with Vite"
      echo "📦 Package managers: npm, pnpm, yarn, bun"
    '';
  }
