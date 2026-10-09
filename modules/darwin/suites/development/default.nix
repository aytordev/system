{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.suites.development;
in {
  options.aytordev.suites.development = {
    enable = lib.mkEnableOption "common development configuration";
    dockerDesktopEnable = lib.mkEnableOption "docker desktop configuration";
    podmanEnable = lib.mkEnableOption "podman desktop configuration";
  };

  config = mkIf cfg.enable {
    # Exactly one provider may own /var/run/docker.sock: the Docker Desktop
    # cask installs its own privileged symlink there, and the docker-socket
    # adapter would race it (ADR 0019).
    assertions = [
      {
        assertion = !(cfg.dockerDesktopEnable && config.aytordev.services.docker-socket.enable);
        message = "aytordev.suites.development: Docker Desktop and aytordev.services.docker-socket both claim /var/run/docker.sock; exactly one provider may own it.";
      }
    ];

    # FIXME: not working again
    # aytordev.nix.nix-rosetta-builder.enable = true;

    homebrew = {
      casks =
        [
          "ghostty"
        ]
        ++ lib.optionals cfg.dockerDesktopEnable [
          "docker-desktop"
        ]
        ++ lib.optionals cfg.podmanEnable [
          "podman-desktop"
        ];

      masApps = mkIf config.aytordev.tools.homebrew.masEnable {
        # TODO: Add Mac App Store apps
      };
    };

    environment.systemPackages = [pkgs.aytordev.pen-dev];

    nix.settings = {
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
