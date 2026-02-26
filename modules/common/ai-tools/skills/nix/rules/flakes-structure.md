## Standard Flake Structure

**Impact:** HIGH

Follow the standard flake schema. Keep `description` meaningful, use `inputs.url` for all dependencies, and structure `outputs` with explicit system parameters.

**Incorrect (Hardcoded System):**

Missing system parameter breaks multi-arch support.

```nix
{
  description = "My project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # BAD - hardcoded system breaks on other architectures
    packages.myPkg = nixpkgs.legacyPackages.x86_64-linux.hello;

    # BAD - only works on x86_64-linux
    devShells.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.git ];
    };
  };
}
```

**Correct (Multi-System):**

Full flake with proper system abstraction.

```nix
{
  description = "My project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Helper to generate attributes for all systems
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.hello;

          myApp = pkgs.stdenv.mkDerivation {
            name = "my-app";
            src = ./.;
            buildInputs = [ pkgs.git ];
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.git
              pkgs.nixpkgs-fmt
            ];
          };
        }
      );
    };
}
```
