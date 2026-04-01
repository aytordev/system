{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (config.system) primaryUser;
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
    auto-optimise-store = true;
    builders-use-substitutes = true;
    accept-flake-config = false;
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
        options = "--delete-older-than 14d";
      };
      optimise.automatic = true;
      settings = nixDaemonSettings;
      extraOptions = ''
        min-free = ${toString (5 * 1024 * 1024 * 1024)}
        max-free = ${toString (15 * 1024 * 1024 * 1024)}
      '';
    };
  };
}
