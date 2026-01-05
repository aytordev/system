{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.programs.terminal.tools.gh;
in {
  options.aytordev.programs.terminal.tools.gh = {
    enable = mkEnableOption "GitHub CLI tool";
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
  };
}
