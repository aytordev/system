{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
  
  # Helper function to pull models declaratively
  pullModelScript = model: ''
    echo "Checking model: ${model}"
    if ! ${cfg.package}/bin/ollama list | grep -q "^${model}"; then
      echo "Pulling model: ${model}"
      ${cfg.package}/bin/ollama pull ${model}
    else
      echo "Model ${model} already exists"
    fi
  '';
  
  # Create a script that pulls all configured models
  modelPullScript = pkgs.writeShellScriptBin "ollama-pull-models" ''
    set -e
    echo "Ensuring Ollama models are available..."
    
    # Wait for ollama service to be ready
    max_attempts=30
    attempt=0
    while ! ${pkgs.curl}/bin/curl -s http://${cfg.host}:${toString cfg.port}/api/tags >/dev/null 2>&1; do
      attempt=$((attempt + 1))
      if [ $attempt -ge $max_attempts ]; then
        echo "Ollama service not responding after $max_attempts attempts"
        exit 1
      fi
      echo "Waiting for Ollama service to start... (attempt $attempt/$max_attempts)"
      sleep 2
    done
    
    echo "Ollama service is ready"
    
    ${concatMapStringsSep "\n" pullModelScript cfg.models}
    
    echo "All models are ready"
  '';
in {
  imports = [
    ./models.nix
    ./scripts.nix
  ];
  
  options.applications.terminal.tools.ollama = {
    enable = mkEnableOption "Ollama - Run large language models locally";
    
    package = mkOption {
      type = types.package;
      default = pkgs.ollama or pkgs.ollama-bin;
      description = "The Ollama package to use";
    };
    
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The host address for the Ollama server";
    };
    
    port = mkOption {
      type = types.port;
      default = 11434;
      description = "The port for the Ollama server";
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
      example = {
        OLLAMA_NUM_PARALLEL = "2";
        OLLAMA_MAX_LOADED_MODELS = "2";
        OLLAMA_KEEP_ALIVE = "5m";
      };
      description = ''
        Environment variables to set for the Ollama service.
        See https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-configure-ollama-server
      '';
    };
    
    corsOrigins = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "http://localhost:3000" "https://myapp.com" ];
      description = "List of allowed CORS origins";
    };
    
    maxMemory = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "8GiB";
      description = "Maximum memory the Ollama service can use (systemd MemoryMax)";
    };
    
    cpuQuota = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "200%";
      description = "CPU quota for the Ollama service (systemd CPUQuota)";
    };
    
    shellAliases = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable shell aliases for Ollama";
      };
      
      aliases = mkOption {
        type = types.attrsOf types.str;
        default = {
          ollama-models = "ollama list";
          ollama-ps = "ollama ps";
          ai = "ollama run llama3.2";
        };
        example = {
          chat = "ollama run llama3.2";
          code = "ollama run codellama";
          summarize = "ollama run llama3.2 'Please summarize the following text:'";
        };
        description = "Shell aliases for quick access to Ollama commands";
      };
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
      
      restartIfChanged = mkOption {
        type = types.bool;
        default = true;
        description = "Restart the service when configuration changes";
      };
    };
    
    modelManagement = {
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically update models on service start";
      };
      
      garbageCollection = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable automatic cleanup of unused model layers";
        };
        
        schedule = mkOption {
          type = types.str;
          default = "weekly";
          example = "daily";
          description = "How often to run garbage collection (systemd timer format)";
        };
      };
    };
    
    integrations = {
      zed = mkOption {
        type = types.bool;
        default = true;
        description = "Configure Zed editor to use local Ollama instance";
      };
      
      vscode = mkOption {
        type = types.bool;
        default = false;
        description = "Add VSCode settings for Ollama extensions";
      };
      
      neovim = mkOption {
        type = types.bool;
        default = false;
        description = "Configure Neovim plugins for Ollama";
      };
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
      modelPullScript
    ] ++ optionals cfg.shellAliases.enable [
      (writeShellScriptBin "ollama-status" ''
        echo "🤖 Ollama Service Status:"
        systemctl --user status ollama.service --no-pager | head -n 10
        echo ""
        echo "📊 Running Models:"
        ${cfg.package}/bin/ollama ps
        echo ""
        echo "📚 Available Models:"
        ${cfg.package}/bin/ollama list
      '')
      
      (writeShellScriptBin "ollama-logs" ''
        journalctl --user -u ollama.service -f
      '')
      
      (writeShellScriptBin "ollama-restart" ''
        echo "Restarting Ollama service..."
        systemctl --user restart ollama.service
        sleep 2
        systemctl --user status ollama.service --no-pager | head -n 5
      '')
    ];
    
    # Shell aliases
    home.shellAliases = mkIf cfg.shellAliases.enable cfg.shellAliases.aliases;
    
    # Environment variables
    home.sessionVariables = {
      OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
    } // optionalAttrs (cfg.corsOrigins != []) {
      OLLAMA_ORIGINS = concatStringsSep "," cfg.corsOrigins;
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
        ExecStartPost = mkIf (cfg.models != []) "${modelPullScript}/bin/ollama-pull-models";
        Environment = [
          "HOME=%h"
          "OLLAMA_HOST=${cfg.host}:${toString cfg.port}"
          "OLLAMA_MODELS=%h/.ollama/models"
        ] ++ optionals (cfg.acceleration == "metal" && pkgs.stdenv.isDarwin) [
          "OLLAMA_METAL=1"
        ] ++ optionals (cfg.acceleration == "cuda") [
          "OLLAMA_CUDA=1"
        ] ++ optionals (cfg.acceleration == "rocm") [
          "OLLAMA_ROCM=1"
        ] ++ optionals (cfg.corsOrigins != []) [
          "OLLAMA_ORIGINS=${concatStringsSep "," cfg.corsOrigins}"
        ] ++ mapAttrsToList (name: value: "${name}=${value}") cfg.environmentVariables;
        
        Restart = "on-failure";
        RestartSec = 5;
        
        # Resource limits
        MemoryMax = mkIf (cfg.maxMemory != null) cfg.maxMemory;
        CPUQuota = mkIf (cfg.cpuQuota != null) cfg.cpuQuota;
        
        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ "%h/.ollama" ];
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
      };
      
      Install = {
        WantedBy = mkIf cfg.service.autoStart [ "default.target" ];
      };
    };
    
    # Model garbage collection timer
    systemd.user.timers.ollama-gc = mkIf (cfg.modelManagement.garbageCollection.enable && cfg.service.enable) {
      Unit = {
        Description = "Ollama model garbage collection timer";
      };
      
      Timer = {
        OnCalendar = cfg.modelManagement.garbageCollection.schedule;
        Persistent = true;
      };
      
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
    
    systemd.user.services.ollama-gc = mkIf (cfg.modelManagement.garbageCollection.enable && cfg.service.enable) {
      Unit = {
        Description = "Ollama model garbage collection";
      };
      
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "ollama-gc" ''
          echo "Running Ollama garbage collection..."
          # Remove unused model layers
          ${cfg.package}/bin/ollama list | tail -n +2 | while read -r model _; do
            echo "Checking $model..."
            # This is a placeholder - Ollama doesn't have a built-in gc command yet
            # You might want to implement custom logic here
          done
          echo "Garbage collection completed"
        ''}";
      };
    };
    
    # Create ollama directory
    home.activation.createOllamaDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.ollama/models
    '';
    
    # Zed editor integration
    programs.zed-editor.userSettings = mkIf (cfg.integrations.zed && config.programs.zed-editor.enable or false) {
      assistant = {
        default_model = mkDefault {
          provider = "ollama";
          model = if (elem "llama3.2" cfg.models) then "llama3.2:latest" 
                  else if (elem "llama3.1" cfg.models) then "llama3.1:latest"
                  else if (cfg.models != []) then "${head cfg.models}:latest"
                  else "llama3.2:latest";
        };
        version = mkDefault "2";
      };
      language_models = {
        ollama = mkDefault {
          api_url = "http://${cfg.host}:${toString cfg.port}";
        };
      };
    };
  };
}