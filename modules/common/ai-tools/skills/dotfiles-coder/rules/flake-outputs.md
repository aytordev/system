## Output Organization

**Impact:** HIGH

Use `flake-parts` for organized outputs. System configurations use builder functions (`mkSystem`, `mkDarwin`, `mkHome`) that handle platform abstraction. Auto-discovery recursively finds systems, homes, packages, and templates.

**Incorrect (Manual Outputs):**

```nix
{
  outputs = { self, nixpkgs, ... }: {
    # Hardcoded systems, no abstraction
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/my-host/configuration.nix
        ./modules/nixos/services/docker.nix
        ./modules/nixos/services/nginx.nix
        # Manually listing every module...
      ];
    };
  };
}
```

**Correct (Flake-parts with Builders):**

```nix
{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      flake = {
        # Auto-discovered via recursive directory scan
        nixosConfigurations = lib.mkSystem {
          inherit inputs;
          # Modules auto-imported via importModulesRecursive
        };

        darwinConfigurations = lib.mkDarwin {
          inherit inputs;
        };

        homeConfigurations = lib.mkHome {
          inherit inputs;
        };
      };
    };
}
```
