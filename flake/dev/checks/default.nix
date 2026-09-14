{
  inputs,
  lib,
  self,
  ...
}: {
  imports = lib.optional (inputs ? git-hooks-nix) inputs.git-hooks-nix.flakeModule;

  perSystem = {
    pkgs,
    system,
    ...
  }: let
    checkInputs = self.inputs;
    identity = self.lib.identity.fromSecrets checkInputs.secrets;
    reusableInputs = builtins.removeAttrs checkInputs ["secrets"];
    # Path to the checks directory
    checksPath = ../../../checks;

    # Filter for directories that contain a default.nix
    isCheckDir = name: type: type == "directory" && builtins.pathExists (checksPath + "/${name}/default.nix");

    # Get list of valid check directories
    checkDirs = lib.filterAttrs isCheckDir (builtins.readDir checksPath);
    unitCheckNames = [
      "ai-tools-dependencies"
      "ai-tools-inventory"
      "ai-tools-loading"
      "ai-tools-sdd-handoffs"
      "ai-tools-sdd-persistence"
      "ai-tools-sdd-research"
      "architecture-layers"
      "file-parsers"
      "home-users-contract"
      "input-policy"
      "library-exports"
      "library-overlay"
      "lua-shell-quoting"
      "nix-unit"
      "parse-lix"
      "parse-nix"
    ];
    productionCheckNames = [
      "home-integration"
      "home-ssh"
      "overlay-composition"
    ];

    # Import each check
    customChecks =
      lib.mapAttrs' (name: _: {
        name = "${
          if lib.elem name unitCheckNames
          then "unit"
          else if lib.elem name productionCheckNames
          then "production"
          else "integration"
        }-${name}";
        value = import (checksPath + "/${name}") {
          inherit
            pkgs
            system
            lib
            identity
            ;
          inputs = reusableInputs;
        };
      })
      checkDirs;

    darwinChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (
      lib.mapAttrs' (name: darwin: {
        name = "production-darwin-${name}";
        value = darwin.system;
      })
      self.darwinConfigurations
    );

    homeChecks =
      lib.mapAttrs'
      (name: home: {
        name = "production-home-${lib.replaceStrings ["@"] ["-"] name}";
        value = home.activationPackage;
      })
      (lib.filterAttrs (_: home: home.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations);
    packageBuilds = pkgs.linkFarm "package-builds-${system}" (
      lib.mapAttrsToList (name: path: {inherit name path;}) self.packages.${system}
    );
  in {
    pre-commit = lib.mkIf (inputs ? git-hooks-nix) {
      check.enable = false;

      settings.hooks = {
        # FIXME: broken dependency on darwin (swift build failure)
        actionlint.enable = pkgs.stdenv.hostPlatform.isLinux;
        clang-tidy.enable = pkgs.stdenv.hostPlatform.isLinux;
        deadnix = {
          enable = true;
          settings.edit = false;
        };
        eslint = {
          enable = true;
          package = pkgs.eslint_d;
        };
        luacheck.enable = true;
        # pre-commit-hook-ensure-sops.enable = true;
        statix = {
          enable = true;
          # Only staged changes
          pass_filenames = true;
          entry = "${lib.getExe pkgs.bash} -c 'for file in \"$@\"; do ${lib.getExe pkgs.statix} check \"$file\"; done' --";
          language = "system";
        };
        conflict-markers = {
          enable = true;
          name = "Conflict markers";
          description = "Reject staged git conflict markers";
          entry = builtins.toString (
            pkgs.writeShellScript "conflict-markers" ''
              set -euo pipefail
              if ${pkgs.git}/bin/git diff --cached | ${pkgs.gnugrep}/bin/grep -qE '^\+(<{7}|>{7})'; then
                printf 'Error: staged changes contain conflict markers\n' >&2
                exit 1
              fi
            ''
          );
        };
        treefmt.enable = true;
        typos.enable = true;
      };
    };

    checks = customChecks // darwinChecks // homeChecks // {package-builds = packageBuilds;};
  };
}
