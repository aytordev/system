{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.zoxide;
in {
  options.aytordev.programs.terminal.tools.zoxide = {
    enable = mkEnableOption "zoxide, a smarter cd command";
    package = mkPackageOption pkgs "zoxide" {};
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package];
      sessionVariables = {
        _ZO_DATA_DIR = "${config.xdg.dataHome}/zoxide";
      };
      activation.createZoxideDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/zoxide"
        $DRY_RUN_CMD chmod 700 "${config.xdg.dataHome}/zoxide"
      '';
    };

    # Upstream programs.zoxide owns every shell's init (initExtra,
    # initContent, interactiveShellInit, extraConfig). No manual fragments;
    # it exposes enable*Integration for bash, zsh, fish and nushell, so the
    # flags merge is safe here (unlike eza, which must exclude nushell).
    programs.zoxide =
      {
        enable = true;
        inherit (cfg) package;
        options = [
          "--cmd cd"
          "--no-aliases"
        ];
      }
      // (lib.aytordev.shellIntegration config).flags;
  };
}
