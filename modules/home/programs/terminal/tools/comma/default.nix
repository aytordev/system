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
  };

  config = mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;

      nix-index = {
        enable = true;
        package = pkgs.nix-index;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        # link nix-index database to ~/.cache/nix-index
        symlinkToCacheHome = true;
      };
    };
  };
}
