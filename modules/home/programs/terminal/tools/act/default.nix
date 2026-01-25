{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.act;
in {
  options.aytordev.programs.terminal.tools.act = {
    enable = lib.mkEnableOption "act";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.act];

    home.file = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) {
      ".actrc".text =
        /*
        Bash
        */
        ''
          --container-architecture linux/amd64
        '';
    };
  };
}
