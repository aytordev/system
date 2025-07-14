{
  config,
  lib,
  ...
}: {
  options = {
    home = {
      enable =
        lib.mkEnableOption "home configuration"
        // {
          description = ''
            Whether to enable home configuration management.
            When enabled, manages user configuration files and XDG configs.
          '';
        };
      files = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.path;
              description = "Source path for the file";
              example = "./path/to/file";
            };
          };
        });
        default = {};
        description = "Files to manage in the home directory";
      };
      configs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            text = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "File content as text";
              example = "key = value\n";
            };
            source = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Source path for the file (alternative to text)";
              example = "./path/to/config";
            };
          };
        });
        default = {};
        description = "Files to manage in XDG config directory";
      };
    };
  };
  config = lib.mkIf config.home.enable (lib.mkMerge [
    {xdg.enable = true;}
    (lib.mkIf (config.home.files != {}) {
      home.file =
        lib.mapAttrs' (
          name: value:
            lib.nameValuePair name {inherit (value) source;}
        )
        config.home.files;
    })
    (lib.mkIf (config.home.configs != {}) {
      xdg.configFile =
        lib.mapAttrs' (
          name: value:
            lib.nameValuePair name (
              if value.source != null
              then {source = value.source;}
              else {text = value.text;}
            )
        )
        config.home.configs;
    })
  ]);
}
