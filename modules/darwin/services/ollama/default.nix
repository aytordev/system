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

  # Wrapper script that waits for Nix store mount before starting ollama.
  # Without this, the launchd agent can crash-loop on boot if it fires
  # before the Nix store FUSE mount is ready.
  ollamaServe = pkgs.writeShellScript "ollama-serve" ''
    /bin/wait4path "${cfg.package}/bin/ollama"
    mkdir -p "${logDir}"
    exec "${cfg.package}/bin/ollama" serve
  '';

  accelerationEnv =
    if cfg.acceleration == "none"
    then {OLLAMA_LLM_LIBRARY = "cpu";}
    else {};
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
      description = "GPU acceleration backend. 'metal' uses Apple GPU (default on Apple Silicon), 'none' forces CPU-only.";
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
      command = "${ollamaServe}";
      serviceConfig = {
        # Only restart on non-zero exit (crash), not on clean shutdown.
        # Prevents infinite crash loops that consume all memory on boot.
        KeepAlive = {SuccessfulExit = false;};
        RunAtLoad = false;
        # Wait 30s between restarts to avoid rapid crash loops that
        # saturate memory and swap, blocking the system.
        ThrottleInterval = 30;
        # Lower scheduling priority so a crash loop can't starve the UI
        ProcessType = "Background";
        StandardOutPath = "${logDir}/ollama.out.log";
        StandardErrorPath = "${logDir}/ollama.err.log";
        EnvironmentVariables =
          {
            OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
            OLLAMA_ORIGINS = "*";
            # XDG-compliant model storage
            OLLAMA_MODELS = "${userHome}/.local/share/ollama/models";

            # Prevent VRAM-based auto-scaling of context (default: 0 = auto)
            # Without this, Ollama sees ~78 GiB and inflates to 262K context,
            # wasting ~25 GB on KV cache beyond model training limits
            OLLAMA_CONTEXT_LENGTH = "32768";
            # Flash Attention: reduces KV cache memory, improves throughput
            OLLAMA_FLASH_ATTENTION = "1";
            # Quantized KV cache: significant memory savings, negligible quality loss
            OLLAMA_KV_CACHE_TYPE = "q8_0";
            # Parallel request handling
            OLLAMA_NUM_PARALLEL = "2";
            # Keep multiple models loaded simultaneously
            OLLAMA_MAX_LOADED_MODELS = "3";
            # Auto-unload models after 30 min of inactivity to free memory
            OLLAMA_KEEP_ALIVE = "30m";
          }
          // accelerationEnv
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
