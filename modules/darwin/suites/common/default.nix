{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.suites.common;
in {
  imports = [(lib.getFile "modules/common/suites/common/default.nix")];

  config = mkIf cfg.enable {
    # The shells platform adapter owns programs.<shell>.enable and the login
    # shell; this suite no longer hard-wires system zsh.
    homebrew = {
      casks = [
        "keymapp"
      ];
    };

    environment = {
      systemPackages =
        [
          pkgs.duti
          pkgs.gawk
          pkgs.gnugrep
          pkgs.gnupg
          pkgs.gnused
          pkgs.gnutls
          pkgs.terminal-notifier
          pkgs.wtfutil
        ]
        ++ lib.optionals config.aytordev.tools.homebrew.masEnable [
          pkgs.mas
        ];
    };

    aytordev = {
      nix = mkDefault enabled;

      programs.terminal.tools = {
        atuin = mkDefault enabled;
        nh = mkDefault enabled;
      };

      tools = {
        homebrew = mkDefault enabled;
      };

      services = {
        openssh.enable = mkDefault false;
      };

      system = {
        fonts = mkDefault enabled;
        input = mkDefault enabled;
        interface = mkDefault enabled;
        logging = mkDefault enabled;
        networking = mkDefault enabled;
        rosetta = mkDefault enabled;
      };
    };
  };
}
