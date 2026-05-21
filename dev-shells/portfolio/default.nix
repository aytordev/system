{
  pkgs,
  mkShell,
  ...
}:
let
  inherit (pkgs) lib;
  portfolioPackages = with pkgs; [
    nodejs_22
    pnpm
    bun
    typescript
    typescript-language-server
  ];
in
mkShell {
  packages = portfolioPackages;

  shellHook = ''
    echo "Portfolio DevShell"
    echo ""
    echo "Available tools:"
    ${lib.concatMapStringsSep "\n" (
      pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
    ) portfolioPackages}
    echo ""
    echo "Stack: Astro + Hono + Bun | pnpm workspaces"
  '';
}
