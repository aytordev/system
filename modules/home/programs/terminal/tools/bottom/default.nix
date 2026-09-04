{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.bottom;
in {
  options.aytordev.programs.terminal.tools.bottom = {
    enable = mkEnableOption "bottom";
    package = mkPackageOption pkgs "bottom" {};
  };
  config = mkIf cfg.enable {
    programs.bottom = {
      enable = true;
      inherit (cfg) package;
      settings = {
        flags.group_processes = true;
        row = [
          {
            ratio = 3;
            child = [
              {type = "cpu";}
              {type = "mem";}
              {type = "net";}
            ];
          }
          {
            ratio = 3;
            child = [
              {
                type = "proc";
                ratio = 1;
                default = true;
              }
            ];
          }
        ];
      };
    };
    xdg.configFile."bash/conf.d/bottom.sh" =
      (lib.aytordev.shellIntegration config).whenShellEnabled "bash"
      {
        text = ''
          alias htop="${lib.getExe cfg.package}"
        '';
      };
  };
}
