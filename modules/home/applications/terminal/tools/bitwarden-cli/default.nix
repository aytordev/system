{
  config,
  lib,
  pkgs,
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
        type = lib.types.str;
        default = if pkgs.stdenv.isDarwin then "pinentry-mac" else "pinentry-gnome3";
        example = "pinentry-curses";
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
                      (if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3)
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

    # Shell integration for Zsh
    programs.zsh = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableZshIntegration) {
      initExtra = ''
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
          eval "$(bw completion --shell zsh)"
        fi
        
        # rbw aliases if using rbw instead of bw
        if command -v rbw &> /dev/null && ! command -v bw &> /dev/null; then
          alias bw="rbw"
          alias bwl="rbw login"
          alias bwu="rbw unlock"
          alias bws="rbw sync"
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

    # Shell integration for Bash
    programs.bash = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableBashIntegration) {
      initExtra = ''
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

    # Shell integration for Fish
    programs.fish = lib.mkIf (cfg.shellIntegration.enable && cfg.shellIntegration.enableFishIntegration) {
      interactiveShellInit = ''
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

    # Configure rbw if enabled
    programs.rbw = lib.mkIf cfg.rbw.enable {
      enable = true;
      package = cfg.rbw.package;
      settings = {
        email = config.user.email or "";
        base_url = cfg.settings.server;
        pinentry = cfg.rbw.pinentry;
        sync_interval = 3600;
      };
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