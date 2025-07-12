{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkBefore;
  cfg = config.applications.terminal.tools.zoxide;
in {
  options.applications.terminal.tools.zoxide = {
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

    # Configuración para asegurar el cumplimiento con XDG
    home.sessionVariables = {
      _ZO_DATA_DIR = "${config.xdg.dataHome}/zoxide";
    };

    # Asegurar que el directorio de datos existe
    home.activation.createZoxideDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.xdg.dataHome}/zoxide"
    '';

    programs.zoxide = {
      enable = true;
      package = cfg.package;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      options = [
        "--cmd cd"
        "--no-aliases" # Evita crear alias globales, mejor para el control
      ];
    };

    # Configuración adicional para shells
    home.file.".config/bash/conf.d/tools/13-zoxide.sh" = lib.mkIf config.applications.terminal.shells.bash.enable {
      text = ''
        eval "$(${cfg.package}/bin/zoxide init --cmd cd bash)"
      '';
    };

    programs.zsh.initContent = mkBefore ''
      eval "$(${cfg.package}/bin/zoxide init --cmd cd zsh)"
    '';

    programs.fish.shellInit = mkBefore ''
      ${cfg.package}/bin/zoxide init --cmd cd fish | source
    '';
  };
}
