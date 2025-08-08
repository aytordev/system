{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.desktop.browsers.chromium;
in {
  options.applications.desktop.browsers.chromium = {
    enable = mkEnableOption "Whether or not to enable Chromium (ungoogled-chromium)";
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;

      commandLineArgs = [
        # Performance
        "--gtk-version=4"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-oop-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        # Etc
        "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"
        "--disable-reading-from-canvas"
        "--no-first-run"
        "--disable-wake-on-wifi"
        "--disable-speech-api"
        "--disable-speech-synthesis-api"
        # Use strict extension verification
        "--extension-content-verification=enforce_strict"
        "--extensions-install-verification=enforce_strict"
        # Disable pings
        "--no-pings"
        # Require HTTPS for component updater
        "--component-updater=require_encryption"
        # Disable crash upload
        "--no-crash-upload"
        # don't run things without asking
        "--no-service-autorun"
        # Disable sync (ungoogled-chromium doesn't have Google sync anyway)
        "--disable-sync"
        # Disable autofill features that might phone home
        "--disable-features=AutofillPaymentCardBenefits,AutofillPaymentCvcStorage,AutofillPaymentCardBenefits"
        # Additional privacy flags for ungoogled-chromium
        "--disable-background-networking"
        "--disable-background-timer-throttling"
        "--disable-backgrounding-occluded-windows"
        "--disable-renderer-backgrounding"
        "--disable-features=TranslateUI"
        "--disable-ipc-flooding-protection"
        "--enable-features=VaapiVideoDecoder"
        "--disable-client-side-phishing-detection"
        # Disable Google services
        "--disable-default-apps"
        "--disable-extensions-http-throttling"
        "--disable-plugins-discovery"
      ];

      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
    };
  };
}
