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
        # Basic flags
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
