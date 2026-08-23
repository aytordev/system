{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.litellm;
  serviceCfg = cfg.service;
  configFile = "${config.xdg.configHome}/litellm/config.yaml";
  logDir = "${config.xdg.stateHome}/litellm";
  environmentNames = builtins.attrNames cfg.environmentFiles;
  validEnvironmentName = name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null;
  secretExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: file: ''
      if [[ ! -r ${lib.escapeShellArg file} ]]; then
        printf 'LiteLLM secret file is not readable: %s\n' ${lib.escapeShellArg file} >&2
        exit 1
      fi
      export ${name}="$(<${lib.escapeShellArg file})"
    '')
    cfg.environmentFiles
  );
  startScript = pkgs.writeShellScript "litellm-service" ''
    set -euo pipefail
    ${secretExports}
    exec ${lib.getExe cfg.package} \
      --config ${lib.escapeShellArg configFile} \
      --host ${lib.escapeShellArg cfg.host} \
      --port ${toString cfg.port}
  '';
  rotateLogs = pkgs.writeShellScript "litellm-log-rotate" ''
    set -euo pipefail
    for log in ${
      lib.escapeShellArgs [
        "${logDir}/litellm.out.log"
        "${logDir}/litellm.err.log"
      ]
    }; do
      if [[ -f "$log" ]] && [[ "$(/usr/bin/stat -f %z "$log")" -gt 5242880 ]]; then
        /bin/cp "$log" "$log.1"
        : > "$log"
      fi
    done
  '';
in {
  options.aytordev.programs.terminal.tools.litellm.service = {
    enable = lib.mkEnableOption "the LiteLLM proxy as a user service";
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start LiteLLM automatically on login.";
    };
  };

  config = lib.mkIf (cfg.enable && serviceCfg.enable) {
    assertions = [
      {
        assertion = builtins.all validEnvironmentName environmentNames;
        message = "LiteLLM environment file names must be valid environment variable names";
      }
    ];

    home.activation.createLiteLLMStateDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg logDir}
    '';

    systemd.user.services.litellm = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "LiteLLM proxy";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        ExecStart = startScript;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = lib.mkIf serviceCfg.autoStart ["default.target"];
    };

    launchd.agents = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      litellm = {
        enable = true;
        config =
          {
            ProgramArguments = ["${startScript}"];
            RunAtLoad = serviceCfg.autoStart;
            ProcessType = "Background";
            StandardOutPath = "${logDir}/litellm.out.log";
            StandardErrorPath = "${logDir}/litellm.err.log";
            EnvironmentVariables.LITELLM_TELEMETRY = "False";
          }
          // lib.optionalAttrs serviceCfg.autoStart {
            KeepAlive = {
              SuccessfulExit = false;
            };
          };
      };
      litellm-log-rotation = {
        enable = true;
        config = {
          ProgramArguments = ["${rotateLogs}"];
          StartInterval = 3600;
          ProcessType = "Background";
        };
      };
    };
  };
}
