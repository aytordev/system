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
        These settings will be written to the Bitwarden data directory.
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
    home.packages = lib.optional cfg.installPackage cfg.package;

    home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "Library/Application Support/Bitwarden/data.json" = settingsFile;
    };

    xdg.configFile = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      "Bitwarden/data.json" = settingsFile;
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
