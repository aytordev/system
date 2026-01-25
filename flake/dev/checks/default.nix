{
  inputs,
  lib,
  ...
}:
{
  imports = lib.optional (inputs ? git-hooks-nix) inputs.git-hooks-nix.flakeModule;

  perSystem =
    {
      pkgs,
      self,
      system,
      ...
    }:
    let
      customChecks = import ../../../checks {
        inherit (self) inputs;
        inherit pkgs system lib;
      };
    in
    {
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
          treefmt.enable = false; # Disabled until treefmt is configured
          typos = {
            enable = true;
            # excludes = [ "generated/*" ]; # FIXME: Regex compliance
          };
        };
      };

      checks = customChecks;
    };
}
