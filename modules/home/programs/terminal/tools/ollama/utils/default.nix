{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) concatMapStringsSep;

  cfg = config.aytordev.programs.terminal.tools.ollama;

  constants = {
    inherit (cfg) host port;
    baseUrl = "http://${cfg.host}:${toString cfg.port}";
  };

  shellUtils = {
    colors = ''
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      BLUE='\033[0;34m'
      CYAN='\033[0;36m'
      NC='\033[0m'
    '';

    errorHandling = ''
      handle_error() {
        echo -e "''${RED}Error: $1''${NC}" >&2
        exit 1
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

  modelOperations = {
    pullModel = model: ''
      echo -e "''${BLUE}Pulling model: ${model}''${NC}"
      if ! ${cfg.package}/bin/ollama list | grep -q "^${model}"; then
        if ${cfg.package}/bin/ollama pull ${model}; then
          echo -e "''${GREEN}Pulled ${model}''${NC}"
        else
          echo -e "''${YELLOW}Failed to pull ${model}, skipping''${NC}"
        fi
      else
        echo -e "''${YELLOW}Model ${model} already exists''${NC}"
      fi
    '';

    listModels = ''
      list_models() {
        echo -e "''${CYAN}Installed Models:''${NC}"
        ${cfg.package}/bin/ollama list
      }
    '';

    showRunning = ''
      show_running() {
        echo -e "''${GREEN}Running Models:''${NC}"
        ${cfg.package}/bin/ollama ps
      }
    '';
  };

  createModelPullScript = pkgs.writeShellScriptBin "ollama-pull-models" ''
    set -e
    ${shellUtils.colors}
    ${shellUtils.errorHandling}

    echo -e "''${CYAN}Ensuring Ollama models are available...''${NC}"

    wait_for_service
    echo -e "''${GREEN}Ollama service is ready''${NC}"

    ${concatMapStringsSep "\n" modelOperations.pullModel cfg.models}

    echo -e "''${GREEN}All models are ready''${NC}"
  '';

  createRestartScript = pkgs.writeShellScriptBin "ollama-restart" ''
    ${shellUtils.colors}

    echo -e "''${YELLOW}Restarting Ollama service...''${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      launchctl kickstart -k "gui/$(id -u)/org.nixos.ollama" 2>/dev/null \
        || launchctl stop org.nixos.ollama 2>/dev/null
      sleep 2
      launchctl start org.nixos.ollama 2>/dev/null || true
    else
      systemctl --user restart ollama.service
    fi
    sleep 2
    echo -e "''${GREEN}Service restarted''${NC}"
  '';

  createLogsScript = pkgs.writeShellScriptBin "ollama-logs" ''
    if [[ "$OSTYPE" == "darwin"* ]]; then
      tail -f "''${XDG_STATE_HOME:-$HOME/.local/state}/ollama/ollama.err.log"
    else
      journalctl --user -u ollama.service -f
    fi
  '';

  createStatusScript = pkgs.writeShellScriptBin "ollama-status" ''
    ${shellUtils.colors}

    echo -e "''${CYAN}Ollama Service Status:''${NC}"

    if ${pkgs.curl}/bin/curl -s http://${cfg.host}:${toString cfg.port}/api/tags > /dev/null 2>&1; then
      echo -e "''${GREEN}Ollama is running and API is responding''${NC}"
      echo ""
      ${modelOperations.showRunning}
      echo ""
      ${modelOperations.listModels}
    else
      echo -e "''${YELLOW}Ollama is not running or API is not responding''${NC}"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Check launchd: launchctl list | grep ollama"
      else
        echo "Check systemd: systemctl --user status ollama.service"
      fi
    fi

    echo ""
    echo -e "''${CYAN}System Memory:''${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      memory_pressure 2>/dev/null | grep -E "(free|pressure)" || true
    else
      free -h 2>/dev/null | head -2 || true
    fi
  '';
in {
  config = {
    _module.args.ollamaUtils = {
      inherit constants shellUtils modelOperations;
      inherit createModelPullScript createStatusScript createRestartScript createLogsScript;
    };
  };
}
