{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.aytordev.system.xdg;
in {
  options.aytordev.system.xdg = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable XDG base directories";
    };
  };

  config = mkIf cfg.enable {
    xdg.enable = true;
  };
}
