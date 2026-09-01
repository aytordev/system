{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.zoxide;
in {
  options.aytordev.programs.terminal.tools.zoxide = {
    enable = mkEnableOption "zoxide, a smarter cd command";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zoxide;
      defaultText = lib.literalExpression "pkgs.zoxide";
      description = "The zoxide package to use.";
    };
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
    # initContent, interactiveShellInit, extraConfig). No manual fragments.
    programs.zoxide = {
      enable = true;
      inherit (cfg) package;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      options = [
        "--cmd cd"
        "--no-aliases"
      ];
    };
  };
}
