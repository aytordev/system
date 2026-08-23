{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.litellm;

  configDir = "${config.xdg.configHome}/litellm";
  configFile = "${configDir}/config.yaml";
  environmentNames = builtins.attrNames cfg.environmentFiles;
  validEnvironmentName = name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null;
  startPackage = import ./start.nix {
    inherit
      cfg
      configFile
      lib
      pkgs
      ;
  };

  proxyConfig = {
    model_list =
      map (m: {
        model_name = m.modelName;
        litellm_params =
          {
            inherit (m) model;
            api_base = m.apiBase;
          }
          // m.extraParams;
      })
      cfg.models;

    litellm_settings =
      {
        drop_params = true;
        telemetry = false;
      }
      // cfg.settings;
  };
in {
  imports = [./service.nix];

  options.aytordev.programs.terminal.tools.litellm = {
    enable = mkEnableOption "LiteLLM unified proxy for LLM model routing";

    package = mkOption {
      type = types.package;
      default = pkgs.litellm;
      description = "The LiteLLM package to use";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "LiteLLM proxy bind address";
    };

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "LiteLLM proxy listen port";
    };

    models = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            modelName = mkOption {
              type = types.str;
              description = "Virtual model name exposed by the proxy";
            };
            model = mkOption {
              type = types.str;
              description = "Underlying model identifier (e.g. ollama/qwen2.5-coder:32b)";
            };
            apiBase = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "API base URL for the model provider";
            };
            extraParams = mkOption {
              type = types.attrsOf types.anything;
              default = {};
              description = "Additional litellm_params for this model";
            };
          };
        }
      );
      default = [
        {
          modelName = "local-coder";
          model = "ollama/qwen2.5-coder:32b";
          apiBase = "http://127.0.0.1:11434";
        }
        {
          modelName = "local-fast";
          model = "ollama/qwen3:30b-a3b";
          apiBase = "http://127.0.0.1:11434";
        }
      ];
      description = "Model routing definitions for the LiteLLM proxy";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Additional litellm_settings merged into the proxy config";
    };

    environmentFiles = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example.OPENAI_API_KEY = "/run/secrets/openai-api-key";
      description = "Environment variable names mapped to runtime secret files";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for LiteLLM";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.all validEnvironmentName environmentNames;
        message = "LiteLLM environment file names must be valid environment variable names";
      }
    ];

    home = {
      packages = [
        cfg.package
        startPackage
      ];

      sessionVariables = {
        LITELLM_CONFIG = "${configDir}/config.yaml";
        LITELLM_HOST = cfg.host;
        LITELLM_PORT = toString cfg.port;
      };

      shellAliases = mkIf cfg.shellAliases {
        litellm-models = "curl -s http://${cfg.host}:${toString cfg.port}/v1/models | python3 -m json.tool";
        litellm-health = "curl -s http://${cfg.host}:${toString cfg.port}/health";
      };
    };

    # XDG-compliant configuration
    xdg.configFile."litellm/config.yaml".text = lib.generators.toYAML {} proxyConfig;
  };
}
