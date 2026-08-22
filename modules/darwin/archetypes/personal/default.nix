{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.archetypes.personal;
in {
  options.aytordev.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = lib.mkIf cfg.enable {
    aytordev.suites = {
      common.enable = lib.mkDefault true;
      desktop.enable = lib.mkDefault true;
      music.enable = lib.mkDefault true;
    };
  };
}
