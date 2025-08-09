{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.applications.terminal.tools.bitwarden-cli;
in {
  options.applications.terminal.tools.bitwarden-cli = {
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
          Custom Bitwarden server URL. Leave null to use the official Bitwarden server.
        '';
      };

      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/run/secrets/bitwarden-api-key";
        description = ''
          Path to a file containing the Bitwarden API key for automated operations.
          The file should contain CLIENT_ID and CLIENT_SECRET separated by a newline.
        '';
      };

      apiKey = {
        useSops = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Use sops-nix to securely manage Bitwarden API keys.
            When enabled, expects secrets at:
            - bitwarden_api_client_id
            - bitwarden_api_client_secret
          '';
        };

        clientIdPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/run/secrets/bitwarden_api_client_id";
          description = ''
            Path to the file containing the Bitwarden API client ID.
            Automatically set when using sops-nix.
          '';
        };

        clientSecretPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/run/secrets/bitwarden_api_client_secret";
          description = ''
            Path to the file containing the Bitwarden API client secret.
            Automatically set when using sops-nix.
          '';
        };

        clientId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
          description = ''
            Bitwarden API client ID (for non-sops configurations).
            Get this from vault.bitwarden.com > Account Settings > Security > API Key.
            Prefer using sops-nix for security.
          '';
        };

        clientSecret = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx";
          description = ''
            Bitwarden API client secret (for non-sops configurations).
            Get this from vault.bitwarden.com > Account Settings > Security > API Key.
            Prefer using sops-nix for security.
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

      syncOnLogin = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Automatically sync vault on login.
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
        default = config.applications.terminal.shells.zsh.enable or false;
        description = ''
          Enable Zsh integration for Bitwarden CLI.
        '';
      };

      enableBashIntegration = lib.mkOption {
        type = lib.types.bool;
        default = config.applications.terminal.shells.bash.enable or false;
        description = ''
          Enable Bash integration for Bitwarden CLI.
        '';
      };

      enableFishIntegration = lib.mkOption {
        type = lib.types.bool;
        default = config.applications.terminal.shells.fish.enable or false;
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
        default = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
        example = lib.literalExpression "pkgs.pinentry-curses";
        description = ''
          Pinentry program to use for password prompts.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Only install bitwarden-cli package if rbw is not enabled (to avoid broken package)
    # rbw can be used as a standalone alternative
    home.packages = lib.optionals (!cfg.rbw.enable) [cfg.package] 
                    ++ lib.optionals cfg.rbw.enable [
                      cfg.rbw.package
                      cfg.rbw.pinentry
                    ];

    # Configure Bitwarden CLI settings
    home.sessionVariables = lib.mkMerge [
      (lib.mkIf (cfg.settings.server != null) {
        BW_CLIENTSECRET = cfg.settings.server;
      })
      {
        BW_SESSION_TIMEOUT = toString cfg.settings.sessionTimeout;
      }
    ];

    # Shell integration scripts
    home.file.".config/bitwarden-cli/zsh-integration.sh" = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableZshIntegration) {
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
          if [[ -f "${cfg.settings.apiKey.clientIdPath or "/run/user/$UID/secrets/bitwarden_api_client_id"}" ]] && \
             [[ -f "${cfg.settings.apiKey.clientSecretPath or "/run/user/$UID/secrets/bitwarden_api_client_secret"}" ]]; then
            BW_CLIENTID=$(cat "${cfg.settings.apiKey.clientIdPath or "/run/user/$UID/secrets/bitwarden_api_client_id"}")
            BW_CLIENTSECRET=$(cat "${cfg.settings.apiKey.clientSecretPath or "/run/user/$UID/secrets/bitwarden_api_client_secret"}")
            echo "$BW_CLIENTSECRET" | rbw login --apikey "$BW_CLIENTID"
          ''} 
          ${lib.optionalString (!cfg.settings.apiKey.useSops) ''
          if [[ -f "$HOME/.config/rbw/apikey" ]]; then
            source "$HOME/.config/rbw/apikey"
            echo "$BW_CLIENTSECRET" | rbw login --apikey "$BW_CLIENTID"
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

    home.file.".config/bitwarden-cli/bash-integration.sh" = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableBashIntegration) {
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

    home.file.".config/bitwarden-cli/fish-integration.fish" = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableFishIntegration) {
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
          if test -f "${cfg.settings.apiKey.clientIdPath or "/run/user/$UID/secrets/bitwarden_api_client_id"}" -a \
                  -f "${cfg.settings.apiKey.clientSecretPath or "/run/user/$UID/secrets/bitwarden_api_client_secret"}"
            set BW_CLIENTID (cat "${cfg.settings.apiKey.clientIdPath or "/run/user/$UID/secrets/bitwarden_api_client_id"}")
            set BW_CLIENTSECRET (cat "${cfg.settings.apiKey.clientSecretPath or "/run/user/$UID/secrets/bitwarden_api_client_secret"}")
            echo "$BW_CLIENTSECRET" | rbw login --apikey "$BW_CLIENTID"
          ''}
          ${lib.optionalString (!cfg.settings.apiKey.useSops) ''
          if test -f "$HOME/.config/rbw/apikey"
            source "$HOME/.config/rbw/apikey"
            echo "$BW_CLIENTSECRET" | rbw login --apikey "$BW_CLIENTID"
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

    # Add sourcing instructions to shell configs
    programs.zsh = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableZshIntegration) {
      initExtra = ''
        # Source Bitwarden CLI integration
        [[ -f "$HOME/.config/bitwarden-cli/zsh-integration.sh" ]] && source "$HOME/.config/bitwarden-cli/zsh-integration.sh"
      '';
    };

    programs.bash = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableBashIntegration) {
      initExtra = ''
        # Source Bitwarden CLI integration
        [[ -f "$HOME/.config/bitwarden-cli/bash-integration.sh" ]] && source "$HOME/.config/bitwarden-cli/bash-integration.sh"
      '';
    };

    programs.fish = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableFishIntegration) {
      interactiveShellInit = ''
        # Source Bitwarden CLI integration
        if test -f "$HOME/.config/bitwarden-cli/fish-integration.fish"
          source "$HOME/.config/bitwarden-cli/fish-integration.fish"
        end
      '';
    };

    # Configure rbw if enabled
    programs.rbw = lib.mkIf cfg.rbw.enable {
      enable = true;
      package = cfg.rbw.package;
      settings = {
        email = inputs.secrets.useremail or "";
        base_url = cfg.settings.server;
        pinentry = cfg.rbw.pinentry;
        sync_interval = 3600;
      };
    };

    # Create API key file if credentials are provided (non-sops mode)
    home.file.".config/rbw/apikey" = lib.mkIf (!cfg.settings.apiKey.useSops && cfg.settings.apiKey.clientId != null && cfg.settings.apiKey.clientSecret != null) {
      text = ''
        BW_CLIENTID="${cfg.settings.apiKey.clientId}"
        BW_CLIENTSECRET="${cfg.settings.apiKey.clientSecret}"
      '';
      mode = "0600";
    };

    # Create a helper script for sops-based API key usage
    home.file.".local/bin/rbw-unlock-sops" = lib.mkIf cfg.settings.apiKey.useSops {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Helper script to unlock rbw using sops-managed API keys
        
        CLIENT_ID_PATH="${cfg.settings.apiKey.clientIdPath or "/run/user/$UID/secrets/bitwarden_api_client_id"}"
        CLIENT_SECRET_PATH="${cfg.settings.apiKey.clientSecretPath or "/run/user/$UID/secrets/bitwarden_api_client_secret"}"
        
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
        
        echo "$CLIENT_SECRET" | rbw login --apikey "$CLIENT_ID"
      '';
    };

    # Create helper scripts
    home.file.".local/bin/bw-session" = lib.mkIf cfg.shellIntegration.enable {
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
}