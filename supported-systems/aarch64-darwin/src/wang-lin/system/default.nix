{
  lib,
  inputs,
  config,
  ...
}: let
  sopsFolder = builtins.toString inputs.secrets + "/hard-secrets";
in {
  nixpkgs.overlays = [
    inputs.self.overlays.google-chrome-dev
  ];

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
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_username".key = "thunderbird_protonmail_bridge_username";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_username".sopsFile = "${sopsFolder}/shared.yaml";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_username".path = "/Users/${inputs.secrets.username}/.config/protonmail-bridge/user.username";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_username".owner = "${inputs.secrets.username}";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_username".mode = "0400";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_password".key = "thunderbird_protonmail_bridge_password";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_password".sopsFile = "${sopsFolder}/shared.yaml";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_password".path = "/Users/${inputs.secrets.username}/.config/protonmail-bridge/user.password";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_password".owner = "${inputs.secrets.username}";
  darwin.security.sops.secrets."thunderbird_protonmail_bridge_password".mode = "0400";
  darwin.services.protonmail-bridge.enable = true;
  darwin.services.protonmail-bridge.usernameFile = "/Users/${inputs.secrets.username}/.config/protonmail-bridge/user.username";
  darwin.services.protonmail-bridge.passwordFile = "/Users/${inputs.secrets.username}/.config/protonmail-bridge/user.password";
  homebrew.casks = ["docker-desktop" "ghostty" "sf-symbols"];
}
