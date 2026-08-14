{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aytordev.system.logging;
in {
  imports = [
    ./newsyslog.nix
  ];

  options.aytordev.system.logging = {
    enable = mkEnableOption "system logging configuration";
  };

  config = mkIf cfg.enable {
    aytordev.system.newsyslog = {
      enable = true;
    };
  };
}
