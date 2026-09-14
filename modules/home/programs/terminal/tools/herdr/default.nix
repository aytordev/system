{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;

  cfg = config.aytordev.programs.terminal.tools.herdr;
  themeCfg = config.aytordev.theme;

  # herdr has no named-theme registry; the UI follows the shared palette through
  # `[theme.custom]` in every family.
  herdrTheme = import ./theme.nix {
    inherit (themeCfg) palette ansi;
  };
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

        # Palette-generated theme (see theme.nix); follows aytordev.theme in
        # every family instead of a single built-in look.
        theme = herdrTheme;

        ui.toast.delivery = "terminal";
      };
    };
  };
}
