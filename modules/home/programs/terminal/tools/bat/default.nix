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
    package = lib.mkPackageOption pkgs "bat" {};
  };
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      inherit (cfg) package;
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
      cat = "${getExe cfg.package} --style=auto";
    };
    xdg.configFile."bash/conf.d/bat.sh".text = ''
      alias cat="${cfg.package}/bin/bat --style=auto"
    '';
  };
}
