{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types optionals mapAttrsToList;

  cfg = config.aytordev.programs.terminal.tools.ollama;
  serviceCfg = cfg.service;
  inherit (config._module.args.ollamaUtils) createModelPullScript;
in {
  options.aytordev.programs.terminal.tools.ollama.service = {
    enable = mkOption {
      type = types.bool;
      default = !pkgs.stdenv.isDarwin;
      description = ''
        Enable the Ollama systemd user service (Linux only).
        On macOS, the service is managed by the darwin module via launchd.
      '';
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Ollama service automatically on login";
    };
  };

  # systemd service only on Linux — macOS uses launchd via darwin module
  config = mkIf (cfg.enable && serviceCfg.enable && !pkgs.stdenv.isDarwin) {
    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama - Local Large Language Model Runner";
        Documentation = "https://github.com/ollama/ollama";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/ollama serve";
        ExecStartPost = mkIf (cfg.models != []) "${createModelPullScript}/bin/ollama-pull-models";
        Environment =
          [
            "HOME=%h"
            "OLLAMA_HOST=${cfg.host}:${toString cfg.port}"
            "OLLAMA_MODELS=%h/.local/share/ollama/models"
          ]
          ++ optionals (cfg.acceleration == "cuda") ["OLLAMA_CUDA=1"]
          ++ optionals (cfg.acceleration == "rocm") ["OLLAMA_ROCM=1"]
          ++ mapAttrsToList (name: value: "${name}=${value}") cfg.environmentVariables;

        Restart = "on-failure";
        RestartSec = 5;
        PrivateTmp = true;
        ReadWritePaths = ["%h/.local/share/ollama"];
      };

      Install = {
        WantedBy = mkIf serviceCfg.autoStart ["default.target"];
      };
    };

    home.activation.createOllamaDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.local/share/ollama/models
    '';
  };
}
