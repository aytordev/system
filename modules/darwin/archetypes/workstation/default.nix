{
  config,
  lib,

  ...
}:
let
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.archetypes.workstation;
in
{
  options.aytordev.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = lib.mkIf cfg.enable {
    aytordev = {
      suites = {
        business = enabled;
        common = enabled;
        desktop = enabled;
        development = enabled;
        networking = enabled;
      };
    };
  };
}
