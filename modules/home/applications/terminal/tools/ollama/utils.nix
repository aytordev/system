{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
  
  # Common constants
  constants = {
    host = "127.0.0.1";
    port = 11434;
    baseUrl = "http://127.0.0.1:11434";
  };
  
  # Common shell utilities
  shellUtils = {
    colors = ''
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      BLUE='\033[0;34m'
      MAGENTA='\033[0;35m'
      CYAN='\033[0;36m'
      NC='\033[0m' # No Color
    '';
    
    errorHandling = ''
      handle_error() {
        echo -e "''${RED}❌ Error: $1''${NC}" >&2
        exit 1
      }
      
      check_service() {
        if ! systemctl --user is-active --quiet ollama.service; then
          echo -e "''${YELLOW}⚠️  Starting Ollama service...''${NC}"
          systemctl --user start ollama.service
          sleep 3
        fi
      }
      
      wait_for_service() {
        local max_attempts=30
        local attempt=0
        while ! ${pkgs.curl}/bin/curl -s ${constants.baseUrl}/api/tags >/dev/null 2>&1; do
          attempt=$((attempt + 1))
          if [ $attempt -ge $max_attempts ]; then
            handle_error "Ollama service not responding after $max_attempts attempts"
          fi
          echo -e "''${YELLOW}Waiting for service... (''${attempt}/''${max_attempts})''${NC}"
          sleep 2
        done
      }
    '';
  };
  
  # Common functions for model operations
  modelOperations = {
    pullModel = model: ''
      echo -e "''${BLUE}📦 Pulling model: ${model}''${NC}"
      if ! ${cfg.package}/bin/ollama list | grep -q "^${model}"; then
        if ${cfg.package}/bin/ollama pull ${model}; then
          echo -e "''${GREEN}✅ Successfully pulled ${model}''${NC}"
        else
          handle_error "Failed to pull ${model}"
        fi
      else
        echo -e "''${YELLOW}Model ${model} already exists''${NC}"
      fi
    '';
    
    listModels = ''
      list_models() {
        echo -e "''${CYAN}📚 Installed Models:''${NC}"
        ${cfg.package}/bin/ollama list
      }
    '';
    
    showRunning = ''
      show_running() {
        echo -e "''${GREEN}🏃 Running Models:''${NC}"
        ${cfg.package}/bin/ollama ps
      }
    '';
  };
  
  # Create a script that pulls all configured models
  createModelPullScript = pkgs.writeShellScriptBin "ollama-pull-models" ''
    set -e
    ${shellUtils.colors}
    ${shellUtils.errorHandling}
    
    echo -e "''${CYAN}🤖 Ensuring Ollama models are available...''${NC}"
    
    wait_for_service
    echo -e "''${GREEN}✅ Ollama service is ready''${NC}"
    
    ${concatMapStringsSep "\n" modelOperations.pullModel cfg.models}
    
    echo -e "''${GREEN}✅ All models are ready''${NC}"
  '';
  
  # Basic status script
  createStatusScript = pkgs.writeShellScriptBin "ollama-status" ''
    ${shellUtils.colors}
    ${shellUtils.errorHandling}
    
    echo -e "''${CYAN}🤖 Ollama Service Status:''${NC}"
    systemctl --user status ollama.service --no-pager | head -n 5
    echo ""
    
    if systemctl --user is-active --quiet ollama.service; then
      ${modelOperations.showRunning}
      echo ""
      ${modelOperations.listModels}
    else
      echo -e "''${YELLOW}Service is not running''${NC}"
    fi
  '';
  
  # Basic restart script
  createRestartScript = pkgs.writeShellScriptBin "ollama-restart" ''
    ${shellUtils.colors}
    
    echo -e "''${YELLOW}🔄 Restarting Ollama service...''${NC}"
    systemctl --user restart ollama.service
    sleep 2
    echo -e "''${GREEN}✅ Service restarted''${NC}"
    systemctl --user status ollama.service --no-pager | head -n 3
  '';
  
  # Simple logs script
  createLogsScript = pkgs.writeShellScriptBin "ollama-logs" ''
    journalctl --user -u ollama.service -f
  '';
  
in {
  config = {
    # Export utilities for use in other modules
    _module.args.ollamaUtils = {
      inherit constants shellUtils modelOperations;
      createModelPullScript = createModelPullScript;
      createStatusScript = createStatusScript;
      createRestartScript = createRestartScript;
      createLogsScript = createLogsScript;
    };
  };
}