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
  tokenPath =
    if hasToken
    then cfg.auth.tokenPath
    else "";
  tokenPathShell = lib.escapeShellArg tokenPath;
  tokenPathNu = builtins.toJSON tokenPath;
  executable = lib.getExe cfg.package;
in {
  options.aytordev.programs.terminal.tools.hcloud = {
    enable = mkEnableOption "Hetzner Cloud CLI";
    package = lib.mkPackageOption pkgs "hcloud" {};

    auth = {
      tokenPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/Users/username/.config/sops/hcloud_token";
        description = ''
          Path to a file containing the Hetzner Cloud API token.
          The token is injected only into Hetzner Cloud CLI processes.
          Designed to work with sops-nix managed secrets.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs = {
      zsh.initContent = mkIf hasToken ''
        hcloud() {
          if [[ -r ${tokenPathShell} ]]; then
            HCLOUD_TOKEN="$(<${tokenPathShell})" ${executable} "$@"
          else
            ${executable} "$@"
          fi
        }
      '';

      bash.initExtra = mkIf hasToken ''
        hcloud() {
          if [[ -r ${tokenPathShell} ]]; then
            HCLOUD_TOKEN="$(<${tokenPathShell})" ${executable} "$@"
          else
            ${executable} "$@"
          fi
        }
      '';

      fish.interactiveShellInit = mkIf hasToken ''
        function hcloud
          if test -r ${tokenPathShell}
            env HCLOUD_TOKEN=(string trim < ${tokenPathShell}) ${executable} $argv
          else
            ${executable} $argv
          end
        end
      '';

      nushell.extraConfig = mkIf hasToken ''
        def --wrapped hcloud [...args] {
          if (${tokenPathNu} | path exists) {
            with-env { HCLOUD_TOKEN: (open --raw ${tokenPathNu} | str trim) } {
              ^${executable} ...$args
            }
          } else {
            ^${executable} ...$args
          }
        }
      '';
    };
  };
}
