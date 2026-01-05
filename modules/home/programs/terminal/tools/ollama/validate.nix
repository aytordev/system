{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib;
let
  cfg = config.aytordev.programs.terminal.tools.ollama;
in
{
  config = mkIf cfg.enable {
    # Validation script to check module configuration
    home.packages = with pkgs; [
      (writeShellScriptBin "ollama-validate" ''
        #!/usr/bin/env bash
        set -e

        # Colors
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        NC='\033[0m'

        echo -e "''${BLUE}🔍 Ollama Module Validation''${NC}"
        echo "=========================="

        # Check if ollama binary exists
        if command -v ollama &> /dev/null; then
          echo -e "''${GREEN}✅ Ollama binary found''${NC}"
          ollama --version
        else
          echo -e "''${RED}❌ Ollama binary not found''${NC}"
          exit 1
        fi

        # Check service status (macOS uses launchd, Linux uses systemd)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          # macOS launchd check
          if launchctl list | grep -q "ollama" 2>/dev/null; then
            echo -e "''${GREEN}✅ Ollama service is running (launchd)''${NC}"
          else
            echo -e "''${YELLOW}⚠️  Ollama service not found in launchd (running manually is fine)''${NC}"
          fi
        else
          # Linux systemd check
          if systemctl --user is-enabled ollama.service &> /dev/null; then
            echo -e "''${GREEN}✅ Ollama service is enabled''${NC}"

            if systemctl --user is-active ollama.service &> /dev/null; then
              echo -e "''${GREEN}✅ Ollama service is running''${NC}"
            else
              echo -e "''${YELLOW}⚠️  Ollama service is not running''${NC}"
            fi
          else
            echo -e "''${RED}❌ Ollama service is not enabled''${NC}"
          fi
        fi

        # Check API connectivity
        if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
          echo -e "''${GREEN}✅ API is responding''${NC}"
        else
          echo -e "''${YELLOW}⚠️  API is not responding (service may not be running)''${NC}"
        fi

        # Check models directory
        if [ -d "$HOME/.ollama/models" ]; then
          echo -e "''${GREEN}✅ Models directory exists''${NC}"

          # Count models
          model_count=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
          if [ "$model_count" -gt 0 ]; then
            echo -e "''${GREEN}✅ $model_count model(s) installed''${NC}"
          else
            echo -e "''${YELLOW}⚠️  No models installed yet''${NC}"
          fi
        else
          echo -e "''${RED}❌ Models directory not found''${NC}"
        fi

        # Check shell aliases
        if alias ai &> /dev/null; then
          echo -e "''${GREEN}✅ Shell aliases configured''${NC}"
        else
          echo -e "''${YELLOW}⚠️  Shell aliases not found (may need shell restart)''${NC}"
        fi

        # Check acceleration
        case "${cfg.acceleration}" in
          metal)
            if [[ "$OSTYPE" == "darwin"* ]]; then
              echo -e "''${GREEN}✅ Metal acceleration configured for macOS''${NC}"
            else
              echo -e "''${YELLOW}⚠️  Metal acceleration configured on non-macOS system''${NC}"
            fi
            ;;
          cuda)
            echo -e "''${BLUE}ℹ️  CUDA acceleration configured''${NC}"
            ;;
          rocm)
            echo -e "''${BLUE}ℹ️  ROCm acceleration configured''${NC}"
            ;;
          none)
            echo -e "''${BLUE}ℹ️  No hardware acceleration configured''${NC}"
            ;;
        esac

        echo ""
        echo -e "''${BLUE}📋 Configuration Summary:''${NC}"
        echo "Models: ${toString cfg.models}"
        echo "Model Presets: ${toString cfg.modelPresets}"
        echo "Shell Aliases: ${if cfg.shellAliases then "enabled" else "disabled"}"
        echo "Service Auto-start: ${if cfg.service.autoStart then "enabled" else "disabled"}"
        echo "Acceleration: ${cfg.acceleration}"

        echo ""
        echo -e "''${GREEN}🎉 Validation complete!''${NC}"
      '')
    ];
  };
}
