{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.applications.desktop.browsers.firefox;
in {
  options.aytordev.applications.desktop.browsers.firefox = {
    enable = mkEnableOption "Whether or not to enable Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;

        extensions = [
          # Extensions can be installed manually from the Firefox Add-ons store
          # Common privacy extensions:
          # - uBlock Origin
          # - Privacy Badger
          # - Bitwarden
          # - ClearURLs
          # - Decentraleyes
        ];

        settings = {
          # Privacy and Security
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.downloads" = false;

          # Disable telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # Performance
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.enabled" = true;
          "layers.acceleration.force-enabled" = true;

          # UI preferences
          "browser.tabs.warnOnClose" = false;
          "browser.tabs.warnOnCloseOtherTabs" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "about:home";
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;

          # Downloads
          "browser.download.useDownloadDir" = false;
          "browser.download.dir" = "/Users/${config.aytordev.user.name}/Downloads";

          # Search
          "browser.search.suggest.enabled" = true;
          "browser.urlbar.suggest.searches" = true;
          "browser.urlbar.showSearchSuggestionsFirst" = false;

          # Security
          "security.tls.version.min" = 3;
          "network.security.esni.enabled" = true;
          "network.dns.disableIPv6" = false;

          # Disable pocket
          "extensions.pocket.enabled" = false;
          "extensions.pocket.showHome" = false;
          "extensions.pocket.onSaveRecs" = false;

          # Disable Firefox accounts
          "identity.fxaccounts.enabled" = false;

          # Disable location services
          "geo.enabled" = false;
          "geo.provider.network.url" = "";

          # Disable WebRTC
          "media.peerconnection.enabled" = false;
          "media.peerconnection.turn.disable" = true;
          "media.peerconnection.use_document_iceservers" = false;
          "media.peerconnection.video.enabled" = false;
          "media.peerconnection.identity.timeout" = 1;

          # Font rendering
          "gfx.font_rendering.cleartype_params.rendering_mode" = 5;
          "gfx.font_rendering.cleartype_params.cleartype_level" = 100;
          "gfx.font_rendering.cleartype_params.force_gdi_classic_for_families" = "";
          "gfx.font_rendering.cleartype_params.force_gdi_classic_max_size" = 6;
          "gfx.font_rendering.directwrite.use_gdi_table_loading" = false;
        };

        userChrome = ''
          /* Hide tab bar when only one tab is open */
          #tabbrowser-tabs[tabscount="1"] {
            visibility: collapse !important;
          }

          /* Compact UI */
          :root {
            --tab-min-height: 32px !important;
            --toolbarbutton-border-radius: 3px !important;
          }
        '';

        userContent = ''
          /* Dark theme for websites that don't have one */
          @-moz-document url-prefix("about:") {
            * {
              scrollbar-width: thin;
            }
          }
        '';
      };

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
      };
    };
  };
}
