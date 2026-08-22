{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.archetypes.workstation;
in {
  options.aytordev.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = lib.mkIf cfg.enable {
    aytordev.suites = {
      business.enable = lib.mkDefault true;
      common.enable = lib.mkDefault true;
      desktop.enable = lib.mkDefault true;
      development = {
        enable = lib.mkDefault true;
        dockerEnable = lib.mkDefault false;
        podmanEnable = lib.mkDefault true;
        aiEnable = lib.mkDefault false;
      };
      networking.enable = lib.mkDefault true;
    };
  };
}
