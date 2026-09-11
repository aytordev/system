{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    literalExpression
    optionals
    getExe
    escapeShellArg
    ;
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  isRbw = cfg.client == "rbw";
  hasApiKeyFiles = cfg.apiKey.clientIdFile != null && cfg.apiKey.clientSecretFile != null;
  clientIdFile = escapeShellArg (toString cfg.apiKey.clientIdFile);
  clientSecretFile = escapeShellArg (toString cfg.apiKey.clientSecretFile);
  apiKeyPinentryMarker = "aytordev-bitwarden-api-key";
  apiKeyPinentry = pkgs.writeShellApplication {
    name = "rbw-api-key-pinentry";
    text = ''
      if [[ "''${PINENTRY_USER_DATA:-}" != ${escapeShellArg apiKeyPinentryMarker} ]]; then
        exec ${getExe cfg.pinentry} "$@"
      fi

      client_id_file=${clientIdFile}
      client_secret_file=${clientSecretFile}
      prompt=""
      state="title"
      printf 'OK Pleased to meet you\n'

      while IFS= read -r command; do
        case "$state:$command" in
          "title:SETTITLE rbw")
            state="prompt"
            printf 'OK\n'
            ;;
          prompt:SETPROMPT\ *)
            prompt="''${command#SETPROMPT }"
            case "$prompt" in
              "API key client__id" | "API key client__secret") ;;
              *)
                printf 'ERR 83886179 Unexpected%%20rbw%%20prompt\n'
                exit 1
                ;;
            esac
            state="description"
            printf 'OK\n'
            ;;
          description:SETDESC\ *)
            state="ready"
            printf 'OK\n'
            ;;
          ready:SETERROR\ *) printf 'OK\n' ;;
          ready:GETPIN)
            case "$prompt" in
              "API key client__id") secret_file="$client_id_file" ;;
              "API key client__secret") secret_file="$client_secret_file" ;;
            esac

            if [[ ! -r "$secret_file" ]]; then
              printf 'ERR 83886179 Bitwarden%%20API%%20key%%20file%%20is%%20not%%20readable\n'
              exit 1
            fi

            secret="$(<"$secret_file")"
            secret="''${secret//%/%25}"
            secret="''${secret//$'\r'/%0D}"
            secret="''${secret//$'\n'/%0A}"
            printf 'D %s\nOK\n' "$secret"
            state="done"
            ;;
          done:BYE)
            printf 'OK\n'
            exit 0
            ;;
          *)
            printf 'ERR 83886179 Unexpected%%20pinentry%%20command\n'
            exit 1
            ;;
        esac
      done
    '';
  };
  rbwPinentry =
    if isRbw && cfg.apiKey.enable && hasApiKeyFiles
    then apiKeyPinentry
    else cfg.pinentry;
  clientCommand =
    if isRbw
    then "rbw"
    else "bw";
in {
  imports = [./shell-integration.nix];

  options.aytordev.programs.terminal.tools.bitwarden-cli = {
    enable = mkEnableOption "a Bitwarden-compatible command-line client";

    client = mkOption {
      type = types.enum [
        "rbw"
        "bw"
      ];
      default = "rbw";
      description = "Bitwarden-compatible client to configure.";
    };

    package = mkOption {
      type = types.package;
      default =
        if isRbw
        then pkgs.rbw
        else pkgs.bitwarden-cli;
      defaultText = literalExpression ''
        if config.aytordev.programs.terminal.tools.bitwarden-cli.client == "rbw"
        then pkgs.rbw
        else pkgs.bitwarden-cli
      '';
      description = "Package providing the selected Bitwarden client.";
    };

    bw.enable = mkEnableOption "the official Bitwarden CLI alongside the selected client";

    server = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://bitwarden.example.com";
      description = "Custom server URL for rbw.";
    };

    apiKey = {
      enable = mkEnableOption "runtime login using API key files";
      clientIdFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/secrets/bitwarden-client-id";
        description = "Runtime file containing the Bitwarden API client ID.";
      };
      clientSecretFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/run/secrets/bitwarden-client-secret";
        description = "Runtime file containing the Bitwarden API client secret.";
      };
    };

    shellIntegration = {
      enable = mkEnableOption "session helpers and completions for the official bw client";
      zsh = mkOption {
        type = types.bool;
        default = (lib.aytordev.shellIntegration config).shellEnabled "zsh";
        description = "Enable Zsh integration.";
      };
      bash = mkOption {
        type = types.bool;
        default = (lib.aytordev.shellIntegration config).shellEnabled "bash";
        description = "Enable Bash integration.";
      };
      fish = mkOption {
        type = types.bool;
        default = (lib.aytordev.shellIntegration config).shellEnabled "fish";
        description = "Enable Fish integration.";
      };
    };

    aliases.enable =
      mkEnableOption "short aliases for the selected Bitwarden client"
      // {
        default = true;
      };

    pinentry = mkOption {
      type = types.package;
      default =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry-gnome3;
      defaultText = literalExpression "pkgs.pinentry_mac or pkgs.pinentry-gnome3";
      description = "Pinentry package used by rbw.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.apiKey.enable || hasApiKeyFiles;
        message = "bitwarden-cli requires both API key files when apiKey.enable is true";
      }
      {
        assertion = isRbw || cfg.server == null;
        message = "bitwarden-cli.server is only supported by the rbw client";
      }
    ];

    home = {
      packages =
        optionals isRbw [cfg.pinentry]
        ++ optionals (!isRbw) [cfg.package]
        ++ optionals (isRbw && cfg.bw.enable) [pkgs.bitwarden-cli];

      shellAliases = mkIf cfg.aliases.enable {
        bwl = "${clientCommand} login";
        bwu = "${clientCommand} unlock";
        bws = "${clientCommand} sync";
        bwg = "${clientCommand} get";
        bwp =
          if isRbw
          then "rbw get --field password"
          else "bw get password";
        bwc =
          if isRbw
          then "rbw get"
          else "bw get item --full-object";
      };

      file.".local/bin/bitwarden-login-sops" = mkIf (cfg.apiKey.enable && hasApiKeyFiles) {
        executable = true;
        text = ''
          #!${getExe pkgs.bash}
          set -euo pipefail

          client_id_file=${clientIdFile}
          client_secret_file=${clientSecretFile}

          if [[ ! -r "$client_id_file" || ! -r "$client_secret_file" ]]; then
            printf 'Bitwarden API key files are not readable\n' >&2
            exit 1
          fi

          ${
            if isRbw
            then ''
              export PINENTRY_USER_DATA=${escapeShellArg apiKeyPinentryMarker}
              ${getExe cfg.package} register
              unset PINENTRY_USER_DATA
              exec ${getExe cfg.package} login
            ''
            else ''
              export BW_CLIENTID="$(<"$client_id_file")"
              export BW_CLIENTSECRET="$(<"$client_secret_file")"
              exec ${getExe cfg.package} login --apikey
            ''
          }
        '';
      };
    };

    programs.rbw = mkIf isRbw {
      enable = true;
      inherit (cfg) package;
      settings = {
        email = config.aytordev.user.email;
        base_url = cfg.server;
        pinentry = rbwPinentry;
        sync_interval = 3600;
      };
    };
  };
}
