moduleArgs @ {
  config,
  lib,
  identity,
  ...
}: let
  inherit (lib.aytordev) enabled;
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
        podmanEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        aiEnable = true;
      }; # Editors, dev tools
      business = enabled; # Thunderbird, bitwarden-cli
      social = enabled; # Discord, Vesktop
      networking = enabled; # Network tools
    };

    # Temporary: exercise the Sora family end to end on this host.
    theme = {
      name = "sora";
      variant = "dark";
    };

    # Host-specific overrides and custom configurations only
    programs = {
      desktop = {
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
        tools = {
          # Explicit MCP selection (ADR 0015, C2). The reusable module enables
          # no servers; this home opts into the same set for both clients.
          mcp.selection = {
            opencode = ["engram" "filesystem" "nixos"];
            pi = ["engram" "filesystem" "nixos"];
          };

          # Home-boundary policy: enable the adopted SDD engine (ADR 0015, C12 /
          # T27). This is the only place the reusable default is turned on, so
          # Pi's SDD workflow resolves `workflow.engine` to the `aytordev-sdd`
          # adapter and OpenCode uses the same boundary. Reusable modules keep
          # their empty/disabled defaults.
          #
          # Rollback and backend-state preservation: restoring a previous Home
          # Manager generation restores the engine, adapter, and skills only. It
          # does not delete runtime state — Engram memory lives outside the store
          # under `$XDG_DATA_HOME/engram` and SDD artifacts live under each
          # project's `openspec/` tree, so both survive a rollback. Data rollback
          # is "do not adopt the derived output"; migrations keep originals
          # byte-identical. See modules/common/ai-tools/legacy-compatibility.md.
          gentle-ai.enable = true;

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

          # Host-specific SSH configuration
          ssh = {
            hosts.github = {
              hostNames = ["github.com"];
              user = "git";
              identityFile = "/Users/${username}/.ssh/ssh_key_github_ed25519";
              identitiesOnly = true;
              port = 22;
            };

            # Portfolio Hetzner VPS — update hostNames with the real IP in PR6.T3
            hosts.hetzner-portfolio = {
              hostNames = ["hetzner-portfolio-vps"]; # TODO PR6.T3: replace with actual VPS IP
              user = "deploy";
              identityFile = "/Users/${username}/.ssh/portfolio_hetzner_ed25519";
              identitiesOnly = true;
              port = 22;
            };
            knownHosts.wang-lin = {
              hostNames = ["wang-lin.local"];
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUV4bxRgp4WZX0MkVv7jg9q2i44yE6jUnnitMDGb0mO";
            };
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

  home.stateVersion = "26.11";
}
