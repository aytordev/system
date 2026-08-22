{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "consumer-user";
  email = "consumer@example.test";
  fullName = "Consumer User";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "consumer-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            inherit email fullName;
            name = username;
            home = homeDirectory;
          };
          programs.terminal.tools = {
            git.enable = true;
            jujutsu.enable = true;
            lazygit.enable = true;
            bitwarden-cli = {
              enable = true;
              settings.apiKey = {
                clientIdPath = "/run/secrets/consumer-client-id";
                clientSecretPath = "/run/secrets/consumer-client-secret";
              };
            };
          };
        };
        home.stateVersion = "25.11";
      }
    ];
  };
  inherit (home) config;
  tests = [
    (config.programs.git.settings.user.name == username)
    (config.programs.git.settings.user.email == email)
    (config.programs.jujutsu.settings.user.name == username)
    (config.programs.jujutsu.settings.user.email == email)
    (builtins.hasAttr fullName config.programs.lazygit.settings.gui.authorColors)
    (config.programs.rbw.settings.email == email)
    (lib.elem homeDirectory config.programs.git.settings.safe.directory)
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-identity-tests" {} ''
      touch "$out"
    ''
