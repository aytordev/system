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
      ({inputs, ...}: {
        assertions = [
          {
            assertion = !(inputs ? secrets);
            message = "Reusable Home Manager modules must not receive the private secrets input";
          }
        ];
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
              server = "https://bitwarden.example.test";
              apiKey = {
                enable = true;
                clientIdFile = "/run/secrets/consumer-client-id";
                clientSecretFile = "/run/secrets/consumer-client-secret";
              };
            };
          };
        };
        home.stateVersion = "25.11";
      })
    ];
  };
  officialHome = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "official-bitwarden-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            inherit email fullName;
            name = username;
            home = homeDirectory;
          };
          programs.terminal = {
            shells.zsh.enable = true;
            tools.bitwarden-cli = {
              enable = true;
              client = "bw";
              shellIntegration.enable = true;
            };
          };
        };
        home.stateVersion = "25.11";
      }
    ];
  };
  inherit (home) config;
  officialConfig = officialHome.config;
  bitwardenConfig = config.aytordev.programs.terminal.tools.bitwarden-cli;
  apiKeyScript = config.home.file.".local/bin/bitwarden-login-sops".text;
  tests = [
    (config.programs.git.settings.user.name == username)
    (config.programs.git.settings.user.email == email)
    (config.programs.jujutsu.settings.user.name == username)
    (config.programs.jujutsu.settings.user.email == email)
    (config.programs.git.signing.signByDefault != true)
    (!(config.programs.jujutsu.settings ? signing))
    (builtins.hasAttr fullName config.programs.lazygit.settings.gui.authorColors)
    (config.programs.rbw.settings.email == email)
    (config.programs.rbw.settings.base_url == "https://bitwarden.example.test")
    (!(config.home.sessionVariables ? BW_CLIENTSECRET))
    (bitwardenConfig.client == "rbw")
    (config.programs.rbw.package == bitwardenConfig.package)
    (!(config.home.file ? ".local/bin/bw-session"))
    (officialConfig.aytordev.programs.terminal.tools.bitwarden-cli.package == pkgs.bitwarden-cli)
    (!officialConfig.programs.rbw.enable)
    (officialConfig.xdg.configFile ? "bitwarden-cli/session.bash")
    (lib.hasInfix "bw completion --shell zsh" officialConfig.programs.zsh.initContent)
    (lib.hasInfix "/run/secrets/consumer-client-id" apiKeyScript)
    (lib.hasInfix "/run/secrets/consumer-client-secret" apiKeyScript)
    (lib.elem homeDirectory config.programs.git.settings.safe.directory)
    (!(config.home.file ? "Desktop/.keep"))
    (!(config.home.shellAliases ? cleanup))
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-identity-tests" {} ''
      touch "$out"
    ''
