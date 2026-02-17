{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.aytordev.programs.terminal.tools.aider;

  configDir = "${config.xdg.configHome}/aider";

  aiderConfig = {
    model = cfg.defaultModel;
    edit-format = "diff";
    auto-commits = true;
    auto-lint = true;
    dark-mode = true;
    analytics-disable = true;
    lint-cmd = cfg.lintCommands;
  };

  modelSettings =
    map (m: {
      inherit (m) name;
      edit_format = m.editFormat;
      use_repo_map = m.useRepoMap;
      extra_params = m.extraParams;
    })
    cfg.modelSettings;
in {
  options.aytordev.programs.terminal.tools.aider = {
    enable = mkEnableOption "Aider AI pair programming assistant";

    package = mkOption {
      type = types.package;
      default = pkgs.aider-chat;
      description = "The Aider package to use";
    };

    defaultModel = mkOption {
      type = types.str;
      default = "anthropic/claude-sonnet-4-5-20250929";
      description = "Default model for Aider to use";
    };

    lintCommands = mkOption {
      type = types.listOf types.str;
      default = [
        "typescript: npx eslint --fix"
        "javascript: npx eslint --fix"
      ];
      description = "Lint commands per language";
    };

    modelSettings = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Model name (e.g. ollama_chat/qwen2.5-coder:32b)";
          };
          editFormat = mkOption {
            type = types.str;
            default = "diff";
            description = "Edit format for the model";
          };
          useRepoMap = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to use repository map";
          };
          extraParams = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            description = "Extra parameters for the model";
          };
        };
      });
      default = [
        {
          name = "ollama_chat/qwen2.5-coder:32b";
          editFormat = "diff";
          useRepoMap = true;
          extraParams.num_ctx = 32768;
        }
        {
          name = "ollama_chat/qwen3:30b-a3b";
          editFormat = "diff";
          useRepoMap = true;
          extraParams.num_ctx = 65536;
        }
      ];
      description = "Model-specific settings for Aider";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for Aider";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package];

      sessionVariables = {
        AIDER_CONFIG = "${configDir}/aider.conf.yml";
        AIDER_MODEL_SETTINGS_FILE = "${configDir}/aider.model.settings.yml";
      };

      shellAliases = mkIf cfg.shellAliases {
        aider-local = "aider --model ollama_chat/qwen2.5-coder:32b";
        aider-fast = "aider --model ollama_chat/qwen3:30b-a3b";
      };
    };

    # XDG-compliant configuration
    xdg.configFile."aider/aider.conf.yml".text =
      lib.generators.toYAML {} aiderConfig;

    xdg.configFile."aider/aider.model.settings.yml".text =
      lib.generators.toYAML {} modelSettings;
  };
}
