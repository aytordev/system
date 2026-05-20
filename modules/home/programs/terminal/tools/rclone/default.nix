{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.rclone;
in {
  options.aytordev.programs.terminal.tools.rclone = {
    enable = mkEnableOption "rclone";

    remotes = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      example = lib.literalExpression ''
        {
          portfolio-b2 = {
            config = {type = "b2";};
            secrets = {
              account = "/path/to/b2_key_id";
              key = "/path/to/b2_app_key";
            };
          };
        }
      '';
      description = ''
        Rclone remote configurations. Passed through to home-manager's
        programs.rclone.remotes. See <https://rclone.org/docs/>.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.rclone = {
      enable = true;
      package = pkgs.rclone;
      inherit (cfg) remotes;
    };
  };
}
