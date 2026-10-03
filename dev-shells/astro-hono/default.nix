{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  catalog = import ../../modules/common/languages/catalog.nix {inherit pkgs;};
  astroHonoPackages =
    catalog.node.runtime "22"
    ++ [pkgs.pnpm pkgs.bun pkgs.typescript pkgs.typescript-language-server];
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
