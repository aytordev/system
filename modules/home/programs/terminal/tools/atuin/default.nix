{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    mkPackageOption
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.atuin;
in
{
  options.aytordev.programs.terminal.tools.atuin = {
    enable = mkEnableOption "atuin";
    package = mkPackageOption pkgs "atuin" { };
    enableDebug = mkEnableOption "atuin daemon debug logging";
    enableBashIntegration = mkOption {
      type = types.bool;
      default = (lib.aytordev.shellIntegration config).shellEnabled "bash";
      description = "atuin bash integration";
    };
    enableFishIntegration = mkOption {
      type = types.bool;
      default = (lib.aytordev.shellIntegration config).shellEnabled "fish";
      description = "atuin fish integration";
    };
    enableZshIntegration = mkOption {
      type = types.bool;
      default = (lib.aytordev.shellIntegration config).shellEnabled "zsh";
      description = "atuin zsh integration";
    };
    enableNushellIntegration = mkOption {
      type = types.bool;
      default = (lib.aytordev.shellIntegration config).shellEnabled "nushell";
      description = "atuin nushell integration";
    };
  };
  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) enableBashIntegration;
      inherit (cfg) enableFishIntegration;
      inherit (cfg) enableZshIntegration;
      inherit (cfg) enableNushellIntegration;
      daemon = {
        enable = true;
      }
      // optionalAttrs cfg.enableDebug {
        logLevel = "debug";
      };
      settings = {
        enter_accept = true;
        filter_mode = "workspace";
        keymap_mode = "auto";
        show_preview = true;
        style = "auto";
        update_check = false;
        workspaces = true;
        history_filter = [
          "^(sudo reboot)$"
          "^(reboot)$"
        ];
      };
    };
    home.shellAliases = {
      atuin-prune-failed = "atuin search --exclude-exit 0 --delete";
    };
    # atuin writes a plaintext SQLite history database; seal its data dir.
    home.activation.createAtuinDataDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/atuin"
      $DRY_RUN_CMD chmod 700 "${config.xdg.dataHome}/atuin"
    '';
  };
}
