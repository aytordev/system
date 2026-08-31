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
  # Host-specific settings only
  # All modules auto-discovered from modules/darwin/
  # All homes auto-injected from homes/aarch64-darwin/aytordev@wang-lin/

  aytordev = {
    user = {
      name = username;
      inherit (identity) email fullName;
    };

    archetypes = {
      personal = enabled;
      workstation = enabled;
    };

    security = {
      sops = {
        enable = true;
        defaultSopsFile = "${sopsFolder}/${username}.yaml";
        age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
        secrets = {
          github_ssh_private_key = {
            key = "github_ssh_private_key";
            path = "/Users/${username}/.ssh/ssh_key_github_ed25519";
            mode = "0600";
            owner = username;
          };
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
          github_cli_personal_access_token = {
            key = "github_cli_personal_access_token";
            path = "/Users/${username}/.config/sops/github_cli_personal_access_token";
            mode = "0600";
            owner = username;
          };
          nan_builders_api_key = {
            key = "nan_builders_api_key";
            path = "/Users/${username}/.config/sops/nan_builders_api_key";
            mode = "0600";
            owner = username;
          };
          hetzner_ssh_private_key = {
            sopsFile = "${sopsFolder}/portfolio.yaml";
            key = "hetzner_ssh_private_key";
            path = "/Users/${username}/.ssh/portfolio_hetzner_ed25519";
            mode = "0600";
            owner = username;
          };
          hetzner_api_token = {
            sopsFile = "${sopsFolder}/portfolio.yaml";
            key = "hetzner_api_token";
            path = "/Users/${username}/.config/sops/hcloud_token";
            mode = "0600";
            owner = username;
          };
          b2_key_id = {
            sopsFile = "${sopsFolder}/portfolio.yaml";
            key = "b2_key_id";
            path = "/Users/${username}/.config/sops/b2_key_id";
            mode = "0600";
            owner = username;
          };
          b2_app_key = {
            sopsFile = "${sopsFolder}/portfolio.yaml";
            key = "b2_app_key";
            path = "/Users/${username}/.config/sops/b2_app_key";
            mode = "0600";
            owner = username;
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
