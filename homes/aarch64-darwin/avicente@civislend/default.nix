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
        # Bring the AI coding agent (Pi) so the host can be iterated on
        # remotely. Pi provider configuration and auth are completed by native
        # setup.
        aiEnable = true;
        # Podman + podman-compose: project docs invoke `docker-compose`, which
        # the podman-compose capability forwards to `podman compose`.
        podmanEnable = true;
      };
      business = enabled;
      # Desktop CLI networking tools + the OpenVPN client. The provider's
      # `.ovpn` profile lives outside the repo under ~/.config/openvpn/, so it
      # is never managed by Nix or committed.
      networking = enabled;
      # SQL/NoSQL client tooling: PostgreSQL/MariaDB/SQLite/DuckDB/Redis/
      # mongosh CLIs plus rainfrog (SQL-only TUI) and DbGate (GUI client).
      # Client tools only: no database servers, daemons, or stored
      # connections/credentials are managed here.
      databases = enabled;
    };

    # Language support is opt-in per host. A pack owns the toolchain and the
    # editor extensions that used to be unconditional in the editor module.
    languages = {
      go.enable = true;
      java = {
        enable = true;
        version = "25";
      };
      nix.enable = true;
      node = {
        enable = true;
        version = "24";
      };
      python = {
        enable = true;
        version = "313";
      };
    };

    # Default theme family for this work host.
    theme = {
      name = "sora";
      variant = "dark";
    };

    programs = {
      terminal.tools = {
        # Official executable only; native onboarding owns the Pi profile.
        gentle-ai.enable = true;

        # Opt-in GUI adapter: publish Gentle Pi's subagent command override
        # (GENTLE_PI_AGENTS_PI) into the GUI login launchd context so Pi
        # resolves for subagents spawned by GUI hosts. See
        # modules/home/programs/terminal/tools/pi/README.md.
        pi.guiEnvironment.enable = true;

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
