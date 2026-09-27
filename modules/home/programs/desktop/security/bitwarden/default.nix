{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.desktop.security.bitwarden;
  settingsFile = {
    text = builtins.toJSON (
      cfg.settings
      // {
        inherit (cfg) enableBrowserIntegration;
        enableTray = cfg.enableTrayIcon;
        enableMinimizeToTray = cfg.enableTrayIcon;
        openAtLogin = cfg.enableSystemStartup;
        biometricUnlock = cfg.biometricUnlock.enable;
        biometricRequirePasswordOnStart = cfg.biometricUnlock.requirePasswordOnStart;
        vaultTimeout = cfg.vault.timeout;
        vaultTimeoutAction = cfg.vault.timeoutAction;
      }
    );
  };
  # `data.json` is Bitwarden's mutable `electron-store` state file: it carries
  # `stateVersion`, window geometry and cached server feature flags alongside
  # the desktop settings, and the application rewrites it on every launch.
  # Home Manager can only symlink a store path into place and store paths are
  # read-only, so owning that path makes the startup migration fail with
  # `EACCES`; the main process then stays alive without a window and swallows
  # every later launch.
  #
  # The rendered settings are therefore published as a read-only seed, and
  # activation copies it into place only while the application does not own the
  # file yet. From then on Bitwarden owns it: `settings` are first-run defaults,
  # not enforced state.
  seedPath = ".local/share/aytordev/bitwarden-desktop/data.json";
  statePath =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Bitwarden/data.json"
    else "${config.xdg.configHome}/Bitwarden/data.json";
  bitwardenExecutable =
    if cfg.installPackage
    then "${cfg.package}/programs/Bitwarden.app/Contents/MacOS/Bitwarden"
    else "/Applications/Bitwarden.app/Contents/MacOS/Bitwarden";
in {
  options.aytordev.programs.desktop.security.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden password manager desktop application";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bitwarden-desktop;
      defaultText = lib.literalExpression "pkgs.bitwarden-desktop";
      description = "The Bitwarden package to install.";
    };

    installPackage = lib.mkOption {
      type = lib.types.bool;
      default = !pkgs.stdenv.hostPlatform.isDarwin;
      defaultText = lib.literalExpression "!pkgs.stdenv.hostPlatform.isDarwin";
      description = ''
        Install the Bitwarden package via Home Manager.
        On Darwin, the desktop app is managed as a Homebrew cask to avoid
        nixpkgs Electron/native-linker build failures.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      example = lib.literalExpression ''
        {
          theme = "dark";
          minimizeToTray = true;
          startToTray = false;
          enableBrowserIntegration = true;
          alwaysShowDock = false;
        }
      '';
      description = ''
        Configuration settings for Bitwarden desktop application.
        These are first-run defaults: activation seeds them into the
        application's data.json only while Bitwarden does not own that file
        yet. Afterwards the application owns the file and these settings are
        not re-applied.
      '';
    };

    enableBrowserIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable browser integration for auto-fill functionality.
        This allows Bitwarden to communicate with browser extensions.
      '';
    };

    enableSystemStartup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Start Bitwarden automatically when the system starts.
      '';
    };

    enableTrayIcon = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Show Bitwarden in the system tray/menu bar.
      '';
    };

    biometricUnlock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable biometric unlock (Touch ID on macOS).
        '';
      };

      requirePasswordOnStart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Require master password on application start even when biometric unlock is enabled.
        '';
      };
    };

    vault = {
      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = 15;
        example = 30;
        description = ''
          Vault timeout in minutes. Set to null to never timeout.
        '';
      };

      timeoutAction = lib.mkOption {
        type = lib.types.enum [
          "lock"
          "logout"
        ];
        default = "lock";
        description = ''
          Action to take when vault times out.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = lib.optional cfg.installPackage cfg.package;

      file."${seedPath}" = settingsFile;

      activation.bitwardenStateFile = lib.hm.dag.entryAfter ["writeBoundary"] ''
        stateFile="${statePath}"
        seedFile="$HOME/${seedPath}"
        if [ -L "$stateFile" ] || [ ! -e "$stateFile" ]; then
          $DRY_RUN_CMD rm -f "$stateFile"
          $DRY_RUN_CMD mkdir -p "$(dirname "$stateFile")"
          $DRY_RUN_CMD install -m 600 "$seedFile" "$stateFile"
        fi
      '';
    };

    launchd.agents = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.enableSystemStartup) {
      bitwarden = {
        enable = true;
        config = {
          ProgramArguments = [bitwardenExecutable];
          RunAtLoad = true;
          KeepAlive = false;
          ProcessType = "Interactive";
          StandardOutPath = "/tmp/bitwarden.out.log";
          StandardErrorPath = "/tmp/bitwarden.err.log";
        };
      };
    };
  };
}
