{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.user;

  sopsFolder = builtins.toString inputs.secrets + "/hard-secrets";
in {
  # Host-specific settings only
  # All modules auto-discovered from modules/darwin/
  # All homes auto-injected from homes/aarch64-darwin/aytordev@wang-lin/

  aytordev = {
    # User configuration is handled by modules/darwin/user
    archetypes = {
      personal = enabled;
      workstation = enabled;
    };

    security = {
      sops = {
        enable = true;
        defaultSopsFile = "${sopsFolder}/${inputs.secrets.username}.yaml";
        age.keyFile = "/Users/${inputs.secrets.username}/.config/sops/age/keys.txt";
        secrets = {
          github_ssh_private_key = {
            key = "github_ssh_private_key";
            path = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
            mode = "0600";
            owner = inputs.secrets.username;
          };
          bitwarden_api_client_id = {
            sopsFile = "${sopsFolder}/shared.yaml";
            key = "bitwarden_api_client_id";
            path = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_id";
            mode = "0600";
            owner = inputs.secrets.username;
          };
          bitwarden_api_client_secret = {
            sopsFile = "${sopsFolder}/shared.yaml";
            key = "bitwarden_api_client_secret";
            path = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_secret";
            mode = "0600";
            owner = inputs.secrets.username;
          };
          github_cli_personal_access_token = {
            key = "github_cli_personal_access_token";
            path = "/Users/${inputs.secrets.username}/.config/sops/github_cli_personal_access_token";
            mode = "0600";
            owner = inputs.secrets.username;
          };
        };
      };
    };
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
