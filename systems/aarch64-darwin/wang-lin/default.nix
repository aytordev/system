{
  lib,
  config,
  ...
}:
let
  inherit (lib.aytordev) enabled;
  cfg = config.aytordev.user;
in
{
  # Host-specific settings only
  # All modules auto-discovered from modules/darwin/
  # All homes auto-injected from homes/aarch64-darwin/aytordev@wang-lin/

  aytordev = {
    # User configuration is handled by modules/darwin/user
  };

  networking = {
    hostName = "wang-lin";
    localHostName = "wang-lin";
  };

  nix.settings = {
    cores = 8;
    max-jobs = 4;
  };

  # Required by nix-darwin for user-specific system defaults
  system.primaryUser = cfg.name;

  system.stateVersion = 6;
}
