{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.programs.terminal.tools.bottom;
in {
  options.aytordev.programs.terminal.tools.bottom = {
    enable = lib.mkEnableOption "bottom";
    package = lib.mkPackageOption pkgs "bottom" {};
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
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
          alias htop="${cfg.package}/bin/btm"
        '';
      };
  };
}
