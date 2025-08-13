{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
in {
  imports = [
    ./utils.nix
    ./models.nix
    ./scripts.nix
  ];
  
  options.applications.terminal.tools.ollama = {
    enable = mkEnableOption "Ollama - Run large language models locally";
    
    package = mkOption {
      type = types.package;
      default = pkgs-stable.ollama;
      description = "The Ollama package to use";
    };
    
    acceleration = mkOption {
      type = types.enum [ "none" "metal" "cuda" "rocm" ];
      default = if pkgs.stdenv.isDarwin then "metal" else "none";
      description = "Hardware acceleration backend to use";
    };
    
    models = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "llama3.2" "codellama" "mistral" "phi3" ];
      description = ''
        List of models to pull automatically when the service starts.
        Models will be downloaded on first run if not already present.
      '';
    };
    
    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Environment variables to set for the Ollama service";
    };
    
    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for Ollama";
    };
    
    service = {
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
  };
  
  config = mkIf cfg.enable (let
    inherit (config._module.args.ollamaUtils) 
      createModelPullScript 
      createStatusScript 
      createRestartScript 
      createLogsScript;
  in {
    home.packages = with pkgs; [
      cfg.package
      createModelPullScript
    ] ++ optionals cfg.shellAliases [
      createStatusScript
      createLogsScript
      createRestartScript
    ];
    
    # Shell aliases
    home.shellAliases = mkIf cfg.shellAliases {
      ollama-models = "ollama list";
      ollama-ps = "ollama ps";
      ai = "ollama run llama3.2";
    };
    
    # Environment variables
    home.sessionVariables = {
      OLLAMA_HOST = "127.0.0.1:11434";
    };
    
    # Systemd user service
    systemd.user.services.ollama = mkIf cfg.service.enable {
      Unit = {
        Description = "Ollama - Local Large Language Model Runner";
        Documentation = "https://github.com/ollama/ollama";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      
      Service = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/ollama serve";
        ExecStartPost = mkIf (cfg.models != []) "${createModelPullScript}/bin/ollama-pull-models";
        Environment = [
          "HOME=%h"
          "OLLAMA_HOST=127.0.0.1:11434"
          "OLLAMA_MODELS=%h/.ollama/models"
        ] ++ optionals (cfg.acceleration == "metal" && pkgs.stdenv.isDarwin) [
          "OLLAMA_METAL=1"
        ] ++ optionals (cfg.acceleration == "cuda") [
          "OLLAMA_CUDA=1"
        ] ++ optionals (cfg.acceleration == "rocm") [
          "OLLAMA_ROCM=1"
        ] ++ mapAttrsToList (name: value: "${name}=${value}") cfg.environmentVariables;
        
        Restart = "on-failure";
        RestartSec = 5;
        
        # Basic security
        PrivateTmp = true;
        ReadWritePaths = [ "%h/.ollama" ];
      };
      
      Install = {
        WantedBy = mkIf cfg.service.autoStart [ "default.target" ];
      };
    };
    

    
    # Create ollama directory
    home.activation.createOllamaDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.ollama/models
    '';
  });
}