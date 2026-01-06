{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib.aytordev) enabled disabled;
in
{
  aytordev = {
    user = {
      enable = true;
      name = inputs.secrets.username;
      home = "/Users/${inputs.secrets.username}";
    };

    # Enable suites for common functionality
    suites = {
      common = enabled;      # Shells, terminal emulators, common tools
      desktop = enabled;     # Browsers, raycast, aerospace
      development = {
        enable = true;
        dockerEnable = true;
        gameEnable = false;
        goEnable = false;
        kubernetesEnable = true;
        nixEnable = true;
        sqlEnable = true;
        aiEnable = true;
      }; # Editors, dev tools
      business = enabled;    # Thunderbird, bitwarden-cli
      social = enabled;      # Discord, Vesktop
      networking = enabled;  # Network tools
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
          theme = "catppuccin-mocha";
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
              enableZshIntegration = true;
              enableBashIntegration = true;
              enableFishIntegration = true;
            };
            aliases = enabled;
            rbw = enabled;
            settings.apiKey = {
              useSops = true;
              clientIdPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_id";
              clientSecretPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_secret";
            };
          };

          # Custom direnv settings
          direnv = {
            nix-direnv = true;
            silent = true;
          };

          # Host-specific git signing key
          git.signingKey = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";

          # Custom jujutsu settings
          jujutsu.signByDefault = true;

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

          # Ollama - Disabled: Using Homebrew cask version for better macOS integration
          ollama = disabled // {
            acceleration = "metal";
            models = [
              "llama3.2"
              "codellama"
              "mistral"
            ];
            service = {
              enable = true;
              autoStart = true;
            };
            shellAliases = true;
            environmentVariables = {
               OLLAMA_NUM_PARALLEL = "2";
               OLLAMA_MAX_LOADED_MODELS = "2";
               OLLAMA_KEEP_ALIVE = "5m";
            };
            integrations.zed = true;
            modelPresets = [ "general" "coding" ];
          };

          # Host-specific SSH configuration
          ssh.knownHosts.github = {
            hostNames = ["github.com"];
            user = "git";
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
            identityFile = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
            identitiesOnly = true;
            port = 22;
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
