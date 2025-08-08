{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.desktop.browsers.chromium;

  # Use overlay version on macOS, nixpkgs version on Linux
  chromiumPackage =
    if pkgs.stdenv.isDarwin
    then pkgs.ungoogled-chromium # From overlay
    else pkgs.ungoogled-chromium; # From nixpkgs
in {
  options.applications.desktop.browsers.chromium = {
    enable = mkEnableOption "Whether or not to enable Chromium (ungoogled-chromium)";
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = chromiumPackage;

      commandLineArgs = [
        # Basic flags for macOS compatibility
        "--no-first-run"
        "--disable-sync"
        "--disable-default-apps"
      ];

      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
        # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      ];
    };
  };
}
