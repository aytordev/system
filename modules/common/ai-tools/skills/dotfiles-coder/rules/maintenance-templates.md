## Development Templates

**Impact:** MEDIUM

Use the project template system for new development environments. Templates live in `templates/` and are accessible via `nix flake init -t .#template-name`. Each template defines a devShell with appropriate tooling.

**Incorrect (Manual Shells):**

```nix
# Creating ad-hoc devShells without using the template system
{
  devShells.x86_64-linux.default = pkgs.mkShell {
    buildInputs = [ pkgs.nodejs pkgs.pnpm ];
    # No structure, no reusability
  };
}
```

**Correct (Template System):**

```nix
# templates/node/flake.nix
{
  description = "Node.js development template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux" "aarch64-linux" "aarch64-darwin"
      ];
    in
    {
      devShells = forEachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nodejs_22
            nodePackages.pnpm
          ];
        };
      });
    };
}
```
