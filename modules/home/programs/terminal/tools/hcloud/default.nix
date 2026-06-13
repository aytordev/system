{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.hcloud;
  hasToken = cfg.auth.tokenPath != null;
in {
  options.aytordev.programs.terminal.tools.hcloud = {
    enable = mkEnableOption "Hetzner Cloud CLI";

    auth = {
      tokenPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/Users/username/.config/sops/hcloud_token";
        description = ''
          Path to a file containing the Hetzner Cloud API token.
          When set, HCLOUD_TOKEN is exported at shell startup for automatic authentication.
          Designed to work with sops-nix managed secrets.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.hcloud];

    programs = {
      zsh.initContent = mkIf hasToken ''
        if [[ -f "${cfg.auth.tokenPath}" ]]; then
          export HCLOUD_TOKEN="$(command cat "${cfg.auth.tokenPath}")"
        fi
      '';

      bash.initExtra = mkIf hasToken ''
        if [[ -f "${cfg.auth.tokenPath}" ]]; then
          export HCLOUD_TOKEN="$(command cat "${cfg.auth.tokenPath}")"
        fi
      '';

      fish.interactiveShellInit = mkIf hasToken ''
        if test -f "${cfg.auth.tokenPath}"
          set -gx HCLOUD_TOKEN (command cat "${cfg.auth.tokenPath}")
        end
      '';

      nushell.extraEnv = mkIf hasToken ''
        if ("${cfg.auth.tokenPath}" | path exists) {
          $env.HCLOUD_TOKEN = (open "${cfg.auth.tokenPath}" | str trim)
        }
      '';
    };
  };
}
