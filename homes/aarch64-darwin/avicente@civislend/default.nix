moduleArgs @ {
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

    # Baseline CLI tooling; extend with more suites as this machine matures.
    suites = {
      common = enabled;
      development = {
        enable = true;
        # Bring the AI coding agents (pi, opencode, ...) so the host can be
        # iterated on remotely. SOPS is enabled on this host, so opencode/pi
        # wire the nan.builders provider from the SOPS-managed API key file.
        aiEnable = true;
      };
    };

    programs.desktop = {
      # Development suite enables vscode by default; its kanagawa theme mirror
      # currently 404s on .vsix downloads, so keep it off in the boilerplate.
      editors.vscode = disabled;
    };

    programs.terminal.tools.ssh.hosts.github-aytordev = {
      hostNames = ["github.com"];
      user = "git";
      identityFile = "/Users/${username}/.ssh/ssh_key_github_aytordev_ed25519";
      identitiesOnly = true;
      port = 22;
    };
  };

  home.stateVersion = "26.11";
}
