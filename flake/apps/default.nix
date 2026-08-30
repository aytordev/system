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
      };
  };
}
