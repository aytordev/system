{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.comma;
in {
  options.aytordev.programs.terminal.tools.comma = {
    enable = lib.mkEnableOption "comma";
    package = lib.mkPackageOption pkgs "nix-index" {};
  };

  config = mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;

      nix-index = {
        enable = true;
        inherit (cfg) package;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        # link nix-index database to ~/.cache/nix-index
        symlinkToCacheHome = true;
      };
    };
  };
}
