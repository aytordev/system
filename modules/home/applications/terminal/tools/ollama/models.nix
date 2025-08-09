{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
  
  # Model presets for common use cases
  modelPresets = {
    general = {
      models = [ "llama3.2" "mistral" ];
      description = "General purpose models for chat and text generation";
    };
    
    coding = {
      models = [ "codellama" "deepseek-coder" "codegemma" ];
      description = "Models optimized for code generation and analysis";
    };
    
    small = {
      models = [ "phi3" "tinyllama" "gemma2:2b" ];
      description = "Smaller models for resource-constrained environments";
    };
    
    large = {
      models = [ "llama3.1:70b" "mixtral:8x7b" ];
      description = "Large models for advanced tasks (requires significant resources)";
    };
    
    multimodal = {
      models = [ "llava" "bakllava" ];
      description = "Models that can process both text and images";
    };
    
    specialized = {
      models = [ "sqlcoder" "medllama2" "nous-hermes2" ];
      description = "Models specialized for specific domains";
    };
  };
  
  # Helper to generate model pull commands with progress tracking
  modelPullWithProgress = model: ''
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Pulling model: ${model}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    start_time=$(date +%s)
    
    if ${cfg.package}/bin/ollama pull ${model}; then
      end_time=$(date +%s)
      duration=$((end_time - start_time))
      echo "✅ Successfully pulled ${model} in ''${duration}s"
    else
      echo "❌ Failed to pull ${model}"
      return 1
    fi
  '';
  
  # Script to manage models interactively
  modelManagerScript = pkgs.writeShellScriptBin "ollama-model-manager" ''
    #!/usr/bin/env bash
    set -e
    
    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
    
    # Check if Ollama service is running
    check_service() {
      if ! systemctl --user is-active --quiet ollama.service; then
        echo -e "''${YELLOW}⚠️  Ollama service is not running. Starting it now...''${NC}"
        systemctl --user start ollama.service
        sleep 3
      fi
    }
    
    # List all available models
    list_models() {
      echo -e "''${CYAN}📚 Installed Models:''${NC}"
      ${cfg.package}/bin/ollama list
    }
    
    # Show running models
    show_running() {
      echo -e "''${GREEN}🏃 Running Models:''${NC}"
      ${cfg.package}/bin/ollama ps
    }
    
    # Pull a new model
    pull_model() {
      echo -e "''${BLUE}Enter model name to pull (e.g., llama3.2, codellama):''${NC}"
      read -r model_name
      
      if [ -z "$model_name" ]; then
        echo -e "''${RED}❌ Model name cannot be empty''${NC}"
        return 1
      fi
      
      echo -e "''${YELLOW}Pulling $model_name...''${NC}"
      if ${cfg.package}/bin/ollama pull "$model_name"; then
        echo -e "''${GREEN}✅ Successfully pulled $model_name''${NC}"
      else
        echo -e "''${RED}❌ Failed to pull $model_name''${NC}"
      fi
    }
    
    # Remove a model
    remove_model() {
      list_models
      echo -e "''${YELLOW}Enter model name to remove:''${NC}"
      read -r model_name
      
      if [ -z "$model_name" ]; then
        echo -e "''${RED}❌ Model name cannot be empty''${NC}"
        return 1
      fi
      
      echo -e "''${YELLOW}Are you sure you want to remove $model_name? (y/N):''${NC}"
      read -r confirm
      
      if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        if ${cfg.package}/bin/ollama rm "$model_name"; then
          echo -e "''${GREEN}✅ Successfully removed $model_name''${NC}"
        else
          echo -e "''${RED}❌ Failed to remove $model_name''${NC}"
        fi
      else
        echo -e "''${BLUE}Cancelled''${NC}"
      fi
    }
    
    # Show model details
    show_model_info() {
      list_models
      echo -e "''${BLUE}Enter model name to inspect:''${NC}"
      read -r model_name
      
      if [ -z "$model_name" ]; then
        echo -e "''${RED}❌ Model name cannot be empty''${NC}"
        return 1
      fi
      
      echo -e "''${CYAN}Model Information for $model_name:''${NC}"
      ${cfg.package}/bin/ollama show "$model_name"
    }
    
    # Update all installed models
    update_all_models() {
      echo -e "''${YELLOW}Updating all installed models...''${NC}"
      
      models=$(${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}')
      
      for model in $models; do
        echo -e "''${BLUE}Updating $model...''${NC}"
        if ${cfg.package}/bin/ollama pull "$model"; then
          echo -e "''${GREEN}✅ Updated $model''${NC}"
        else
          echo -e "''${RED}❌ Failed to update $model''${NC}"
        fi
      done
      
      echo -e "''${GREEN}✅ Update complete''${NC}"
    }
    
    # Show disk usage
    show_disk_usage() {
      echo -e "''${CYAN}💾 Ollama Disk Usage:''${NC}"
      
      ollama_dir="$HOME/.ollama"
      if [ -d "$ollama_dir" ]; then
        total_size=$(du -sh "$ollama_dir" 2>/dev/null | cut -f1)
        echo -e "Total size: ''${MAGENTA}$total_size''${NC}"
        echo ""
        echo "Breakdown by directory:"
        du -sh "$ollama_dir"/* 2>/dev/null | while read -r size path; do
          basename_path=$(basename "$path")
          echo -e "  ''${YELLOW}$basename_path:''${NC} $size"
        done
      else
        echo -e "''${RED}Ollama directory not found''${NC}"
      fi
    }
    
    # Install model presets
    install_preset() {
      echo -e "''${CYAN}Available Presets:''${NC}"
      echo "1) General - General purpose models"
      echo "2) Coding - Code generation models"
      echo "3) Small - Resource-efficient models"
      echo "4) Large - Advanced models (high resource usage)"
      echo "5) Multimodal - Text and image models"
      echo "6) Specialized - Domain-specific models"
      echo ""
      echo -e "''${BLUE}Select preset (1-6):''${NC}"
      read -r preset_choice
      
      case $preset_choice in
        1)
          models="llama3.2 mistral"
          ;;
        2)
          models="codellama deepseek-coder"
          ;;
        3)
          models="phi3 tinyllama"
          ;;
        4)
          echo -e "''${YELLOW}⚠️  Large models require significant resources (>32GB RAM recommended)''${NC}"
          echo "Continue? (y/N):"
          read -r confirm
          if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            return
          fi
          models="llama3.1:70b"
          ;;
        5)
          models="llava"
          ;;
        6)
          models="sqlcoder"
          ;;
        *)
          echo -e "''${RED}Invalid selection''${NC}"
          return 1
          ;;
      esac
      
      for model in $models; do
        echo -e "''${BLUE}Installing $model...''${NC}"
        if ${cfg.package}/bin/ollama pull "$model"; then
          echo -e "''${GREEN}✅ Installed $model''${NC}"
        else
          echo -e "''${RED}❌ Failed to install $model''${NC}"
        fi
      done
    }
    
    # Main menu
    main_menu() {
      while true; do
        echo ""
        echo -e "''${MAGENTA}╔════════════════════════════════════════╗''${NC}"
        echo -e "''${MAGENTA}║       🤖 Ollama Model Manager 🤖       ║''${NC}"
        echo -e "''${MAGENTA}╚════════════════════════════════════════╝''${NC}"
        echo ""
        echo "1) List installed models"
        echo "2) Show running models"
        echo "3) Pull new model"
        echo "4) Remove model"
        echo "5) Show model information"
        echo "6) Update all models"
        echo "7) Show disk usage"
        echo "8) Install model preset"
        echo "9) Exit"
        echo ""
        echo -e "''${BLUE}Select option (1-9):''${NC}"
        read -r choice
        
        case $choice in
          1) list_models ;;
          2) show_running ;;
          3) pull_model ;;
          4) remove_model ;;
          5) show_model_info ;;
          6) update_all_models ;;
          7) show_disk_usage ;;
          8) install_preset ;;
          9) 
            echo -e "''${GREEN}Goodbye! 👋''${NC}"
            exit 0
            ;;
          *)
            echo -e "''${RED}Invalid option''${NC}"
            ;;
        esac
        
        echo ""
        echo -e "''${YELLOW}Press Enter to continue...''${NC}"
        read -r
      done
    }
    
    # Check service and run main menu
    check_service
    main_menu
  '';
  
  # Script to benchmark models
  benchmarkScript = pkgs.writeShellScriptBin "ollama-benchmark" ''
    #!/usr/bin/env bash
    set -e
    
    echo "🏁 Ollama Model Benchmark"
    echo "========================="
    
    # Default prompt for benchmarking
    PROMPT="Write a Python function that calculates the factorial of a number."
    
    # Get list of installed models
    models=$(${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}')
    
    if [ -z "$models" ]; then
      echo "No models installed. Please install some models first."
      exit 1
    fi
    
    echo "Testing prompt: \"$PROMPT\""
    echo ""
    
    # Test each model
    for model in $models; do
      echo "Testing model: $model"
      echo "-------------------"
      
      # Measure time
      start_time=$(date +%s%N)
      
      # Run the model
      output=$(echo "$PROMPT" | ${cfg.package}/bin/ollama run "$model" --verbose 2>&1)
      
      end_time=$(date +%s%N)
      
      # Calculate duration in milliseconds
      duration=$(( (end_time - start_time) / 1000000 ))
      
      echo "Response time: ''${duration}ms"
      
      # Extract token information if available
      if echo "$output" | grep -q "eval count"; then
        eval_count=$(echo "$output" | grep "eval count" | sed 's/.*eval count[[:space:]]*\([0-9]*\).*/\1/')
        eval_rate=$(echo "$output" | grep "eval rate" | sed 's/.*eval rate[[:space:]]*\([0-9.]*\).*/\1/')
        echo "Tokens generated: $eval_count"
        echo "Tokens/second: $eval_rate"
      fi
      
      echo ""
    done
    
    echo "Benchmark complete!"
  '';
  
in {
  options.applications.terminal.tools.ollama.modelPresets = mkOption {
    type = types.listOf (types.enum (attrNames modelPresets));
    default = [];
    example = [ "general" "coding" ];
    description = ''
      Model presets to automatically install. Available presets:
      ${concatStringsSep "\n" (mapAttrsToList (name: preset: 
        "- ${name}: ${preset.description}"
      ) modelPresets)}
    '';
  };
  
  config = mkIf cfg.enable {
    # Add preset models to the main model list
    applications.terminal.tools.ollama.models = mkDefault (
      flatten (map (preset: modelPresets.${preset}.models) cfg.modelPresets)
    );
    
    # Add management scripts to packages
    home.packages = with pkgs; [
      modelManagerScript
      benchmarkScript
    ];
    
    # Add helpful aliases for model management
    home.shellAliases = mkIf cfg.shellAliases.enable {
      ollama-manager = mkDefault "ollama-model-manager";
      ollama-bench = mkDefault "ollama-benchmark";
      ollama-update = mkDefault "${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ${cfg.package}/bin/ollama pull {}";
      ollama-clean = mkDefault "rm -rf ~/.ollama/history";
    };
  };
}