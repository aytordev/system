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
    inputs.self.overlays.ungoogled-chromium
    inputs.self.overlays.ollama-binary
  ];

  system.stateVersion = 6;
  system.networking.hostName = "wang-lin";
  system.networking.computerName = "Mac Studio M3 Ultra (2025)";
  system.networking.localHostName = "wang-lin";
  system.primaryUser = inputs.secrets.username;
  system.rosetta.enable = true;
  darwin.tools.homebrew.enable = true;
  darwin.security.sops.enable = true;
  darwin.security.sops.defaultSopsFile = "${sopsFolder}/${inputs.secrets.username}.yaml";
  darwin.security.sops.age.keyFile = "/Users/${inputs.secrets.username}/.config/sops/age/keys.txt";
  darwin.security.sops.secrets.github_ssh_private_key.key = "github_ssh_private_key";
  darwin.security.sops.secrets.github_ssh_private_key.path = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  darwin.security.sops.secrets.github_ssh_private_key.mode = "0600";
  darwin.security.sops.secrets.github_ssh_private_key.owner = "${inputs.secrets.username}";
  # Bitwarden API credentials for rbw CLI (from shared.yaml)
  darwin.security.sops.secrets.bitwarden_api_client_id.sopsFile = "${sopsFolder}/shared.yaml";
  darwin.security.sops.secrets.bitwarden_api_client_id.key = "bitwarden_api_client_id";
  darwin.security.sops.secrets.bitwarden_api_client_id.path = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_id";
  darwin.security.sops.secrets.bitwarden_api_client_id.mode = "0600";
  darwin.security.sops.secrets.bitwarden_api_client_id.owner = "${inputs.secrets.username}";
  darwin.security.sops.secrets.bitwarden_api_client_secret.sopsFile = "${sopsFolder}/shared.yaml";
  darwin.security.sops.secrets.bitwarden_api_client_secret.key = "bitwarden_api_client_secret";
  darwin.security.sops.secrets.bitwarden_api_client_secret.path = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_secret";
  darwin.security.sops.secrets.bitwarden_api_client_secret.mode = "0600";
  darwin.security.sops.secrets.bitwarden_api_client_secret.owner = "${inputs.secrets.username}";
  applications.terminal.tools.ssh.knownHosts."github".hostNames = ["github.com"];
  applications.terminal.tools.ssh.knownHosts."github".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
  darwin.security.sudo.enable = true;
  darwin.user.enable = true;
  darwin.user.name = inputs.secrets.username;
  darwin.user.email = inputs.secrets.useremail;
  darwin.user.fullName = inputs.secrets.userfullname;
  darwin.user.uid = 501;
  # ProtonMail Bridge configuration
  # NOTE: ProtonMail Bridge must be configured manually first:
  # 1. Run `protonmail-bridge` (without --noninteractive) to set up your account
  # 2. Login with your ProtonMail credentials
  # 3. Configure mail client settings
  # 4. After initial setup, the service below will keep it running in background
  darwin.services.protonmail-bridge.enable = true;
  darwin.services.protonmail-bridge.logLevel = "info";  # Options: panic, fatal, error, warn, info, debug
  darwin.services.protonmail-bridge.enableGrpc = false;  # Enable if you need programmatic control
  homebrew.casks = ["docker-desktop" "ghostty" "ollama" "sf-symbols" "spotify"];
}
