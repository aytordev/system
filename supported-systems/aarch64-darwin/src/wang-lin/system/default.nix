{
  lib,
  inputs,
  ...
}: let
  sopsFolder = builtins.toString inputs.secrets + "/hard-secrets";
in {
  system.stateVersion = 6;
  system.networking.hostName = "wang-lin";
  system.networking.computerName = "Mac Studio M3 Ultra (2025)";
  system.networking.localHostName = "wang-lin";
  system.primaryUser = inputs.secrets.username;
  darwin.tools.homebrew.enable = true;
  darwin.security.sops.enable = true;
  darwin.security.sops.defaultSopsFile = "${sopsFolder}/${inputs.secrets.username}.yaml";
  darwin.security.sops.age.keyFile = "/Users/${inputs.secrets.username}/.config/sops/age/keys.txt";
  darwin.security.sops.secrets.github_ssh_private_key.key = "github_ssh_private_key";
  darwin.security.sops.secrets.github_ssh_private_key.path = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  darwin.security.sops.secrets.github_ssh_private_key.mode = "0600";
  darwin.security.sops.secrets.github_ssh_private_key.owner = "${inputs.secrets.username}";
  applications.terminal.tools.ssh.knownHosts."github".hostNames = ["github.com"];
  applications.terminal.tools.ssh.knownHosts."github".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
  darwin.security.sudo.enable = true;
  darwin.user.enable = true;
  darwin.user.name = inputs.secrets.username;
  darwin.user.email = inputs.secrets.useremail;
  darwin.user.fullName = inputs.secrets.userfullname;
  darwin.user.uid = 501;
  homebrew.casks = ["docker-desktop" "ghostty" "sf-symbols"];
}
