{
  config,
  lib,
  ...
}: let
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.archetypes.personal;
in {
  options.aytordev.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = lib.mkIf cfg.enable {
    aytordev = {
      suites = {
        common = enabled;
        desktop = enabled;
        music = enabled;
      };
    };
  };
}
