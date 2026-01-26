{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkBefore;
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
        mkdir -p "${config.xdg.dataHome}/zoxide"
      '';
    };

    programs = {
      zoxide = {
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
      zsh.initContent = mkBefore ''
        eval "$(${cfg.package}/bin/zoxide init --cmd cd zsh)"
      '';
      fish.shellInit = mkBefore ''
        ${cfg.package}/bin/zoxide init --cmd cd fish | source
      '';
    };

    xdg.configFile."bash/conf.d/tools/zoxide.sh" = lib.mkIf config.aytordev.programs.terminal.shells.bash.enable {
      text = ''
        eval "$(${cfg.package}/bin/zoxide init --cmd cd bash)"
      '';
    };
    programs.fish.shellInit = mkBefore ''
      ${cfg.package}/bin/zoxide init --cmd cd fish | source
    '';
  };
}
