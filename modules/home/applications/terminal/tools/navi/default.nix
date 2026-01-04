{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.applications.terminal.tools.navi;
  inherit (lib) mkIf;
  defaultStyle = {
    tag = {
      color = "green";
    };
    comment = {
      color = "blue";
    };
    snippet = {
      color = "white";
    };
  };
in {
  options.aytordev.applications.terminal.tools.navi = {
    enable = lib.mkEnableOption "navi";
    settings = {
      style = {
        tag = {
          color = lib.mkOption {
            type = lib.types.str;
            default = defaultStyle.tag.color;
            description = "Color for tag text in navi";
          };
          width_percentage = lib.mkOption {
            type = lib.types.int;
            default = 26;
            description = "Column width relative to terminal window";
          };
          min_width = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "Minimum column width as number of characters";
          };
        };
        comment = {
          color = lib.mkOption {
            type = lib.types.str;
            default = defaultStyle.comment.color;
            description = "Color for comment text in navi";
          };
          width_percentage = lib.mkOption {
            type = lib.types.int;
            default = 42;
            description = "Column width relative to terminal window";
          };
          min_width = lib.mkOption {
            type = lib.types.int;
            default = 45;
            description = "Minimum column width as number of characters";
          };
        };
        snippet = {
          color = lib.mkOption {
            type = lib.types.str;
            default = defaultStyle.snippet.color;
            description = "Color for snippet text in navi";
          };
          width_percentage = lib.mkOption {
            type = lib.types.int;
            default = 42;
            description = "Column width relative to terminal window";
          };
          min_width = lib.mkOption {
            type = lib.types.int;
            default = 45;
            description = "Minimum column width as number of characters";
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    applications.navi = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
