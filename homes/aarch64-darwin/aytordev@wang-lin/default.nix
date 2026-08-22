moduleArgs @ {
  config,
  lib,
  identity,
  ...
}: let
  inherit (lib.aytordev) enabled disabled;
  inherit (identity) username;
in {
  assertions = [
    {
      assertion = !(moduleArgs ? secretsRoot);
      message = "Home configurations must not receive the private secrets root";
    }
  ];

  aytordev = {
    user = {
      enable = true;
      name = username;
      inherit (identity) email fullName;
      home = "/Users/${username}";
    };

    # Enable suites for common functionality
    suites = {
      common = enabled; # Shells, terminal emulators, common tools
      desktop = enabled; # Browsers, raycast, aerospace
      development = {
        enable = true;
        dockerEnable = false;
        podmanEnable = true;
        gameEnable = false;
        goEnable = false;
        kubernetesEnable = true;
        nixEnable = true;
        sqlEnable = true;
        aiEnable = true;
      }; # Editors, dev tools
      business = enabled; # Thunderbird, bitwarden-cli
      social = enabled; # Discord, Vesktop
      networking = enabled; # Network tools
    };

    # Host-specific overrides and custom configurations only
    programs = {
      desktop = {
        # Override: disable vscode (suite enables it by default)
        editors.vscode = disabled;

        # Custom bitwarden desktop settings
        security.bitwarden = {
          enable = true;
          enableBrowserIntegration = true;
          enableTrayIcon = true;
          biometricUnlock = enabled;
          vault = {
            timeout = 30;
            timeoutAction = "lock";
          };
        };
      };

      terminal = {
        # Custom ghostty theme
        emulators.ghostty = {
          theme = "kanagawa-wave";
          enableThemes = true;
        };

        tools = {
          # Custom shell integrations
          atuin = {
            enableBashIntegration = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            enableNushellIntegration = true;
          };

          # Host-specific bitwarden CLI configuration
          bitwarden-cli = {
            shellIntegration = {
              enable = true;
              zsh = true;
              bash = true;
              fish = true;
            };
            aliases = enabled;
            client = "rbw";
            apiKey = {
              enable = true;
              clientIdFile = "/Users/${username}/.config/sops/bitwarden_api_client_id";
              clientSecretFile = "/Users/${username}/.config/sops/bitwarden_api_client_secret";
            };
          };

          # Custom direnv settings
          direnv = {
            nix-direnv = true;
            silent = true;
          };

          # Host-specific gh authentication via sops
          gh.auth.tokenPath = "/Users/${username}/.config/sops/github_cli_personal_access_token";

          # Host-specific hcloud authentication via sops
          hcloud.auth.tokenPath = "/Users/${username}/.config/sops/hcloud_token";

          # Portfolio Backblaze B2 backup remote — secrets injected from sops at activation
          rclone.remotes.portfolio-b2 = {
            config = {
              type = "b2";
            };
            secrets = {
              account = "/Users/${username}/.config/sops/b2_key_id";
              key = "/Users/${username}/.config/sops/b2_app_key";
            };
          };

          # Host-specific commit signing
          git.signing = {
            enable = true;
            key = "/Users/${username}/.ssh/ssh_key_github_ed25519";
          };
          jujutsu.signing = {
            enable = true;
            key = "/Users/${username}/.ssh/ssh_key_github_ed25519";
          };

          # Custom navi styling
          navi.settings.style = {
            tag = {
              color = "green";
              width_percentage = 26;
              min_width = 20;
            };
            comment = {
              color = "blue";
              width_percentage = 42;
              min_width = 45;
            };
            snippet = {
              color = "white";
              width_percentage = 42;
              min_width = 45;
            };
          };

          nh.flake = "${config.home.homeDirectory}/Developer/system";

          # Ollama - M3 Ultra optimized; the user service remains opt-in.
          ollama = {
            acceleration = "metal";
            modelPresets = ["m3-ultra"];
            integrations.zed = true;
            service.enable = false;
          };

          # Host-specific SSH configuration
          ssh.hosts.github = {
            hostNames = ["github.com"];
            user = "git";
            identityFile = "/Users/${username}/.ssh/ssh_key_github_ed25519";
            identitiesOnly = true;
            port = 22;
          };

          # Portfolio Hetzner VPS — update hostNames with the real IP in PR6.T3
          ssh.hosts.hetzner-portfolio = {
            hostNames = ["hetzner-portfolio-vps"]; # TODO PR6.T3: replace with actual VPS IP
            user = "deploy";
            identityFile = "/Users/${username}/.ssh/portfolio_hetzner_ed25519";
            identitiesOnly = true;
            port = 22;
          };
          ssh.knownHosts.wang-lin = {
            hostNames = ["wang-lin.local"];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUV4bxRgp4WZX0MkVv7jg9q2i44yE6jUnnitMDGb0mO";
          };

          # Custom starship integrations
          starship = {
            enableZshIntegration = true;
            enableFishIntegration = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
          };
        };
      };
    };
  };

  home.stateVersion = "25.11";
}
