{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;

  cfg = config.aytordev.programs.terminal.tools.herdr;
in {
  options.aytordev.programs.terminal.tools.herdr = {
    enable = mkEnableOption "herdr agent runtime";
    package = mkPackageOption pkgs "herdr" {};
  };

  config = mkIf cfg.enable {
    # herdr manages its own agent integrations (e.g. `herdr integration install
    # opencode` writes files under ~/.config/opencode). Do not vendor them: a
    # store symlink would block herdr's installer/updater.
    programs.herdr = {
      enable = true;
      inherit (cfg) package;

      settings = {
        onboarding = false;

        # Nix owns updates; disable the binary's own release checks so it does
        # not advertise self-updates that would fight the flake.
        update = {
          version_check = false;
          manifest_check = false;
        };

        terminal = {
          # Login shells on macOS pick up /usr/libexec/path_helper and Homebrew.
          shell_mode = "auto";
          new_cwd = "follow";
        };

        # Follow the host terminal's ANSI palette; ghostty is already themed
        # from aytordev.theme, so herdr inherits it without a built-in family.
        theme.name = "terminal";

        ui.toast.delivery = "terminal";
      };
    };
  };
}
