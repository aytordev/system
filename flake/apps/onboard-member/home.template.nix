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
      development.enable = true;
    };

    programs.desktop = {
      # Development suite enables vscode by default; its kanagawa theme mirror
      # currently 404s on .vsix downloads, so keep it off in the boilerplate.
      editors.vscode = disabled;
    };
  };

  home.stateVersion = "26.11";
}
