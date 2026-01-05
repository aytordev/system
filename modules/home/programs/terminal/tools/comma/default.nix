{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.aytordev.programs.terminal.tools.comma;
in {
  options.aytordev.programs.terminal.tools.comma = {
    enable = mkEnableOption "comma";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      comma
      nix-index
    ];
    programs = {
      nix-index = {
        enable = true;
        package = pkgs.nix-index;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
