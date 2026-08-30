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
        while ! ${pkgs.curl}/bin/curl -s ${lib.escapeShellArg "${constants.baseUrl}/api/tags"} >/dev/null 2>&1; do
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
    pullModel = model: let
      modelArg = lib.escapeShellArg model;
    in ''
      printf '%bPulling model: %s%b\n' "''${BLUE}" ${modelArg} "''${NC}"
      if ! ${cfg.package}/bin/ollama list | ${pkgs.gawk}/bin/awk -v model=${modelArg} 'NR > 1 && $1 == model { found=1 } END { exit !found }'; then
        if ${cfg.package}/bin/ollama pull ${modelArg}; then
          printf '%bPulled %s%b\n' "''${GREEN}" ${modelArg} "''${NC}"
        else
          printf '%bFailed to pull %s, skipping%b\n' "''${YELLOW}" ${modelArg} "''${NC}"
        fi
      else
        printf '%bModel %s already exists%b\n' "''${YELLOW}" ${modelArg} "''${NC}"
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
    ${
      if pkgs.stdenv.hostPlatform.isDarwin
      then ''
        /bin/launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.ollama"
      ''
      else ''
        ${lib.getExe' pkgs.systemd "systemctl"} --user restart ollama.service
      ''
    }
    sleep 2
    echo -e "''${GREEN}Service restarted''${NC}"
  '';

  createLogsScript = pkgs.writeShellScriptBin "ollama-logs" ''
    ${
      if pkgs.stdenv.hostPlatform.isDarwin
      then ''
        tail -f "''${XDG_STATE_HOME:-$HOME/.local/state}/ollama/ollama.err.log"
      ''
      else ''
        ${lib.getExe' pkgs.systemd "journalctl"} --user -u ollama.service -f
      ''
    }
  '';

  createStatusScript = pkgs.writeShellScriptBin "ollama-status" ''
    ${shellUtils.colors}

    echo -e "''${CYAN}Ollama Service Status:''${NC}"

    if ${pkgs.curl}/bin/curl -s ${lib.escapeShellArg "${constants.baseUrl}/api/tags"} > /dev/null 2>&1; then
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
      inherit
        createModelPullScript
        createStatusScript
        createRestartScript
        createLogsScript
        ;
    };
  };
}
