{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkBefore;
  cfg = config.aytordev.applications.terminal.tools.zoxide;
in {
  options.aytordev.applications.terminal.tools.zoxide = {
    enable = mkEnableOption "zoxide, a smarter cd command";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zoxide;
      defaultText = lib.literalExpression "pkgs.zoxide";
      description = "The zoxide package to use.";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    home.sessionVariables = {
      _ZO_DATA_DIR = "${config.xdg.dataHome}/zoxide";
    };
    home.activation.createZoxideDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.xdg.dataHome}/zoxide"
    '';
    applications.zoxide = {
      enable = true;
      package = cfg.package;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      options = [
        "--cmd cd"
        "--no-aliases"
      ];
    };
    home.file.".config/bash/conf.d/tools/zoxide.sh" = lib.mkIf config.aytordev.applications.terminal.shells.bash.enable {
      text = ''
        eval "$(${cfg.package}/bin/zoxide init --cmd cd bash)"
      '';
    };
    applications.zsh.initContent = mkBefore ''
      eval "$(${cfg.package}/bin/zoxide init --cmd cd zsh)"
    '';
    applications.fish.shellInit = mkBefore ''
      ${cfg.package}/bin/zoxide init --cmd cd fish | source
    '';
  };
}
