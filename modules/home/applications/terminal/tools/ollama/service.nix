{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib;
let
  cfg = config.aytordev.applications.terminal.tools.ollama;
  serviceCfg = cfg.service;
  inherit (config._module.args.ollamaUtils) createModelPullScript;
in
{
  options.aytordev.applications.terminal.tools.ollama.service = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the Ollama systemd user service";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Ollama service automatically on login";
    };
  };

  config = mkIf (cfg.enable && serviceCfg.enable) {
    # Systemd user service
    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama - Local Large Language Model Runner";
        Documentation = "https://github.com/ollama/ollama";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/ollama serve";
        ExecStartPost = mkIf (cfg.models != [ ]) "${createModelPullScript}/bin/ollama-pull-models";
        Environment =
          [
            "HOME=%h"
            "OLLAMA_HOST=127.0.0.1:11434"
            "OLLAMA_MODELS=%h/.ollama/models"
          ]
          ++ optionals (cfg.acceleration == "metal" && pkgs.stdenv.isDarwin) [
            "OLLAMA_METAL=1"
          ]
          ++ optionals (cfg.acceleration == "cuda") [
            "OLLAMA_CUDA=1"
          ]
          ++ optionals (cfg.acceleration == "rocm") [
            "OLLAMA_ROCM=1"
          ]
          ++ mapAttrsToList (name: value: "${name}=${value}") cfg.environmentVariables;

        Restart = "on-failure";
        RestartSec = 5;

        # Basic security
        PrivateTmp = true;
        ReadWritePaths = [ "%h/.ollama" ];
      };

      Install = {
        WantedBy = mkIf serviceCfg.autoStart [ "default.target" ];
      };
    };

    # Create ollama directory
    home.activation.createOllamaDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.ollama/models
    '';
  };
}
