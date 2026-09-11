{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "consumer-user";
  email = "consumer@example.test";
  fullName = "Consumer User";
  apiClientId = "user.test-client-id";
  apiClientSecret = "test-client-secret";
  apiClientIdFile = pkgs.writeText "bitwarden-client-id" apiClientId;
  apiClientSecretFile = pkgs.writeText "bitwarden-client-secret" apiClientSecret;
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
              bw.enable = true;
              server = "https://bitwarden.example.test";
              shellIntegration = {
                enable = true;
                bash = true;
              };
              apiKey = {
                enable = true;
                clientIdFile = toString apiClientIdFile;
                clientSecretFile = toString apiClientSecretFile;
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
              auth = {
                tokenPath = "/run/secrets/github-token";
                accounts = {
                  personal = {
                    tokenPath = "/run/secrets/github-personal-token";
                    command = "ghp";
                  };
                  work.tokenPath = "/run/secrets/github-work-token";
                };
              };
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
  hcloudWrappedPackage =
    lib.findFirst (
      package: lib.hasPrefix "hcloud-with-runtime-token" (lib.getName package)
    )
    null
    officialConfig.home.packages;
  ghPersonalWrapper =
    lib.findFirst (
      package: lib.getName package == "ghp"
    )
    null
    officialConfig.home.packages;
  ghWorkWrapper =
    lib.findFirst (
      package: lib.getName package == "gh-work"
    )
    null
    officialConfig.home.packages;
  bitwardenConfig = config.aytordev.programs.terminal.tools.bitwarden-cli;
  apiKeyScript = config.home.file.".local/bin/bitwarden-login-sops".text;
  rbwPinentry = config.programs.rbw.settings.pinentry;
  tests = [
    (config.programs.git.settings.user.name == fullName)
    (config.programs.git.settings.user.email == email)
    (config.programs.jujutsu.settings.user.name == fullName)
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
    (lib.any (p: lib.getName p == "bitwarden-cli") config.home.packages)
    (config.xdg.configFile ? "bitwarden-cli/session.bash")
    config.programs.rbw.enable
    (lib.hasInfix "bw completion --shell zsh" officialConfig.programs.zsh.initContent)
    (!(lib.hasInfix "export GH_TOKEN" zshInit))
    (!(lib.hasInfix "export HCLOUD_TOKEN" zshInit))
    (!(lib.hasInfix "set -gx GH_TOKEN" fishInit))
    (!(lib.hasInfix "set -gx HCLOUD_TOKEN" fishInit))
    (!(lib.hasInfix "$env.GH_TOKEN" nushellInit))
    (!(lib.hasInfix "$env.HCLOUD_TOKEN" nushellInit))
    (!(lib.hasInfix "export BW_SESSION" officialBitwardenBash))
    (!(lib.hasInfix "set -gx BW_SESSION" officialBitwardenFish))
    (lib.hasInfix "/tmp/bitwarden-" officialBitwardenBash)
    (lib.hasInfix "/tmp/bitwarden-" officialBitwardenFish)
    (lib.hasInfix "-c %a" officialBitwardenBash)
    (lib.hasInfix "-c %a" officialBitwardenFish)
    (!(lib.hasInfix "TMPDIR" officialBitwardenBash))
    (!(lib.hasInfix "TMPDIR" officialBitwardenFish))
    (lib.hasPrefix "gh-with-runtime-token" (lib.getName officialConfig.programs.gh.package))
    (hcloudWrappedPackage != null)
    (ghPersonalWrapper != null)
    (ghWorkWrapper != null)
    (lib.hasInfix "rbw-api-key-pinentry" rbwPinentry)
    (lib.hasInfix "PINENTRY_USER_DATA=aytordev-bitwarden-api-key" apiKeyScript)
    (!(lib.hasInfix "BW_CLIENTID" apiKeyScript))
    (lib.hasInfix "register" apiKeyScript)
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
      if ${lib.getExe officialConfig.programs.gh.package} --version; then
        echo "GitHub CLI wrapper did not fail closed" >&2
        exit 1
      fi
      if ${lib.getExe hcloudWrappedPackage} version; then
        echo "Hetzner Cloud wrapper did not fail closed" >&2
        exit 1
      fi
      if ${lib.getExe ghPersonalWrapper} --version; then
        echo "ghp wrapper did not fail closed" >&2
        exit 1
      fi
      client_id_output="$(
        printf 'SETTITLE rbw\nSETPROMPT API key client__id\nSETDESC Test\nGETPIN\n' \
          | PINENTRY_USER_DATA=aytordev-bitwarden-api-key ${rbwPinentry}
      )"
      client_secret_output="$(
        printf 'SETTITLE rbw\nSETPROMPT API key client__secret\nSETDESC Test\nGETPIN\n' \
          | PINENTRY_USER_DATA=aytordev-bitwarden-api-key ${rbwPinentry}
      )"
      case "$client_id_output" in
        *"D ${apiClientId}"*) ;;
        *)
          echo "rbw pinentry did not return the API client ID" >&2
          exit 1
          ;;
      esac
      case "$client_id_output" in
        "OK Pleased to meet you"*) ;;
        *)
          echo "rbw pinentry did not emit an Assuan greeting" >&2
          exit 1
          ;;
      esac
      case "$client_secret_output" in
        *"D ${apiClientSecret}"*) ;;
        *)
          echo "rbw pinentry did not return the API client secret" >&2
          exit 1
          ;;
      esac
      if printf 'UNEXPECTED\n' \
        | PINENTRY_USER_DATA=aytordev-bitwarden-api-key ${rbwPinentry} >/dev/null; then
        echo "rbw pinentry accepted an unexpected command" >&2
        exit 1
      fi
      touch "$out"
    ''
