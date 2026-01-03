{
  config,
  lib,
  inputs,
  ...
}:
{
  # Host-specific settings only
  # All modules auto-discovered from modules/darwin/
  # All homes auto-injected from homes/aarch64-darwin/aytordev@wang-lin/

  networking.hostName = "wang-lin";
  networking.localHostName = "wang-lin";

  nix.settings.cores = 8;
  nix.settings.max-jobs = 4;

  system.stateVersion = 6;
}
