## Output Organization

**Impact:** HIGH

Use `flake-parts` for organized outputs. System configurations use builder functions under `lib.system` (`mkSystem`, `mkDarwin`, `mkHome`) that handle platform abstraction. Auto-discovery recursively finds systems, homes, packages, and templates.

**Incorrect (Manual Outputs):**

```nix
{
  outputs = { self, nixpkgs, ... }: {
    # Hardcoded systems, no abstraction
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./systems/x86_64-linux/my-host/default.nix
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
  outputs = {
    self,
    inputs,
    ...
  }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      flake = {
        # Builders live under `self.lib.system`; they assemble a host and its
        # matching home from the modules auto-discovered via
        # `importModulesRecursive`. See flake/configs and flake/home for the
        # real call sites.
        nixosConfigurations.my-host = self.lib.system.mkSystem {
          inherit inputs;
          system = "x86_64-linux";
          hostname = "my-host";
          username = "me";
          # ...
        };

        darwinConfigurations.my-mac = self.lib.system.mkDarwin {
          inherit inputs;
          system = "aarch64-darwin";
          hostname = "my-mac";
          username = "me";
          # ...
        };

        homeConfigurations."me@my-mac" = self.lib.system.mkHome {
          inherit inputs;
          system = "aarch64-darwin";
          hostname = "my-mac";
          username = "me";
          # ...
        };
      };
    };
}
```
