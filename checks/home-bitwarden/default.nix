{
  inputs,
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
  settingsFile =
    if pkgs.stdenv.hostPlatform.isDarwin
    then config.home.file."Library/Application Support/Bitwarden/data.json"
    else config.xdg.configFile."Bitwarden/data.json";
  settings = builtins.fromJSON settingsFile.text;
  tests = [
    (builtins.seq home.activationPackage true)
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
