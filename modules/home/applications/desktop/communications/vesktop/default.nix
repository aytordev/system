{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  
  cfg = config.applications.desktop.communications.vesktop;

in {
  options.applications.desktop.communications.vesktop = {
    enable = mkEnableOption "Vesktop";
    
    package = mkOption {
      type = types.package;
      default = pkgs.vesktop;
      defaultText = "pkgs.vesktop";
      description = "The Vesktop package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # For backward compatibility with existing configurations
    programs.vesktop = {
      enable = true;
      package = cfg.package;

      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          useQuickCss = true;
          themeLinks = [ ];
          eagerPatches = false;
          enableReactDevtools = true;
          frameless = false;
          transparent = true;
          winCtrlQ = false;
          disableMinSize = true;
          winNativeTitleBar = false;
          
          plugins = {
            CommandsAPI.enabled = true;
            MessageAccessoriesAPI.enabled = true;
            UserSettingsAPI.enabled = true;
            AlwaysAnimate.enabled = true;
            AlwaysExpandRoles.enabled = true;
            AlwaysTrust.enabled = true;
            BetterSessions.enabled = true;
            CrashHandler.enabled = true;
            FixImagesQuality.enabled = true;
            PlatformIndicators.enabled = true;
            ReplyTimestamp.enabled = true;
            ShowHiddenChannels.enabled = true;
            ShowHiddenThings.enabled = true;
            VencordToolbox.enabled = true;
            WebKeybinds.enabled = true;
            WebScreenShareFixes.enabled = true;
            YoutubeAdblock.enabled = true;
            BadgeAPI.enabled = true;
            NoTrack = {
              enabled = true;
              disableAnalytics = true;
            };
            Settings = {
              enabled = true;
              settingsLocation = "aboveNitro";
            };
          };
          
          notifications = {
            timeout = 5000;
            position = "bottom-right";
            useNative = "not-focused";
            logLimit = 50;
          };
        };
      };
    };
  };
}
