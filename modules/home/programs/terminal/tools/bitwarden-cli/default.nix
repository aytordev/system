{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  isRbw = cfg.client == "rbw";
  hasApiKeyFiles = cfg.apiKey.clientIdFile != null && cfg.apiKey.clientSecretFile != null;
  clientIdFile = lib.escapeShellArg (toString cfg.apiKey.clientIdFile);
  clientSecretFile = lib.escapeShellArg (toString cfg.apiKey.clientSecretFile);
  clientCommand =
    if isRbw
    then "rbw"
    else "bw";
in {
  imports = [./shell-integration.nix];

  options.aytordev.programs.terminal.tools.bitwarden-cli = {
    enable = lib.mkEnableOption "a Bitwarden-compatible command-line client";

    client = lib.mkOption {
      type = lib.types.enum [
        "rbw"
        "bw"
      ];
      default = "rbw";
      description = "Bitwarden-compatible client to configure.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default =
        if isRbw
        then pkgs.rbw
        else pkgs.bitwarden-cli;
      defaultText = lib.literalExpression ''
        if config.aytordev.programs.terminal.tools.bitwarden-cli.client == "rbw"
        then pkgs.rbw
        else pkgs.bitwarden-cli
      '';
      description = "Package providing the selected Bitwarden client.";
    };

    server = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://bitwarden.example.com";
      description = "Custom server URL for rbw.";
    };

    apiKey = {
      enable = lib.mkEnableOption "runtime login using API key files";
      clientIdFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/bitwarden-client-id";
        description = "Runtime file containing the Bitwarden API client ID.";
      };
      clientSecretFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/bitwarden-client-secret";
        description = "Runtime file containing the Bitwarden API client secret.";
      };
    };

    shellIntegration = {
      enable = lib.mkEnableOption "session helpers and completions for the official bw client";
      zsh = lib.mkOption {
        type = lib.types.bool;
        default = config.aytordev.programs.terminal.shells.zsh.enable;
        description = "Enable Zsh integration.";
      };
      bash = lib.mkOption {
        type = lib.types.bool;
        default = config.aytordev.programs.terminal.shells.bash.enable;
        description = "Enable Bash integration.";
      };
      fish = lib.mkOption {
        type = lib.types.bool;
        default = config.aytordev.programs.terminal.shells.fish.enable;
        description = "Enable Fish integration.";
      };
    };

    aliases.enable =
      lib.mkEnableOption "short aliases for the selected Bitwarden client"
      // {
        default = true;
      };

    pinentry = lib.mkOption {
      type = lib.types.package;
      default =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry-gnome3;
      defaultText = lib.literalExpression "pkgs.pinentry_mac or pkgs.pinentry-gnome3";
      description = "Pinentry package used by rbw.";
    };
  };

  config = lib.mkIf cfg.enable {
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
      packages = lib.optionals isRbw [cfg.pinentry] ++ lib.optionals (!isRbw) [cfg.package];

      shellAliases = lib.mkIf cfg.aliases.enable {
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

      file.".local/bin/bitwarden-login-sops" = lib.mkIf (cfg.apiKey.enable && hasApiKeyFiles) {
        executable = true;
        text = ''
          #!${lib.getExe pkgs.bash}
          set -euo pipefail

          client_id_file=${clientIdFile}
          client_secret_file=${clientSecretFile}

          if [[ ! -r "$client_id_file" || ! -r "$client_secret_file" ]]; then
            printf 'Bitwarden API key files are not readable\n' >&2
            exit 1
          fi

          export BW_CLIENTID="$(<"$client_id_file")"
          export BW_CLIENTSECRET="$(<"$client_secret_file")"
          exec ${lib.getExe cfg.package} login${lib.optionalString (!isRbw) " --apikey"}
        '';
      };
    };

    programs.rbw = lib.mkIf isRbw {
      enable = true;
      inherit (cfg) package;
      settings = {
        email = config.aytordev.user.email;
        base_url = cfg.server;
        inherit (cfg) pinentry;
        sync_interval = 3600;
      };
    };
  };
}
