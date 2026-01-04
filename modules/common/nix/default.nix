{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  primaryUser = config.system.primaryUser;
  allowedUsers = [
    "root"
    "@wheel"
    "nix-builder"
    primaryUser
  ];
  essentialPackages = with pkgs; [
    deploy-rs
    git
    nix-prefetch-git
  ];
  nixDaemonSettings = {
    allowed-users = allowedUsers;
    trusted-users = allowedUsers;
    sandbox = true;
    auto-optimise-store = pkgs.stdenv.hostPlatform.isLinux;
    builders-use-substitutes = true;
    http-connections = 50;
    keep-derivations = true;
    keep-going = true;
    keep-outputs = true;
    log-lines = 50;
    use-xdg-base-directories = true;
    warn-dirty = false;
    experimental-features = ["nix-command" "flakes"];
  };

  cfg = config.aytordev.nix;
in {
  options.aytordev.nix.enable = mkEnableOption "Common Nix configuration";

  config = mkIf cfg.enable {
    environment.systemPackages = essentialPackages;
    nix = {
      package = pkgs.nixVersions.latest;
      checkConfig = true;
      distributedBuilds = true;
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
      settings = nixDaemonSettings;
    };
  };
}
