{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.aytordev.services.ollama;
  userHome = config.users.users.${config.aytordev.user.name}.home;
  logDir = "${userHome}/.local/state/ollama";
in {
  options.aytordev.services.ollama = {
    enable = mkEnableOption "Ollama inference server as launchd agent";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The Ollama package to use";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Ollama bind address";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Ollama listen port";
    };

    acceleration = mkOption {
      type = types.enum ["metal" "none"];
      default = "metal";
      description = "GPU acceleration backend";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables for the Ollama service";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    launchd.user.agents.ollama = {
      command = "${cfg.package}/bin/ollama serve";
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${logDir}/ollama.out.log";
        StandardErrorPath = "${logDir}/ollama.err.log";
        EnvironmentVariables =
          {
            OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
            OLLAMA_ORIGINS = "*";
            # XDG-compliant model storage
            OLLAMA_MODELS = "${userHome}/.local/share/ollama/models";

            # Flash Attention: reduces KV cache memory, improves throughput
            OLLAMA_FLASH_ATTENTION = "1";
            # Quantized KV cache: significant memory savings, negligible quality loss
            OLLAMA_KV_CACHE_TYPE = "q8_0";
            # Parallel request handling
            OLLAMA_NUM_PARALLEL = "2";
            # Keep multiple models loaded simultaneously
            OLLAMA_MAX_LOADED_MODELS = "3";
            # Don't auto-unload models (managed via warmup/unload scripts)
            OLLAMA_KEEP_ALIVE = "-1";
          }
          // cfg.environmentVariables;
      };
    };

    # Ensure XDG state directory exists for logs
    system.activationScripts.postActivation.text = lib.mkAfter ''
      mkdir -p "${logDir}"
      chown ${config.aytordev.user.name}:staff "${logDir}"
    '';

    aytordev.system.newsyslog.files.ollama-out = [
      {
        logfilename = "${logDir}/ollama.out.log";
        mode = "644";
        owner = config.aytordev.user.name;
        group = "staff";
        count = 5;
        size = "5120";
        flags = ["Z" "C"];
      }
    ];

    aytordev.system.newsyslog.files.ollama-err = [
      {
        logfilename = "${logDir}/ollama.err.log";
        mode = "644";
        owner = config.aytordev.user.name;
        group = "staff";
        count = 5;
        size = "5120";
        flags = ["Z" "C"];
      }
    ];
  };
}
