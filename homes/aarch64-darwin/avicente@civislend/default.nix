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
        # Bring the AI coding agents (pi, opencode, ...) so
        # the host can be iterated on remotely; providers need a local /login or
        # API-key env for now (nan.builders is gated on SOPS, off on this host).
        aiEnable = true;
      };
    };

    programs.desktop = {
      # Development suite enables vscode by default; its kanagawa theme mirror
      # currently 404s on .vsix downloads, so keep it off in the boilerplate.
      editors.vscode = disabled;
    };
  };

  home.stateVersion = "26.11";
}
