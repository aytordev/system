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
  cfg = config.aytordev.nix;
  allowedUsers =
    [
      "root"
      "@wheel"
      "nix-builder"
    ]
    ++ cfg.extraTrustedUsers;
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
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
in {
  options.aytordev.nix = {
    enable = mkEnableOption "Common Nix configuration";
    package = lib.mkPackageOption pkgs "Nix" {
      default = [
        "nixVersions"
        "latest"
      ];
    };
    extraTrustedUsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional users allowed and trusted by the Nix daemon";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = essentialPackages;
    nix = {
      inherit (cfg) package;
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
