{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.ollama;
  serviceCfg = cfg.service;
  logDir = "${config.xdg.stateHome}/ollama";
  accelerationEnvironment =
    if cfg.acceleration == "none"
    then {OLLAMA_LLM_LIBRARY = "cpu";}
    else {};
  baseEnvironment =
    {
      OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
      OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";
    }
    // accelerationEnvironment
    // cfg.environmentVariables;
  darwinEnvironment =
    {
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_NUM_PARALLEL = "2";
      OLLAMA_MAX_LOADED_MODELS = "3";
      OLLAMA_KEEP_ALIVE = "30m";
    }
    // baseEnvironment;
  environmentList = lib.mapAttrsToList (name: value: "${name}=${value}") baseEnvironment;
  inherit (config._module.args.ollamaUtils) createModelPullScript;
  startScript = pkgs.writeShellScript "ollama-service" ''
    set -euo pipefail
    /bin/wait4path ${lib.escapeShellArg (lib.getExe cfg.package)}

    ${lib.getExe cfg.package} serve &
    server_pid=$!
    trap 'kill "$server_pid" 2>/dev/null || true' EXIT INT TERM
    ${lib.optionalString (cfg.models != []) "${lib.getExe createModelPullScript}"}
    wait "$server_pid"
    trap - EXIT
  '';
  rotateLogs = pkgs.writeShellScript "ollama-log-rotate" ''
    set -euo pipefail
    for log in ${
      lib.escapeShellArgs [
        "${logDir}/ollama.out.log"
        "${logDir}/ollama.err.log"
      ]
    }; do
      if [[ -f "$log" ]] && [[ "$(/usr/bin/stat -f %z "$log")" -gt 5242880 ]]; then
        /bin/cp "$log" "$log.1"
        : > "$log"
      fi
    done
  '';
in {
  options.aytordev.programs.terminal.tools.ollama.service = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isLinux;
      description = "Run Ollama as a user service.";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isLinux;
      description = "Start Ollama automatically with the user session.";
    };
  };

  config = lib.mkIf (cfg.enable && serviceCfg.enable) (
    lib.mkMerge [
      {
        home.activation.createOllamaDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD mkdir -p \
            ${lib.escapeShellArg "${config.xdg.dataHome}/ollama/models"} \
            ${lib.escapeShellArg logDir}
        '';
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.services.ollama = {
          Unit = {
            Description = "Ollama - Local Large Language Model Runner";
            Documentation = "https://github.com/ollama/ollama";
            After = ["network-online.target"];
            Wants = ["network-online.target"];
          };
          Service = {
            Type = "exec";
            TimeoutStartSec = lib.mkIf (cfg.models != []) "infinity";
            ExecStart = "${lib.getExe cfg.package} serve";
            ExecStartPost = lib.mkIf (cfg.models != []) "${lib.getExe createModelPullScript}";
            Environment = ["HOME=%h"] ++ environmentList;
            Restart = "on-failure";
            RestartSec = 5;
            PrivateTmp = true;
            ReadWritePaths = ["%h/.local/share/ollama"];
          };
          Install.WantedBy = lib.mkIf serviceCfg.autoStart ["default.target"];
        };
      })

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        launchd.agents = {
          ollama = {
            enable = true;
            config =
              {
                ProgramArguments = ["${startScript}"];
                RunAtLoad = serviceCfg.autoStart;
                ThrottleInterval = 30;
                ProcessType = "Background";
                StandardOutPath = "${logDir}/ollama.out.log";
                StandardErrorPath = "${logDir}/ollama.err.log";
                EnvironmentVariables = darwinEnvironment;
              }
              // lib.optionalAttrs serviceCfg.autoStart {
                KeepAlive = {
                  SuccessfulExit = false;
                };
              };
          };
          ollama-log-rotation = {
            enable = true;
            config = {
              ProgramArguments = ["${rotateLogs}"];
              StartInterval = 3600;
              ProcessType = "Background";
            };
          };
        };
      })
    ]
  );
}
