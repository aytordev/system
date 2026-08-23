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
  cfg = config.aytordev.programs.terminal.tools.gh;
  hasToken = cfg.auth.tokenPath != null;
  tokenPath =
    if hasToken
    then cfg.auth.tokenPath
    else "";
  tokenPathShell = lib.escapeShellArg tokenPath;
  tokenPathNu = builtins.toJSON tokenPath;
  executable = lib.getExe cfg.package;
in {
  options.aytordev.programs.terminal.tools.gh = {
    enable = mkEnableOption "GitHub CLI tool";
    package = lib.mkPackageOption pkgs "gh" {};

    auth = {
      tokenPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/Users/username/.config/sops/github_token";
        description = ''
          Path to a file containing the GitHub personal access token.
          The token is injected only into GitHub CLI processes.
          Designed to work with sops-nix managed secrets.
        '';
      };
    };

    gitCredentialHelper = {
      hosts = mkOption {
        type = with types; listOf str;
        default = [
          "https://github.com"
          "https://gist.github.com"
        ];
        description = "List of hosts for which gh should be used as a credential helper";
        example = ''
          [ "github.com" "enterprise.github.com" ]
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        inherit (cfg) package;
        extensions = with pkgs; [
          gh-eco
          gh-cal
          gh-poi
          gh-notify
          gh-dash
        ];
        gitCredentialHelper = {
          enable = true;
          inherit (cfg.gitCredentialHelper) hosts;
        };
        settings = {
          version = "1";
        };
      };

      zsh.initContent = mkIf hasToken ''
        gh() {
          if [[ -r ${tokenPathShell} ]]; then
            GH_TOKEN="$(<${tokenPathShell})" ${executable} "$@"
          else
            ${executable} "$@"
          fi
        }
      '';

      bash.initExtra = mkIf hasToken ''
        gh() {
          if [[ -r ${tokenPathShell} ]]; then
            GH_TOKEN="$(<${tokenPathShell})" ${executable} "$@"
          else
            ${executable} "$@"
          fi
        }
      '';

      fish.interactiveShellInit = mkIf hasToken ''
        function gh
          if test -r ${tokenPathShell}
            env GH_TOKEN=(string trim < ${tokenPathShell}) ${executable} $argv
          else
            ${executable} $argv
          end
        end
      '';

      nushell.extraConfig = mkIf hasToken ''
        def --wrapped gh [...args] {
          if (${tokenPathNu} | path exists) {
            with-env { GH_TOKEN: (open --raw ${tokenPathNu} | str trim) } {
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
