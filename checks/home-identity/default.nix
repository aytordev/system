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
              shellIntegration = {
                enable = true;
                bash = true;
                fish = true;
                zsh = true;
              };
            };
            tools.gh = {
              enable = true;
              auth.tokenPath = "/run/secrets/github-token";
            };
            tools.hcloud = {
              enable = true;
              auth.tokenPath = "/run/secrets/hcloud-token";
            };
          };
        };
        home.stateVersion = "25.11";
      }
    ];
  };
  inherit (home) config;
  officialConfig = officialHome.config;
  bashInit = officialConfig.programs.bash.initExtra;
  fishInit = officialConfig.programs.fish.interactiveShellInit;
  nushellInit = officialConfig.programs.nushell.extraConfig;
  zshInit = officialConfig.programs.zsh.initContent;
  bashInitFile = pkgs.writeText "credential-wrappers.bash" bashInit;
  fishInitFile = pkgs.writeText "credential-wrappers.fish" fishInit;
  nushellInitFile = pkgs.writeText "credential-wrappers.nu" nushellInit;
  zshInitFile = pkgs.writeText "credential-wrappers.zsh" zshInit;
  officialBitwardenBash = officialConfig.xdg.configFile."bitwarden-cli/session.bash".text;
  officialBitwardenFish = officialConfig.xdg.configFile."bitwarden-cli/session.fish".text;
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
    (!(lib.hasInfix "export GH_TOKEN" zshInit))
    (!(lib.hasInfix "export HCLOUD_TOKEN" zshInit))
    (!(lib.hasInfix "set -gx GH_TOKEN" fishInit))
    (!(lib.hasInfix "set -gx HCLOUD_TOKEN" fishInit))
    (!(lib.hasInfix "$env.GH_TOKEN" nushellInit))
    (!(lib.hasInfix "$env.HCLOUD_TOKEN" nushellInit))
    (!(lib.hasInfix "export BW_SESSION" officialBitwardenBash))
    (!(lib.hasInfix "set -gx BW_SESSION" officialBitwardenFish))
    (lib.hasInfix "/run/secrets/consumer-client-id" apiKeyScript)
    (lib.hasInfix "/run/secrets/consumer-client-secret" apiKeyScript)
    (lib.elem homeDirectory config.programs.git.settings.safe.directory)
    (!(config.home.file ? "Desktop/.keep"))
    (!(config.home.shellAliases ? cleanup))
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-identity-tests"
    {
      nativeBuildInputs = [
        pkgs.bash
        pkgs.fish
        pkgs.nushell
        pkgs.zsh
      ];
    }
    ''
      bash -n ${bashInitFile}
      fish --no-execute ${fishInitFile}
      nu --no-config-file --commands 'source ${nushellInitFile}'
      zsh -n ${zshInitFile}
      touch "$out"
    ''
