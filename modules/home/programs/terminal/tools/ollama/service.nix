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
  environment =
    {
      OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
      OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";
    }
    // accelerationEnvironment
    // cfg.environmentVariables;
  environmentList = lib.mapAttrsToList (name: value: "${name}=${value}") environment;
  inherit (config._module.args.ollamaUtils) createModelPullScript;
  startScript = pkgs.writeShellScript "ollama-service" ''
    /bin/wait4path ${lib.escapeShellArg (lib.getExe cfg.package)}
    exec ${lib.getExe cfg.package} serve
  '';
in {
  options.aytordev.programs.terminal.tools.ollama.service = {
    enable = lib.mkEnableOption "Ollama as a user service";
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
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
            Type = "notify";
            ExecStart = "${lib.getExe cfg.package} serve";
            ExecStartPost = lib.mkIf (cfg.models != []) "${createModelPullScript}/bin/ollama-pull-models";
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
        launchd.agents.ollama = {
          enable = true;
          config = {
            ProgramArguments = [startScript];
            KeepAlive = {
              SuccessfulExit = false;
            };
            RunAtLoad = serviceCfg.autoStart;
            ThrottleInterval = 30;
            ProcessType = "Background";
            StandardOutPath = "${logDir}/ollama.out.log";
            StandardErrorPath = "${logDir}/ollama.err.log";
            EnvironmentVariables = environment;
          };
        };
      })
    ]
  );
}
