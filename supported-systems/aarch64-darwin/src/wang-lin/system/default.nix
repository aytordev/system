# wang-lin modules configuration
#
# This file defines host-specific module configurations for the wang-lin system.
# It serves as a central place to manage and organize all module configurations
# specific to this host.
{
  lib,
  inputs,
  ...
}: let
  sopsFolder = builtins.toString inputs.secrets + "/hard-secrets";
in {
  # Add any host-specific module configurations here
  # This is a good place to set default values or overrides for modules
  # that are specific to this host.

  system.stateVersion = 6; # Match your nix-darwin version

  # Set the hostname
  system.networking.hostName = "wang-lin";
  system.networking.computerName = "Mac Studio M3 Ultra (2025)";
  system.networking.localHostName = "wang-lin";

  # Set the primary user for user-specific configurations
  system.primaryUser = inputs.secrets.username;

  # Configure Homebrew
  darwin.tools.homebrew.enable = true;

  # Configure SOPS
  darwin.security.sops.enable = true;
  darwin.security.sops.defaultSopsFile = "${sopsFolder}/${inputs.secrets.username}.yaml";
  darwin.security.sops.age.keyFile = "/Users/${inputs.secrets.username}/.config/sops/age/keys.txt";

  darwin.security.sops.secrets.github_ssh_private_key.key = "github_ssh_private_key";
  darwin.security.sops.secrets.github_ssh_private_key.path = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  darwin.security.sops.secrets.github_ssh_private_key.mode = "0600";
  darwin.security.sops.secrets.github_ssh_private_key.owner = "${inputs.secrets.username}";

  # SSH configuration
  applications.terminal.tools.ssh.knownHosts."github".hostNames = ["github.com"];
  applications.terminal.tools.ssh.knownHosts."github".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
  
  # Sudo configuration
  darwin.security.sudo.enable = true;

  # User configuration
  darwin.user.enable = true;
  darwin.user.name = inputs.secrets.username;
  darwin.user.email = inputs.secrets.useremail;
  darwin.user.fullName = inputs.secrets.userfullname;
  darwin.user.uid = 501;
}
