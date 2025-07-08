{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.zsh;
in {
  options.applications.terminal.shells.zsh = {
    enable = mkEnableOption "Z shell with useful defaults";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
    };

    # Required packages
    home.packages = with pkgs; [
      zsh
    ];
  };
}
