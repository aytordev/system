{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.aytordev.programs.terminal.tools.ollama;
  advancedCfg = cfg.advancedScripts;
  inherit (config._module.args.ollamaUtils) constants shellUtils;
in {
  options.aytordev.programs.terminal.tools.ollama.advancedScripts = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable advanced Ollama scripts (RAG, API client, benchmarking)";
    };
  };

  config = mkIf (cfg.enable && advancedCfg.enable) {
    home.packages = with pkgs; [
      # RAG (Retrieval Augmented Generation) script
      (writeShellScriptBin "ollama-rag" ''
        #!/usr/bin/env bash
        set -e

        ${shellUtils.colors}
        ${shellUtils.errorHandling}

        MODEL=''${OLLAMA_RAG_MODEL:-llama3.2}
        EMBEDDINGS_DIR="$HOME/.ollama/embeddings"

        case "$1" in
          index)
            mkdir -p "$EMBEDDINGS_DIR"
            if [ -f "$2" ]; then
              echo -e "''${BLUE}Indexing file: $2''${NC}"
              cp "$2" "$EMBEDDINGS_DIR/$(basename "$2").txt"
            else
              handle_error "File not found: $2"
            fi
            ;;
          query)
            shift
            if [ -z "$(ls -A "$EMBEDDINGS_DIR" 2>/dev/null)" ]; then
              handle_error "No documents indexed. Use 'ollama-rag index <file>' first."
            fi

            context=$(grep -l -i "$*" "$EMBEDDINGS_DIR"/*.txt 2>/dev/null | head -3 | xargs cat)
            prompt="Based on this context, answer: $*\n\nContext:\n$context"
            echo "$prompt" | ${cfg.package}/bin/ollama run "$MODEL"
            ;;
          list)
            echo -e "''${CYAN}Indexed documents:''${NC}"
            ls -la "$EMBEDDINGS_DIR" 2>/dev/null || echo "No documents indexed"
            ;;
          clear)
            rm -rf "$EMBEDDINGS_DIR"
            echo "All indexes cleared"
            ;;
          *)
            echo "Usage: ollama-rag {index|query|list|clear} [args...]"
            exit 1
            ;;
        esac
      '')

      # API client script
      (writeShellScriptBin "ollama-api" ''
        #!/usr/bin/env bash
        set -e

        ${shellUtils.colors}
        BASE_URL="${constants.baseUrl}"

        case "$1" in
          generate)
            curl -s -X POST "$BASE_URL/api/generate" \
              -H "Content-Type: application/json" \
              -d "{\"model\": \"$2\", \"prompt\": \"$3\", \"stream\": false}" \
              | ${pkgs.jq}/bin/jq -r '.response'
            ;;
          health)
            if curl -s "$BASE_URL/api/tags" > /dev/null 2>&1; then
              echo -e "''${GREEN}✅ Ollama API is healthy''${NC}"
            else
              echo -e "''${RED}❌ Ollama API is not responding''${NC}"
              exit 1
            fi
            ;;
          *)
            echo "Usage: ollama-api {generate|health} [args...]"
            echo "Example: ollama-api generate llama3.2 'Hello'"
            exit 1
            ;;
        esac
      '')

      # Simple benchmark script
      (writeShellScriptBin "ollama-benchmark" ''
        #!/usr/bin/env bash
        set -e

        ${shellUtils.colors}

        PROMPT="Write a simple hello world function"
        models=$(${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}')

        if [ -z "$models" ]; then
          echo "No models installed"
          exit 1
        fi

        echo -e "''${CYAN}🏁 Benchmarking models with: $PROMPT''${NC}"
        echo ""

        for model in $models; do
          echo -e "''${BLUE}Testing $model...''${NC}"
          start_time=$(date +%s)
          echo "$PROMPT" | ${cfg.package}/bin/ollama run "$model" > /dev/null
          end_time=$(date +%s)
          duration=$((end_time - start_time))
          echo -e "''${GREEN}$model: ''${duration}s''${NC}"
        done
      '')
    ];

    # Advanced aliases
    home.shellAliases = mkIf cfg.shellAliases {
      ai-rag = mkDefault "ollama-rag";
      ai-api = mkDefault "ollama-api";
      ai-bench = mkDefault "ollama-benchmark";
    };
  };
}
