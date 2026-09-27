{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "bitwarden-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "bitwarden-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "bitwarden@example.test";
            fullName = "Bitwarden User";
            home = homeDirectory;
          };
          programs.desktop.security.bitwarden = {
            enable = true;
            installPackage = false;
            enableSystemStartup = pkgs.stdenv.hostPlatform.isDarwin;
            biometricUnlock.enable = true;
            vault.timeout = 30;
          };
        };
        home.stateVersion = "25.11";
      }
    ];
  };
  inherit (home) config;
  settings =
    builtins.fromJSON
    config.home.file.".local/share/aytordev/bitwarden-desktop/data.json".text;
  activationText = config.home.activation.bitwardenStateFile.data;
  tests = [
    (builtins.seq home.activationPackage true)
    # The application's mutable state path must not be claimed by Home Manager.
    (!(config.home.file ? "Library/Application Support/Bitwarden/data.json"))
    (!(config.xdg.configFile ? "Bitwarden/data.json"))
    # Activation seeds the state file once, behind a writable-file guard.
    (lib.hasInfix "install -m 600" activationText)
    (lib.hasInfix "[ -L \"$stateFile\" ]" activationText)
    (lib.hasInfix "[ ! -e \"$stateFile\" ]" activationText)
    settings.enableBrowserIntegration
    settings.biometricUnlock
    (settings.vaultTimeout == 30)
    (settings.vaultTimeoutAction == "lock")
    (
      if pkgs.stdenv.hostPlatform.isDarwin
      then
        builtins.head config.launchd.agents.bitwarden.config.ProgramArguments
        == "/Applications/Bitwarden.app/Contents/MacOS/Bitwarden"
      else true
    )
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-bitwarden-tests" {} ''
      touch "$out"
    ''
