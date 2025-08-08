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

  config = {
    # On macOS, install the pre-built app directly
    home.packages = mkIf (cfg.enable && pkgs.stdenv.isDarwin) [
      pkgs.ungoogled-chromium-macos
    ];

    # On Linux, use Home Manager's chromium program
    programs.chromium = mkIf (cfg.enable && !pkgs.stdenv.isDarwin) {
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
        # Disable sync
        "--disable-sync"
        # Disable autofill
        "AutofillPaymentCardBenefits"
        "AutofillPaymentCvcStorage"
        "AutofillPaymentCardBenefits"
      ];

      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
    };
  };
}
