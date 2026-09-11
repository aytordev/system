{
  lib,
  identity,
  secretsRoot,
  config,
  ...
}: let
  inherit (lib.aytordev) enabled;
  inherit (identity) username;

  cfg = config.aytordev.user;

  sopsFolder = builtins.toString secretsRoot + "/hard-secrets";
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

    # SOPS is enabled so opencode/pi can wire the nan.builders provider from the
    # SOPS-managed API key. Requires the machine's age key and a
    # `hard-secrets/${username}.yaml` entry in the private secrets flake.
    security.sops = {
      enable = true;
      defaultSopsFile = "${sopsFolder}/${username}.yaml";
      age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
      secrets = {
        bitwarden_api_client_id = {
          key = "bitwarden_api_client_id";
          path = "/Users/${username}/.config/sops/bitwarden_api_client_id";
          mode = "0600";
          owner = username;
        };
        bitwarden_api_client_secret = {
          key = "bitwarden_api_client_secret";
          path = "/Users/${username}/.config/sops/bitwarden_api_client_secret";
          mode = "0600";
          owner = username;
        };
        bitbucket_ssh_private_key = {
          key = "bitbucket_ssh_private_key";
          path = "/Users/${username}/.ssh/ssh_key_bitbucket_ed25519";
          mode = "0600";
          owner = username;
        };
        github_aytordev_ssh_private_key = {
          key = "github_aytordev_ssh_private_key";
          path = "/Users/${username}/.ssh/ssh_key_github_aytordev_ed25519";
          mode = "0600";
          owner = username;
        };
        github_aytordev_token = {
          key = "github_aytordev_token";
          path = "/Users/${username}/.config/sops/github_aytordev_token";
          mode = "0600";
          owner = username;
        };
        github_civislend_ssh_private_key = {
          key = "github_civislend_ssh_private_key";
          path = "/Users/${username}/.ssh/ssh_key_github_civislend_ed25519";
          mode = "0600";
          owner = username;
        };
        github_civislend_token = {
          key = "github_civislend_token";
          path = "/Users/${username}/.config/sops/github_civislend_token";
          mode = "0600";
          owner = username;
        };
        nan_builders_api_key = {
          key = "nan_builders_api_key";
          path = "/Users/${username}/.config/sops/nan_builders_api_key";
          mode = "0600";
          owner = username;
        };
      };
    };
  };

  networking = {
    hostName = "civislend";
    localHostName = "civislend";
  };

  # Required by nix-darwin for user-specific system defaults
  system.primaryUser = cfg.name;

  system.stateVersion = 6;
}
