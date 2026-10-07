{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.docker;
in {
  options.aytordev.programs.terminal.tools.docker = {
    enable = mkEnableOption "docker";

    package = mkPackageOption pkgs "docker-client" {};
  };

  config = mkIf cfg.enable {
    # The whole CLI story is this one package: `pkgs.docker-client` already
    # carries the Compose and Buildx plugins in its runtime closure and
    # resolves them from their store `libexec/docker/cli-plugins` paths.
    # Deliberately, this module must NOT write `~/.docker/cli-plugins` or
    # anything else under `~/.docker`: Colima rewrites `~/.docker/config.json`
    # on start AND on stop (setting/clearing `currentContext`), so any Home
    # Manager wiring there would fight the runtime provider on every switch.
    # Do not "fix" the apparent missing plugin wiring; it is not missing.
    home.packages = [cfg.package];
  };
}
