{
  lib,
  identity,
  config,
  ...
}: let
  inherit (lib.aytordev) enabled;
  inherit (identity) username;

  cfg = config.aytordev.user;
in {
  aytordev = {
    user = {
      name = username;
      inherit (identity) email fullName;
    };

    # Role selection; extend with more archetypes as this machine matures.
    archetypes = {
      personal = enabled;
      workstation = enabled;
    };

    # TODO(osb): enable security.sops after provisioning the machine's age key
    # and adding `hard-secrets/${username}.yaml` to the private secrets flake.
    security.sops.enable = false;
  };

  networking = {
    hostName = "civislend";
    localHostName = "civislend";
  };

  # Required by nix-darwin for user-specific system defaults
  system.primaryUser = cfg.name;

  system.stateVersion = 6;
}
