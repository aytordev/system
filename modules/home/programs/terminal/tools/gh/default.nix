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
  executable = lib.getExe cfg.package;
  wrappedExecutable = pkgs.writeShellScript "gh-with-runtime-token" ''
    set -euo pipefail
    if [[ ! -r ${tokenPathShell} ]]; then
      printf 'GitHub CLI token file is not readable: %s\n' ${tokenPathShell} >&2
      exit 1
    fi
    ${cfg.auth.tokenVariable}="$(<${tokenPathShell})" exec ${executable} "$@"
  '';
  wrappedPackage = pkgs.symlinkJoin {
    name = "gh-with-runtime-token";
    paths = [cfg.package];
    meta.mainProgram = "gh";
    postBuild = ''
      rm -f "$out/bin/gh"
      ln -s ${wrappedExecutable} "$out/bin/gh"
    '';
  };
  effectivePackage =
    if hasToken
    then wrappedPackage
    else cfg.package;
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
      tokenVariable = mkOption {
        type = types.enum [
          "GH_TOKEN"
          "GH_ENTERPRISE_TOKEN"
        ];
        default = "GH_TOKEN";
        description = "Environment variable used for GitHub CLI authentication.";
      };
    };

    gitCredentialHelper = {
      hosts = mkOption {
        type = with types; listOf str;
        default = [
          "https://github.com"
          "https://gist.github.com"
        ];
        description = ''
          Hosts for which gh is used as a credential helper. Set
          auth.tokenVariable to GH_ENTERPRISE_TOKEN for enterprise hosts.
        '';
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
        package = effectivePackage;
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
    };
  };
}
