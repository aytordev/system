{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types optionals;

  cfg = config.aytordev.programs.terminal.tools.ollama;
in {
  options.aytordev.programs.terminal.tools.ollama = {
    enable = mkEnableOption "Ollama - Run large language models locally";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The Ollama package to use";
    };

    acceleration = mkOption {
      type = types.enum [
        "none"
        "metal"
        "cuda"
        "rocm"
      ];
      default =
        if pkgs.stdenv.isDarwin
        then "metal"
        else "none";
      description = "Hardware acceleration backend to use";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Ollama server bind address";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Ollama server port";
    };

    models = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [
        "qwen2.5-coder:32b"
        "qwen3:30b-a3b"
        "nomic-embed-text"
      ];
      description = ''
        List of models to pull automatically.
        Models will be downloaded on first run if not already present.
      '';
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables for the Ollama service";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for Ollama";
    };
  };

  config = mkIf cfg.enable (
    let
      inherit (config._module.args.ollamaUtils) createStatusScript createRestartScript createLogsScript;
    in {
      home = {
        packages =
          [cfg.package]
          ++ optionals cfg.shellAliases [
            createStatusScript
            createRestartScript
            createLogsScript
          ];

        shellAliases = mkIf cfg.shellAliases {
          ollama-models = "ollama list";
          ollama-ps = "ollama ps";
        };

        sessionVariables = {
          OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          OLLAMA_API_BASE = "http://${cfg.host}:${toString cfg.port}";
          OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";
        };
      };
    }
  );
}
