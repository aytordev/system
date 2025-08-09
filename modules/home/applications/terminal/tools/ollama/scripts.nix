{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
  
  # Chat interface script with history and context management
  chatScript = pkgs.writeShellScriptBin "ollama-chat" ''
    #!/usr/bin/env bash
    set -e
    
    # Default model
    MODEL=''${1:-llama3.2}
    
    # Colors
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    
    # History file
    HISTORY_DIR="$HOME/.ollama/chat_history"
    mkdir -p "$HISTORY_DIR"
    HISTORY_FILE="$HISTORY_DIR/$(date +%Y%m%d_%H%M%S)_$MODEL.txt"
    
    echo -e "''${CYAN}🤖 Starting chat with $MODEL''${NC}"
    echo -e "''${YELLOW}Commands: /exit, /clear, /save, /model <name>''${NC}"
    echo ""
    
    # Chat loop
    while true; do
      echo -ne "''${GREEN}You:''${NC} "
      read -r input
      
      # Handle commands
      case "$input" in
        /exit|/quit)
          echo "Chat saved to: $HISTORY_FILE"
          exit 0
          ;;
        /clear)
          clear
          echo -e "''${CYAN}🤖 Chat cleared''${NC}"
          continue
          ;;
        /save)
          echo "Chat saved to: $HISTORY_FILE"
          continue
          ;;
        /model*)
          NEW_MODEL=$(echo "$input" | sed 's/^\/model[[:space:]]*//')
          if [ -n "$NEW_MODEL" ]; then
            MODEL="$NEW_MODEL"
            echo -e "''${CYAN}Switched to model: $MODEL''${NC}"
          fi
          continue
          ;;
      esac
      
      # Save input to history
      echo "You: $input" >> "$HISTORY_FILE"
      
      # Get response
      echo -ne "''${CYAN}$MODEL:''${NC} "
      response=$(echo "$input" | ${cfg.package}/bin/ollama run "$MODEL")
      echo "$response"
      
      # Save response to history
      echo "$MODEL: $response" >> "$HISTORY_FILE"
      echo "" >> "$HISTORY_FILE"
    done
  '';
  
  # Code assistant script
  codeAssistScript = pkgs.writeShellScriptBin "ollama-code" ''
    #!/usr/bin/env bash
    set -e
    
    MODEL=''${OLLAMA_CODE_MODEL:-codellama}
    
    show_help() {
      cat << EOF
    Ollama Code Assistant
    
    Usage: ollama-code [OPTIONS] [PROMPT]
    
    Options:
      -f, --file FILE     Analyze or modify a file
      -l, --language LANG Specify programming language
      -r, --review        Review code for issues
      -e, --explain       Explain code
      -o, --optimize      Suggest optimizations
      -t, --test          Generate tests
      -d, --doc           Generate documentation
      -m, --model MODEL   Use specific model (default: codellama)
      -h, --help          Show this help
    
    Examples:
      ollama-code "Write a Python function to sort a list"
      ollama-code -f script.py -r
      ollama-code -f app.js -e
      ollama-code -l rust "implement a binary tree"
    EOF
    }
    
    # Parse arguments
    FILE=""
    LANGUAGE=""
    ACTION=""
    PROMPT=""
    
    while [[ $# -gt 0 ]]; do
      case $1 in
        -f|--file)
          FILE="$2"
          shift 2
          ;;
        -l|--language)
          LANGUAGE="$2"
          shift 2
          ;;
        -r|--review)
          ACTION="review"
          shift
          ;;
        -e|--explain)
          ACTION="explain"
          shift
          ;;
        -o|--optimize)
          ACTION="optimize"
          shift
          ;;
        -t|--test)
          ACTION="test"
          shift
          ;;
        -d|--doc)
          ACTION="document"
          shift
          ;;
        -m|--model)
          MODEL="$2"
          shift 2
          ;;
        -h|--help)
          show_help
          exit 0
          ;;
        *)
          PROMPT="$*"
          break
          ;;
      esac
    done
    
    # Build the prompt
    if [ -n "$FILE" ] && [ -f "$FILE" ]; then
      FILE_CONTENT=$(cat "$FILE")
      
      case "$ACTION" in
        review)
          FULL_PROMPT="Review this code for bugs, security issues, and best practices:\n\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
        explain)
          FULL_PROMPT="Explain what this code does in detail:\n\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
        optimize)
          FULL_PROMPT="Suggest optimizations for this code:\n\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
        test)
          FULL_PROMPT="Generate comprehensive tests for this code:\n\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
        document)
          FULL_PROMPT="Generate detailed documentation for this code:\n\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
        *)
          FULL_PROMPT="$PROMPT\n\nCode:\n\`\`\`\n$FILE_CONTENT\n\`\`\`"
          ;;
      esac
    else
      if [ -n "$LANGUAGE" ]; then
        FULL_PROMPT="Using $LANGUAGE: $PROMPT"
      else
        FULL_PROMPT="$PROMPT"
      fi
    fi
    
    # Send to Ollama
    echo "$FULL_PROMPT" | ${cfg.package}/bin/ollama run "$MODEL"
  '';
  
  # RAG (Retrieval Augmented Generation) script for documents
  ragScript = pkgs.writeShellScriptBin "ollama-rag" ''
    #!/usr/bin/env bash
    set -e
    
    MODEL=''${OLLAMA_RAG_MODEL:-llama3.2}
    EMBEDDINGS_DIR="$HOME/.ollama/embeddings"
    
    show_help() {
      cat << EOF
    Ollama RAG (Retrieval Augmented Generation)
    
    Usage: ollama-rag [OPTIONS] COMMAND
    
    Commands:
      index FILE/DIR    Index documents for RAG
      query QUESTION    Query indexed documents
      list             List indexed documents
      clear            Clear all indexes
    
    Options:
      -m, --model MODEL    Use specific model
      -h, --help          Show this help
    
    Examples:
      ollama-rag index ~/Documents/manual.pdf
      ollama-rag index ~/projects/docs/
      ollama-rag query "How do I configure the API?"
    EOF
    }
    
    # Create embeddings directory
    mkdir -p "$EMBEDDINGS_DIR"
    
    index_document() {
      local path="$1"
      
      if [ -f "$path" ]; then
        echo "Indexing file: $path"
        
        # Extract text based on file type
        case "$path" in
          *.txt)
            content=$(cat "$path")
            ;;
          *.md)
            content=$(cat "$path")
            ;;
          *.pdf)
            if command -v pdftotext &> /dev/null; then
              content=$(pdftotext "$path" -)
            else
              echo "pdftotext not found. Install poppler-utils to index PDFs."
              return 1
            fi
            ;;
          *)
            echo "Unsupported file type"
            return 1
            ;;
        esac
        
        # Create embedding (simplified - in production use proper vector DB)
        embedding_file="$EMBEDDINGS_DIR/$(basename "$path").embedding"
        echo "$content" > "$embedding_file"
        echo "Indexed: $path -> $embedding_file"
        
      elif [ -d "$path" ]; then
        echo "Indexing directory: $path"
        find "$path" -type f \( -name "*.txt" -o -name "*.md" \) | while read -r file; do
          index_document "$file"
        done
      else
        echo "Path not found: $path"
        return 1
      fi
    }
    
    query_documents() {
      local question="$1"
      
      if [ -z "$(ls -A "$EMBEDDINGS_DIR" 2>/dev/null)" ]; then
        echo "No documents indexed. Use 'ollama-rag index' first."
        return 1
      fi
      
      echo "Searching indexed documents..."
      
      # Simple keyword search (in production use proper vector similarity)
      context=""
      for embedding_file in "$EMBEDDINGS_DIR"/*.embedding; do
        if grep -q -i "$question" "$embedding_file" 2>/dev/null; then
          context="$context\n\n--- From $(basename "$embedding_file" .embedding) ---\n"
          context="$context$(grep -C 3 -i "$question" "$embedding_file" | head -20)"
        fi
      done
      
      if [ -z "$context" ]; then
        echo "No relevant context found. Answering without context."
        prompt="$question"
      else
        prompt="Based on the following context, answer this question: $question\n\nContext:$context"
      fi
      
      echo "$prompt" | ${cfg.package}/bin/ollama run "$MODEL"
    }
    
    # Parse arguments
    case "$1" in
      index)
        shift
        index_document "$1"
        ;;
      query)
        shift
        query_documents "$*"
        ;;
      list)
        echo "Indexed documents:"
        ls -la "$EMBEDDINGS_DIR" 2>/dev/null || echo "No documents indexed"
        ;;
      clear)
        rm -rf "$EMBEDDINGS_DIR"/*
        echo "All indexes cleared"
        ;;
      -h|--help)
        show_help
        ;;
      *)
        show_help
        exit 1
        ;;
    esac
  '';
  
  # API client script
  apiScript = pkgs.writeShellScriptBin "ollama-api" ''
    #!/usr/bin/env bash
    set -e
    
    BASE_URL="http://${cfg.host}:${toString cfg.port}"
    
    show_help() {
      cat << EOF
    Ollama API Client
    
    Usage: ollama-api [COMMAND] [OPTIONS]
    
    Commands:
      generate MODEL PROMPT    Generate text
      chat MODEL MESSAGE       Chat conversation
      embeddings MODEL TEXT    Generate embeddings
      tags                     List available models
      show MODEL              Show model information
      health                  Check API health
    
    Options:
      -j, --json              Output raw JSON
      -s, --stream            Stream responses
      -h, --help              Show this help
    
    Examples:
      ollama-api generate llama3.2 "Hello, world!"
      ollama-api chat codellama "Write a Python function"
      ollama-api tags
      ollama-api health
    EOF
    }
    
    # Check API health
    check_health() {
      if curl -s "$BASE_URL/api/tags" > /dev/null 2>&1; then
        echo "✅ Ollama API is healthy at $BASE_URL"
      else
        echo "❌ Ollama API is not responding at $BASE_URL"
        exit 1
      fi
    }
    
    # Parse arguments
    case "$1" in
      generate)
        MODEL="$2"
        PROMPT="$3"
        curl -s -X POST "$BASE_URL/api/generate" \
          -H "Content-Type: application/json" \
          -d "{\"model\": \"$MODEL\", \"prompt\": \"$PROMPT\", \"stream\": false}" \
          | ${pkgs.jq}/bin/jq -r '.response'
        ;;
      chat)
        MODEL="$2"
        MESSAGE="$3"
        curl -s -X POST "$BASE_URL/api/chat" \
          -H "Content-Type: application/json" \
          -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"$MESSAGE\"}], \"stream\": false}" \
          | ${pkgs.jq}/bin/jq -r '.message.content'
        ;;
      embeddings)
        MODEL="$2"
        TEXT="$3"
        curl -s -X POST "$BASE_URL/api/embeddings" \
          -H "Content-Type: application/json" \
          -d "{\"model\": \"$MODEL\", \"prompt\": \"$TEXT\"}" \
          | ${pkgs.jq}/bin/jq '.embedding'
        ;;
      tags)
        curl -s "$BASE_URL/api/tags" | ${pkgs.jq}/bin/jq '.models[]'
        ;;
      show)
        MODEL="$2"
        curl -s -X POST "$BASE_URL/api/show" \
          -H "Content-Type: application/json" \
          -d "{\"name\": \"$MODEL\"}" \
          | ${pkgs.jq}/bin/jq '.'
        ;;
      health)
        check_health
        ;;
      -h|--help)
        show_help
        ;;
      *)
        show_help
        exit 1
        ;;
    esac
  '';
  
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      chatScript
      codeAssistScript
      ragScript
      apiScript
      
      # Additional utility scripts
      (writeShellScriptBin "ollama-compare" ''
        #!/usr/bin/env bash
        # Compare responses from different models
        
        PROMPT="''${1:-Tell me a joke}"
        shift
        MODELS="''${*:-llama3.2 mistral phi3}"
        
        echo "Prompt: $PROMPT"
        echo "================================"
        
        for model in $MODELS; do
          echo ""
          echo "Model: $model"
          echo "--------------------------------"
          echo "$PROMPT" | ${cfg.package}/bin/ollama run "$model" 2>/dev/null || echo "Model $model not available"
        done
      '')
      
      (writeShellScriptBin "ollama-translate" ''
        #!/usr/bin/env bash
        # Translation helper
        
        FROM_LANG="''${1:-English}"
        TO_LANG="''${2:-Spanish}"
        shift 2
        TEXT="$*"
        
        if [ -z "$TEXT" ]; then
          echo "Usage: ollama-translate [FROM_LANG] [TO_LANG] TEXT"
          echo "Example: ollama-translate English Spanish Hello world"
          exit 1
        fi
        
        prompt="Translate the following text from $FROM_LANG to $TO_LANG. Only provide the translation, no explanations:\n\n$TEXT"
        echo "$prompt" | ${cfg.package}/bin/ollama run llama3.2
      '')
      
      (writeShellScriptBin "ollama-summarize" ''
        #!/usr/bin/env bash
        # Summarize text or files
        
        if [ -f "$1" ]; then
          content=$(cat "$1")
          prompt="Summarize the following text concisely:\n\n$content"
        else
          prompt="Summarize the following text concisely:\n\n$*"
        fi
        
        echo "$prompt" | ${cfg.package}/bin/ollama run llama3.2
      '')
    ];
    
    # Add convenience aliases
    home.shellAliases = mkIf cfg.shellAliases.enable (cfg.shellAliases.aliases // {
      ai-chat = mkDefault "ollama-chat";
      ai-code = mkDefault "ollama-code";
      ai-rag = mkDefault "ollama-rag";
      ai-api = mkDefault "ollama-api";
      ai-compare = mkDefault "ollama-compare";
      ai-translate = mkDefault "ollama-translate";
      ai-summarize = mkDefault "ollama-summarize";
    });
  };
}