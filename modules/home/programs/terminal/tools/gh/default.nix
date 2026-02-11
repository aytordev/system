{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.programs.terminal.tools.gh;
  hasToken = cfg.auth.tokenPath != null;
in {
  options.aytordev.programs.terminal.tools.gh = {
    enable = mkEnableOption "GitHub CLI tool";

    auth = {
      tokenPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/Users/username/.config/sops/github_token";
        description = ''
          Path to a file containing the GitHub personal access token.
          When set, GH_TOKEN is exported at shell startup for automatic authentication.
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
    home.packages = with pkgs; [
      gh
      gh-eco
      gh-cal
      gh-poi
      gh-notify
      gh-dash
    ];
    programs.gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
        inherit (cfg.gitCredentialHelper) hosts;
      };
      settings = {
        version = "1";
      };
    };

    programs.zsh.initContent = mkIf hasToken ''
      if [[ -f "${cfg.auth.tokenPath}" ]]; then
        export GH_TOKEN="$(command cat "${cfg.auth.tokenPath}")"
      fi
    '';

    programs.bash.initExtra = mkIf hasToken ''
      if [[ -f "${cfg.auth.tokenPath}" ]]; then
        export GH_TOKEN="$(command cat "${cfg.auth.tokenPath}")"
      fi
    '';

    programs.fish.interactiveShellInit = mkIf hasToken ''
      if test -f "${cfg.auth.tokenPath}"
        set -gx GH_TOKEN (command cat "${cfg.auth.tokenPath}")
      end
    '';

    programs.nushell.extraEnv = mkIf hasToken ''
      if ("${cfg.auth.tokenPath}" | path exists) {
        $env.GH_TOKEN = (open "${cfg.auth.tokenPath}" | str trim)
      }
    '';
  };
}
