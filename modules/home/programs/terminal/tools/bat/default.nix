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
    # cat is a drop-in for bat in every shell (nushell has no cat builtin, so
    # no conflict). No --style override: let cat honor the configured style.
    home.shellAliases = {
      cat = "${getExe cfg.package}";
    };
  };
}
