{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.podman-compose;

  # Project docs invoke `docker-compose`. Forward that command to the
  # podman-native provider; `podman compose` sets up the runtime environment
  # before exec'ing the provider pinned in containers.conf below.
  dockerComposeCompat = pkgs.writeShellApplication {
    name = "docker-compose";
    runtimeInputs = [pkgs.podman];
    text = ''exec podman compose "$@"'';
  };
in {
  options.aytordev.programs.terminal.tools.podman-compose = {
    enable = mkEnableOption "podman-compose";
    package = mkPackageOption pkgs "podman-compose" {};
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package dockerComposeCompat];

    # Pin `podman compose` to the provider this module installs. The absolute
    # store path keeps the lookup off PATH, so it can never re-enter the
    # `docker-compose` shim. Also drop the "executing an external command" notice.
    xdg.configFile."containers/containers.conf".text = ''
      [engine]
      compose_providers = ["${lib.getExe cfg.package}"]
      compose_warning_logs = false
    '';
  };
}
