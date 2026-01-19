{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.aytordev.services.jankyborders;
in
{
  options.aytordev.services.jankyborders = {
    enable = lib.aytordev.mkBoolOpt false "Whether to enable jankyborders in the desktop environment.";
  };

  config = mkIf cfg.enable {
    services.jankyborders = {
      enable = true;

      settings = {
        style = "round";
        width = 6.0;
        hidpi = "off";
        active_color = "0xff7793d1";
        inactive_color = "0xff5e6798";
        # FIXME: broken atm
        # background_color = "0x302c2e34";
      };
    };
  };
}
