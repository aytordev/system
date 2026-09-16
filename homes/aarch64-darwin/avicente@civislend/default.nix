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
        # iterated on remotely. SOPS is enabled on this host, so opencode/pi
        # wire the nan.builders provider from the SOPS-managed API key file.
        aiEnable = true;
        nixEnable = true;
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
        # byte-identical. See docs/ai-tools/legacy-compatibility.md.
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
