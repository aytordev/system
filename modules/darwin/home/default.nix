# Home Manager Module for Darwin
#
# Manages user configuration files and XDG configs for Darwin systems.
# Follows the same pattern as other modules in the codebase.
#
# Version: 1.0.0
# Last Updated: 2025-06-27
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

      # User's home files
      #
      # Example:
      # ```nix
      # {
      #   ".config/nvim/init.vim" = {
      #     source = ./path/to/init.vim;
      #   };
      # }
      #
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

      # User's XDG config files
      #
      # Example:
      # ```nix
      # {
      #   "git/config" = {
      #     text = ''
      #       [user]
      #         name = "User Name"
      #         email = "user@example.com"
      #     '';
      #   };
      # }
      #```
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
    # Enable XDG by default for better organization
    {xdg.enable = true;}

    # Handle home files
    (lib.mkIf (config.home.files != {}) {
      home.file =
        lib.mapAttrs' (
          name: value:
            lib.nameValuePair name {inherit (value) source;}
        )
        config.home.files;
    })

    # Handle XDG config files with either source or text content
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
