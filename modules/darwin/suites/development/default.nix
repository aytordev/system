{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.suites.development;
in {
  options.aytordev.suites.development = {
    enable = lib.mkEnableOption "common development configuration";
    dockerEnable = lib.mkEnableOption "docker development configuration";
    aiEnable = lib.mkEnableOption "ai development configuration";
  };

  config = mkIf cfg.enable {
    # FIXME: not working again
    # aytordev.nix.nix-rosetta-builder.enable = true;

    homebrew = {
      casks =
        [
          "ghostty"
        ]
        ++ lib.optionals cfg.dockerEnable [
          "docker-desktop"
          "podman-desktop"
        ]
        ;

      masApps = mkIf config.aytordev.tools.homebrew.masEnable {
        # TODO: Add Mac App Store apps
      };
    };

    aytordev.services = {
      ollama.enable = lib.mkDefault cfg.aiEnable;
      litellm.enable = lib.mkDefault cfg.aiEnable;
    };

    nix.settings = {
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
