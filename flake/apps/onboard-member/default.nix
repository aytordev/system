{
  lib,
  pkgs,
}: let
  hostTemplate = toString ./host.template.nix;
  homeTemplate = toString ./home.template.nix;
in {
  type = "app";
  meta.description = "Bootstrap a new team member host+home into the tree";
  program = lib.getExe (
    pkgs.writeShellApplication {
      name = "onboard-member";
      runtimeInputs = [];
      text = ''
        set -euo pipefail

        if [ $# -lt 2 ]; then
          echo "usage: onboard-member <user> <hostname>" >&2
          exit 1
        fi
        user="$1"
        hostname="$2"

        case "$user" in
          *[^a-z0-9_-]*) echo "error: user must match [a-z0-9_-]" >&2; exit 1 ;;
        esac
        case "$hostname" in
          *[^a-z0-9_-]*) echo "error: hostname must match [a-z0-9_-]" >&2; exit 1 ;;
        esac

        root="$(pwd)"
        systemsPath="$root/systems/aarch64-darwin/$hostname"
        homesPath="$root/homes/aarch64-darwin/$user@$hostname"
        mkdir -p "$systemsPath" "$homesPath"

        cp "${hostTemplate}" "$systemsPath/default.nix"
        sed -i "s/@@HOSTNAME@@/$hostname/g" "$systemsPath/default.nix"
        cp "${homeTemplate}" "$homesPath/default.nix"

        echo "Created host: $systemsPath/default.nix"
        echo "Created home: $homesPath/default.nix"
        echo
        echo "Next:"
        echo "  1. Add users.$user + hard-secrets/$user.yaml to the secrets flake."
        echo "  2. Add a matching users.$user entry to checks/fixtures/secrets/flake.nix."
        echo "  3. Run: nix fmt && nix flake check"
      '';
    }
  );
}
