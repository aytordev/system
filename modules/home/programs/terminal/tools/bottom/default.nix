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
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [bottom];
    programs.bottom = {
      enable = true;
      package = pkgs.bottom;
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
    home.file.".config/bash/conf.d/bottom.sh".text = ''
      alias htop="${pkgs.bottom}/bin/btm"
    '';
  };
}
