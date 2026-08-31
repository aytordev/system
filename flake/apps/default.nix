{lib, ...}: {
  perSystem = {pkgs, ...}: let
    inputGroups = {
      core = {
        description = "Core Nix ecosystem";
        inputs = [
          "nixpkgs"
          "flake-parts"
        ];
      };

      system = {
        description = "System management";
        inputs = [
          "home-manager"
          "nix-darwin"
          "nix-rosetta-builder"
          "sops-nix"
        ];
      };

      apps = {
        description = "Applications & packages";
        inputs = [
          "nix-index-database"
          "yazi-flavors"
        ];
      };
    };

    mkUpdateApp = name: {
      description,
      inputs,
    }: {
      type = "app";
      meta.description = "Update ${description} inputs";
      program = lib.getExe (
        pkgs.writeShellApplication {
          name = "update-${name}";
          meta = {
            mainProgram = "update-${name}";
            description = "Update ${description} inputs";
          };
          text = ''
            set -euo pipefail

            echo "🔄 Updating ${description} inputs..."
            nix flake update ${lib.concatStringsSep " " inputs}

            echo "✅ ${description} inputs updated successfully!"
          '';
        }
      );
    };

    mkFastBuildApp = name: flakeRef: description: {
      type = "app";
      meta.description = description;
      program = lib.getExe (
        pkgs.writeShellApplication {
          name = "fast-build-${name}";
          runtimeInputs = [pkgs.nix-fast-build];
          text = ''
            nix-fast-build --flake ${flakeRef} --no-link "$@"
          '';
        }
      );
    };

    groupApps =
      lib.mapAttrs' (
        name: value: lib.nameValuePair "update-${name}" (mkUpdateApp name value)
      )
      inputGroups;
  in {
    apps =
      groupApps
      // {
        update-all = {
          type = "app";
          meta.description = "Update all flake inputs";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "update-all";
              meta = {
                mainProgram = "update-all";
                description = "Update all flake inputs";
              };
              text = ''
                set -euo pipefail

                echo "🔄 Updating main flake lock..."
                nix flake update

                echo "🔄 Updating dev flake lock..."
                cd flake/dev && nix flake update

                echo "✅ All flake locks updated successfully!"
              '';
            }
          );
        };

        fast-build-checks =
          mkFastBuildApp "checks" ".#checks"
          "Evaluate and build checks with nix-fast-build";
        fast-build-packages =
          mkFastBuildApp "packages" ".#packages"
          "Evaluate and build packages with nix-fast-build";
      };
  };
}
