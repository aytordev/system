{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe mkIf;
  cfg = config.aytordev.programs.terminal.tools.bat;
in {
  options.aytordev.programs.terminal.tools.bat = {
    enable = lib.mkEnableOption "bat";
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        style = "auto,header-filesize";
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };
    home.shellAliases = {
      cat = "${getExe pkgs.bat} --style=auto";
    };
    xdg.configFile."bash/conf.d/bat.sh".text = ''
      alias cat="${pkgs.bat}/bin/bat --style=auto"
    '';
  };
}
