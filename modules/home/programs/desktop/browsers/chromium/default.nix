{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aytordev.programs.desktop.browsers.chromium;
in {
  options.aytordev.programs.desktop.browsers.chromium = {
    enable = mkEnableOption "Whether or not to enable Chromium (ungoogled-chromium)";
    package = lib.mkOption {
      type = lib.types.package;
      default =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ungoogled-chromium-macos
        else pkgs.ungoogled-chromium;
      defaultText = lib.literalExpression ''
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ungoogled-chromium-macos
        else pkgs.ungoogled-chromium
      '';
      description = "Chromium package to use";
    };
  };

  config = {
    # On macOS, install the pre-built app directly
    home.packages = mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) [
      cfg.package
    ];

    # On Linux, use Home Manager's chromium program
    programs.chromium = mkIf (cfg.enable && !pkgs.stdenv.hostPlatform.isDarwin) {
      enable = true;
      inherit (cfg) package;

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
