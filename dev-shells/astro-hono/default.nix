{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  astroHonoPackages = with pkgs; [
    nodejs_22
    pnpm
    bun
    typescript
    typescript-language-server
  ];
in
  mkShell {
    packages = astroHonoPackages;

    shellHook = ''
      echo -e "\n\033[1;32m🚀 Astro + Hono DevShell\033[0m"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        astroHonoPackages}
      echo ""
      echo "⚛️  Stack: Astro + Hono + Bun | pnpm workspaces"
    '';
  }
