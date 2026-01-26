{
  inputs,
  lib,
  ...
}: {
  imports = lib.optional (inputs ? git-hooks-nix) inputs.git-hooks-nix.flakeModule;

  perSystem = {
    pkgs,
    self,
    system,
    ...
  }: let
    # Path to the checks directory
    checksPath = ../../../checks;

    # Filter for directories that contain a default.nix
    isCheckDir = name: type:
      type == "directory" && builtins.pathExists (checksPath + "/${name}/default.nix");

    # Get list of valid check directories
    checkDirs = lib.filterAttrs isCheckDir (builtins.readDir checksPath);

    # Import each check
    customChecks =
      lib.mapAttrs (
        name: _:
          import (checksPath + "/${name}") {
            inherit pkgs system lib;
            inherit (self) inputs;
          }
      )
      checkDirs;
  in {
    pre-commit = lib.mkIf (inputs ? git-hooks-nix) {
      check.enable = false;

      settings.hooks = {
        # FIXME: broken dependency on darwin (swift build failure)
        actionlint.enable = pkgs.stdenv.hostPlatform.isLinux;
        clang-tidy.enable = pkgs.stdenv.hostPlatform.isLinux;
        deadnix = {
          enable = true;
          settings.edit = true;
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
        treefmt.enable = true;
        typos = {
          enable = true;
          settings = {
            extend-words = {
              ags = "ags";
              ba = "ba";
              Folx = "Folx";
              folx = "folx";
              iterm = "iterm";
              metaphore = "metaphore";
            };
          };
          excludes = ["^flake/dev/checks/default\\.nix$"]; # Exclude self to avoid flagging the ignored words list
        };
      };
    };

    checks = customChecks;
  };
}
