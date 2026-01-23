{
  description = "Node.js project template with Nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      devShells = forEachSystem (system: {
        default = (pkgsFor system).mkShell {
          packages = with (pkgsFor system); [
            nodejs_22
            nodePackages.pnpm
            nodePackages.typescript
            nodePackages.typescript-language-server
          ];

          shellHook = ''
            echo "📦 Node.js development environment"
          '';
        };
      });
    };
}
