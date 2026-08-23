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
  executable = lib.getExe cfg.package;
  wrappedExecutable = pkgs.writeShellScript "hcloud-with-runtime-token" ''
    set -euo pipefail
    if [[ ! -r ${tokenPathShell} ]]; then
      printf 'Hetzner Cloud token file is not readable: %s\n' ${tokenPathShell} >&2
      exit 1
    fi
    HCLOUD_TOKEN="$(<${tokenPathShell})" exec ${executable} "$@"
  '';
  wrappedPackage = pkgs.symlinkJoin {
    name = "hcloud-with-runtime-token";
    paths = [cfg.package];
    meta.mainProgram = "hcloud";
    postBuild = ''
      rm -f "$out/bin/hcloud"
      ln -s ${wrappedExecutable} "$out/bin/hcloud"
    '';
  };
  effectivePackage =
    if hasToken
    then wrappedPackage
    else cfg.package;
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
    home.packages = [effectivePackage];
  };
}
