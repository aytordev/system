moduleArgs @ {
  lib,
  identity,
  ownerIdentity,
  ...
}: let
  inherit (lib.aytordev) enabled;
  inherit (identity) username;

  workSshKey = "/Users/${username}/.ssh/ssh_key_github_civislend_ed25519";
  personalSshKey = "/Users/${username}/.ssh/ssh_key_github_aytordev_ed25519";
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

    # Baseline CLI tooling; extend with more suites as this machine matures.
    suites = {
      common = enabled;
      desktop = enabled;
      development = {
        enable = true;
        # Bring the AI coding agents (pi, opencode, ...) so the host can be
        # iterated on remotely. OpenCode wires nan.builders from the SOPS key;
        # Pi provider configuration and auth are completed by native setup.
        aiEnable = true;
        nixEnable = true;
        # Podman + podman-compose: project docs invoke `docker-compose`, which
        # the podman-compose capability forwards to `podman compose`.
        podmanEnable = true;
      };
      business = enabled;
      # Desktop CLI networking tools + the OpenVPN client. The provider's
      # `.ovpn` profile lives outside the repo under ~/.config/openvpn/, so it
      # is never managed by Nix or committed.
      networking = enabled;
    };

    # Default theme family for this work host.
    theme = {
      name = "sora";
      variant = "dark";
    };

    programs = {
      terminal.tools = {
        # Explicit MCP selection for the independent OpenCode client.
        mcp.selection = {
          opencode = ["engram" "filesystem" "nixos"];
        };

        # Official executable only; native onboarding owns the Pi profile.
        gentle-ai.enable = true;

        # github.com resolves to the personal account; the work account uses the
        # `github-civislend` alias; Bitbucket uses its own key on the real host.
        ssh.hosts = {
          github = {
            hostNames = ["github.com"];
            user = "git";
            identityFile = personalSshKey;
            identitiesOnly = true;
            port = 22;
          };
          github-civislend = {
            hostNames = ["github-civislend"];
            hostName = "github.com";
            user = "git";
            identityFile = workSshKey;
            identitiesOnly = true;
            port = 22;
          };
          bitbucket = {
            hostNames = ["bitbucket.org"];
            user = "git";
            identityFile = "/Users/${username}/.ssh/ssh_key_bitbucket_ed25519";
            identitiesOnly = true;
            port = 22;
          };
        };

        # This is a work machine: the global commit identity is the work one.
        git.signing = {
          enable = true;
          key = workSshKey;
        };

        jujutsu.signing = {
          enable = true;
          key = workSshKey;
        };

        # `gh` defaults to the work account; `ghp` serves the personal one.
        gh.auth = {
          tokenPath = "/Users/${username}/.config/sops/github_civislend_token";
          accounts.personal = {
            tokenPath = "/Users/${username}/.config/sops/github_aytordev_token";
            command = "ghp";
          };
        };

        bitwarden-cli = {
          bw.enable = true;
          shellIntegration.enable = true;
          apiKey = {
            enable = true;
            clientIdFile = "/Users/${username}/.config/sops/bitwarden_api_client_id";
            clientSecretFile = "/Users/${username}/.config/sops/bitwarden_api_client_secret";
          };
        };
      };
    };
  };

  # Personal git identity only under the personal tree (owner identity comes
  # from the private secrets flake via flake/home).
  programs.git.includes = [
    {
      condition = "gitdir:/Users/${username}/Developer/aytordev/";
      contents = {
        user = {
          name = ownerIdentity.fullName;
          inherit (ownerIdentity) email;
          signingKey = personalSshKey;
        };
        gpg.format = "ssh";
      };
    }
  ];

  home.stateVersion = "26.11";
}
