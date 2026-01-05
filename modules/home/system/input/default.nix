{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aytordev.system.input;
in
{
  options.aytordev.system.input = {
    enable = mkEnableOption "macOS input";
  };

  config = mkIf cfg.enable {
    services.macos-remap-keys = {
      enable = true;
      keyboard = {
        Capslock = "Escape";
      };
    };
  };
}
