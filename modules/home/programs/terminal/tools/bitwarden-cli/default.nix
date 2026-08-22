{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.bitwarden-cli;
  hasSopsPaths =
    cfg.settings.apiKey.clientIdPath != null && cfg.settings.apiKey.clientSecretPath != null;
  clientIdPath =
    if cfg.settings.apiKey.clientIdPath == null
    then ""
    else cfg.settings.apiKey.clientIdPath;
  clientSecretPath =
    if cfg.settings.apiKey.clientSecretPath == null
    then ""
    else cfg.settings.apiKey.clientSecretPath;
in {
  options.aytordev.programs.terminal.tools.bitwarden-cli = {
    enable = lib.mkEnableOption "Bitwarden CLI for terminal-based password management";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bitwarden-cli;
      defaultText = lib.literalExpression "pkgs.bitwarden-cli";
      description = "The Bitwarden CLI package to install.";
    };

    settings = {
      server = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://bitwarden.company.com";
        description = ''
          Custom Bitwarden-compatible server URL for rbw.
          Configure the official CLI separately with `bw config server`.
        '';
      };

      apiKey = {
        useSops = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Use sops-nix to securely manage Bitwarden API keys.
            Both clientIdPath and clientSecretPath are required when enabled.
          '';
        };

        clientIdPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/run/secrets/bitwarden_api_client_id";
          description = ''
            Path to the file containing the Bitwarden API client ID.
          '';
        };

        clientSecretPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/run/secrets/bitwarden_api_client_secret";
          description = ''
            Path to the file containing the Bitwarden API client secret.
          '';
        };
      };

      sessionTimeout = lib.mkOption {
        type = lib.types.int;
        default = 900;
        example = 1800;
        description = ''
          Session timeout in seconds. Default is 15 minutes (900 seconds).
        '';
      };
    };

    shellIntegration = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable shell integration for session management and auto-completion.
        '';
      };

      enableZshIntegration = lib.mkOption {
        type = lib.types.bool;
        default = config.programs.terminal.shells.zsh.enable or false;
        description = ''
          Enable Zsh integration for Bitwarden CLI.
        '';
      };

      enableBashIntegration = lib.mkOption {
        type = lib.types.bool;
        default = config.programs.terminal.shells.bash.enable or false;
        description = ''
          Enable Bash integration for Bitwarden CLI.
        '';
      };

      enableFishIntegration = lib.mkOption {
        type = lib.types.bool;
        default = config.programs.terminal.shells.fish.enable or false;
        description = ''
          Enable Fish integration for Bitwarden CLI.
        '';
      };
    };

    aliases = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable convenient aliases for common Bitwarden operations.
        '';
      };

      bwl = lib.mkOption {
        type = lib.types.str;
        default = "bw login";
        description = "Alias for Bitwarden login.";
      };

      bwu = lib.mkOption {
        type = lib.types.str;
        default = "bw unlock";
        description = "Alias for Bitwarden unlock.";
      };

      bws = lib.mkOption {
        type = lib.types.str;
        default = "bw sync";
        description = "Alias for Bitwarden sync.";
      };

      bwg = lib.mkOption {
        type = lib.types.str;
        default = "bw get";
        description = "Alias for Bitwarden get.";
      };

      bwp = lib.mkOption {
        type = lib.types.str;
        default = "bw get password";
        description = "Alias for getting passwords.";
      };

      bwc = lib.mkOption {
        type = lib.types.str;
        default = "bw get item --full-object";
        description = "Alias for getting complete item details.";
      };
    };

    rbw = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enable rbw, an unofficial Bitwarden CLI client with better session management.
          This is a great alternative when the official bitwarden-cli is broken or unavailable.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.rbw;
        defaultText = lib.literalExpression "pkgs.rbw";
        description = "The rbw package to install.";
      };

      pinentry = lib.mkOption {
        type = lib.types.package;
        default =
          if pkgs.stdenv.hostPlatform.isDarwin
          then pkgs.pinentry_mac
          else pkgs.pinentry-gnome3;
        example = lib.literalExpression "pkgs.pinentry-curses";
        description = ''
          Pinentry program to use for password prompts.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.settings.apiKey.useSops || hasSopsPaths;
        message = "bitwarden-cli requires both SOPS API key paths when useSops is enabled";
      }
    ];

    home = {
      packages =
        lib.optionals (!cfg.rbw.enable) [cfg.package]
        ++ lib.optionals cfg.rbw.enable [
          cfg.rbw.package
          cfg.rbw.pinentry
        ];

      # Configure Bitwarden CLI settings
      sessionVariables.BW_SESSION_TIMEOUT = toString cfg.settings.sessionTimeout;

      # Create helper scripts
      file = {
        ".local/bin/rbw-unlock-sops" = lib.mkIf (cfg.settings.apiKey.useSops && hasSopsPaths) {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            # Helper script to unlock rbw using sops-managed API keys

            CLIENT_ID_PATH="${clientIdPath}"
            CLIENT_SECRET_PATH="${clientSecretPath}"

            if [[ ! -f "$CLIENT_ID_PATH" ]] || [[ ! -f "$CLIENT_SECRET_PATH" ]]; then
              echo "Error: Bitwarden API keys not found in sops secrets"
              echo "Expected locations:"
              echo "  Client ID: $CLIENT_ID_PATH"
              echo "  Client Secret: $CLIENT_SECRET_PATH"
              echo ""
              echo "Add these to your sops secrets file:"
              echo "  bitwarden_api_client_id: your-client-id"
              echo "  bitwarden_api_client_secret: your-client-secret"
              exit 1
            fi

            CLIENT_ID=$(cat "$CLIENT_ID_PATH")
            CLIENT_SECRET=$(cat "$CLIENT_SECRET_PATH")

            export BW_CLIENTID="$CLIENT_ID"
            export BW_CLIENTSECRET="$CLIENT_SECRET"
            rbw login
          '';
        };

        ".local/bin/bw-session" = lib.mkIf cfg.shellIntegration.enable {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            # Helper script to manage Bitwarden sessions

            case "$1" in
              unlock)
                export BW_SESSION=$(bw unlock --raw)
                echo "export BW_SESSION=$BW_SESSION"
                ;;
              lock)
                bw lock
                echo "unset BW_SESSION"
                ;;
              status)
                bw status
                ;;
              *)
                echo "Usage: $0 {unlock|lock|status}"
                exit 1
                ;;
            esac
          '';
        };
      };
    };

    xdg.configFile = {
      "bitwarden-cli/zsh-integration.sh" =
        lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableZshIntegration)
        {
          text = ''
            # Bitwarden CLI session management
            export BW_SESSION=""

            # Function to unlock Bitwarden and export session
            bw-unlock() {
              export BW_SESSION=$(bw unlock --raw)
              echo "Bitwarden vault unlocked for this session"
            }

            # Function to lock Bitwarden
            bw-lock() {
              bw lock
              unset BW_SESSION
              echo "Bitwarden vault locked"
            }

            # rbw helper functions
            rbw-login-apikey() {
              ${lib.optionalString cfg.settings.apiKey.useSops ''
              if [[ -f "${clientIdPath}" ]] && \
                 [[ -f "${clientSecretPath}" ]]; then
                export BW_CLIENTID=$(cat "${clientIdPath}")
                export BW_CLIENTSECRET=$(cat "${clientSecretPath}")
                rbw login
            ''}
              ${lib.optionalString (!cfg.settings.apiKey.useSops) ''
              if [[ -f "$XDG_CONFIG_HOME/rbw/apikey" ]]; then
                source "$XDG_CONFIG_HOME/rbw/apikey"
                export BW_CLIENTID
                export BW_CLIENTSECRET
                rbw login
            ''}
              else
                echo "API key not configured. Use 'rbw login' for password login."
                echo "To configure: Add bitwarden_api_client_id and bitwarden_api_client_secret to your sops secrets"
              fi
            }

            # Auto-completion for Bitwarden CLI
            if command -v bw &> /dev/null; then
              eval "$(bw completion --shell zsh)"
            fi

            # rbw aliases if using rbw instead of bw
            if command -v rbw &> /dev/null && ! command -v bw &> /dev/null; then
              alias bw="rbw"
              alias bwl="rbw login"
              alias bwu="rbw unlock"
              alias bws="rbw sync"
              alias bwg="rbw get"
              alias bwp="rbw get --field password"
            fi

            ${lib.optionalString cfg.aliases.enable ''
              # Bitwarden aliases
              alias bwl="${cfg.aliases.bwl}"
              alias bwu="${cfg.aliases.bwu}"
              alias bws="${cfg.aliases.bws}"
              alias bwg="${cfg.aliases.bwg}"
              alias bwp="${cfg.aliases.bwp}"
              alias bwc="${cfg.aliases.bwc}"
            ''}
          '';
        };

      "bitwarden-cli/bash-integration.sh" =
        lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableBashIntegration)
        {
          text = ''
            # Bitwarden CLI session management
            export BW_SESSION=""

            # Function to unlock Bitwarden and export session
            bw-unlock() {
              export BW_SESSION=$(bw unlock --raw)
              echo "Bitwarden vault unlocked for this session"
            }

            # Function to lock Bitwarden
            bw-lock() {
              bw lock
              unset BW_SESSION
              echo "Bitwarden vault locked"
            }

            # Auto-completion for Bitwarden CLI
            if command -v bw &> /dev/null; then
              eval "$(bw completion --shell bash)"
            fi

            # rbw aliases if using rbw instead of bw
            if command -v rbw &> /dev/null && ! command -v bw &> /dev/null; then
              alias bw="rbw"
              alias bwl="rbw login"
              alias bwu="rbw unlock"
              alias bws="rbw sync"
              alias bwg="rbw get"
              alias bwp="rbw get --field password"
            fi

            ${lib.optionalString cfg.aliases.enable ''
              # Bitwarden aliases
              alias bwl="${cfg.aliases.bwl}"
              alias bwu="${cfg.aliases.bwu}"
              alias bws="${cfg.aliases.bws}"
              alias bwg="${cfg.aliases.bwg}"
              alias bwp="${cfg.aliases.bwp}"
              alias bwc="${cfg.aliases.bwc}"
            ''}
          '';
        };

      "bitwarden-cli/fish-integration.fish" =
        lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableFishIntegration)
        {
          text = ''
            # Bitwarden CLI session management
            set -gx BW_SESSION ""

            # Function to unlock Bitwarden and export session
            function bw-unlock
              set -gx BW_SESSION (bw unlock --raw)
              echo "Bitwarden vault unlocked for this session"
            end

            # Function to lock Bitwarden
            function bw-lock
              bw lock
              set -e BW_SESSION
              echo "Bitwarden vault locked"
            end

            # rbw helper functions
            function rbw-login-apikey
              ${lib.optionalString cfg.settings.apiKey.useSops ''
              if test -f "${clientIdPath}" -a \
                      -f "${clientSecretPath}"
                set -gx BW_CLIENTID (cat "${clientIdPath}")
                set -gx BW_CLIENTSECRET (cat "${clientSecretPath}")
                rbw login
            ''}
              ${lib.optionalString (!cfg.settings.apiKey.useSops) ''
              if test -f "$XDG_CONFIG_HOME/rbw/apikey"
                source "$XDG_CONFIG_HOME/rbw/apikey"
                set -gx BW_CLIENTID $BW_CLIENTID
                set -gx BW_CLIENTSECRET $BW_CLIENTSECRET
                rbw login
            ''}
              else
                echo "API key not configured. Use 'rbw login' for password login."
                echo "To configure: Add bitwarden_api_client_id and bitwarden_api_client_secret to your sops secrets"
              end
            end

            # Auto-completion for Bitwarden CLI
            if command -v bw &> /dev/null
              bw completion --shell fish | source
            end

            # rbw aliases if using rbw instead of bw
            if command -v rbw &> /dev/null; and not command -v bw &> /dev/null
              alias bw="rbw"
              alias bwl="rbw login"
              alias bwu="rbw unlock"
              alias bws="rbw sync"
              alias bwg="rbw get"
              alias bwp="rbw get --field password"
            end

            ${lib.optionalString cfg.aliases.enable ''
              # Bitwarden aliases
              alias bwl="${cfg.aliases.bwl}"
              alias bwu="${cfg.aliases.bwu}"
              alias bws="${cfg.aliases.bws}"
              alias bwg="${cfg.aliases.bwg}"
              alias bwp="${cfg.aliases.bwp}"
              alias bwc="${cfg.aliases.bwc}"
            ''}
          '';
        };
    };

    programs = {
      # Add sourcing instructions to shell configs
      zsh = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableZshIntegration) {
        initContent = ''
          # Source Bitwarden CLI integration
          [[ -f "$XDG_CONFIG_HOME/bitwarden-cli/zsh-integration.sh" ]] && source "$XDG_CONFIG_HOME/bitwarden-cli/zsh-integration.sh"
        '';
      };

      bash = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableBashIntegration) {
        initExtra = ''
          # Source Bitwarden CLI integration
          [[ -f "$XDG_CONFIG_HOME/bitwarden-cli/bash-integration.sh" ]] && source "$XDG_CONFIG_HOME/bitwarden-cli/bash-integration.sh"
        '';
      };

      fish = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableFishIntegration) {
        interactiveShellInit = ''
          # Source Bitwarden CLI integration
          if test -f "$XDG_CONFIG_HOME/bitwarden-cli/fish-integration.fish"
            source "$XDG_CONFIG_HOME/bitwarden-cli/fish-integration.fish"
          end
        '';
      };

      # Configure rbw if enabled
      rbw = lib.mkIf cfg.rbw.enable {
        enable = true;
        inherit (cfg.rbw) package;
        settings = {
          email = config.aytordev.user.email;
          base_url = cfg.settings.server;
          inherit (cfg.rbw) pinentry;
          sync_interval = 3600;
        };
      };
    };
  };
}
