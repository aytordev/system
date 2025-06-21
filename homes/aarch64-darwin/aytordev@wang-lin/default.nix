{
  config,
  lib,
  ...
}: let
  cfg = config.home;
in {
  options.home = with lib.types; {
    enable = lib.mkEnableOption "home configuration";
  };

  config = lib.mkIf cfg.enable {
    home.stateVersion = "25.11";
  };
}
