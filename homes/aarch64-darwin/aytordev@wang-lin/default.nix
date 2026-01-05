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

    programs = {
      desktop = {
        # bars.sketchybar.enable = true;

        browsers = {
          chrome = enabled;
          chrome-dev = enabled;
          brave = enabled;
          chromium = enabled;
          firefox = enabled;
        };

        communications = {
          discord = enabled;
          thunderbird = enabled;
          # vesktop = enabled;
        };

        editors = {
          vscode = disabled;
          antigravity = enabled;
          zed = enabled;
        };

        launchers = {
          raycast = enabled;
        };

        security = {
          bitwarden = {
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

        window-manager-system = {
          aerospace = enabled;
        };
      };

      terminal = {
        emulators = {
          ghostty = {
            enable = true;
            theme = "catppuccin-mocha";
            enableThemes = true;
          };
          # warp = enabled;
        };

        shells = {
          zsh = enabled;
          bash = enabled;
          fish = enabled;
          nu = enabled;
        };

        tools = {
          atuin = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            enableNushellIntegration = true;
          };

          bat = enabled;

          bitwarden-cli = {
            enable = true;
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

          bottom = enabled;
          btop = enabled;
          carapace = enabled;
          comma = enabled;

          direnv = {
            enable = true;
            nix-direnv = true;
            silent = true;
          };

          eza = enabled;
          fastfetch = enabled;
          fzf = enabled;
          gh = enabled;

          git = {
            enable = true;
            signingKey = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
          };

          git-crypt = enabled;
          jq = enabled;

          jujutsu = {
            enable = true;
            signByDefault = true;
          };

          lazydocker = enabled;
          lazygit = enabled;

          navi = {
            enable = true;
            settings.style = {
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
          };

          nh = enabled;

          # Ollama - Local LLM Runner
          # Disabled: Using Homebrew cask version instead for better macOS integration
          ollama = disabled // {
            acceleration = "metal"; # Use Metal for GPU acceleration on macOS
            models = [
              "llama3.2"      # General purpose 3B model
              "codellama"     # Code generation
              "mistral"       # 7B general model
            ];
            service = {
              enable = true;
              autoStart = true;
            };
            shellAliases = true;
            # Shell aliases are now handled automatically by the module
            environmentVariables = {
               OLLAMA_NUM_PARALLEL = "2";
               OLLAMA_MAX_LOADED_MODELS = "2";
               OLLAMA_KEEP_ALIVE = "5m";
            };
            # Enable Zed integration through new module structure
            integrations.zed = true;
            modelPresets = [ "general" "coding" ];
          };

          ripgrep = enabled;

          ssh = {
            enable = true;
            knownHosts.github = {
              hostNames = ["github.com"];
              user = "git";
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
              identityFile = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
              identitiesOnly = true;
              port = 22;
            };
            extraConfig = '''';
          };

          starship = {
            enable = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            enableBashIntegration = true;
            enableNushellIntegration = true;
          };

          yazi = enabled;
          zellij = enabled;
          zoxide = enabled;
        };
      };
    };
  };

  home.stateVersion = "25.11";
}
