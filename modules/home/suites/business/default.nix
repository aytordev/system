{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.suites.business;
  isWSL = osConfig.aytordev.archetypes.wsl.enable or false;
in
{
  options.aytordev.suites.business = {
    enable = lib.mkEnableOption "business configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        # TODO: add packages
      ];

    aytordev = {
      programs = {
        desktop = {
          communications = {
            thunderbird = lib.mkDefault (!isWSL); # No GUI email client in WSL
          };
        };
        terminal = {
          tools = {
            bitwarden-cli = lib.mkDefault enabled;
          };
        };
      };
    };
  };
}
