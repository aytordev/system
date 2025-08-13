{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.ollama;
  inherit (config._module.args.ollamaUtils) constants shellUtils;
  
  # Simple chat script
  chatScript = pkgs.writeShellScriptBin "ollama-chat" ''
    #!/usr/bin/env bash
    set -e
    
    ${shellUtils.colors}
    ${shellUtils.errorHandling}
    
    MODEL=''${1:-llama3.2}
    
    echo -e "''${CYAN}🤖 Starting chat with $MODEL''${NC}"
    echo -e "''${YELLOW}Type 'exit' to quit''${NC}"
    echo ""
    
    while true; do
      echo -ne "''${GREEN}You:''${NC} "
      read -r input
      
      case "$input" in
        exit|quit)
          echo "Goodbye!"
          exit 0
          ;;
        *)
          echo -ne "''${CYAN}$MODEL:''${NC} "
          echo "$input" | ${cfg.package}/bin/ollama run "$MODEL"
          ;;
      esac
    done
  '';
  
  # Simple code assistant
  codeScript = pkgs.writeShellScriptBin "ollama-code" ''
    #!/usr/bin/env bash
    set -e
    
    MODEL=''${1:-codellama}
    shift
    PROMPT="$*"
    
    if [ -z "$PROMPT" ]; then
      echo "Usage: ollama-code [model] <prompt>"
      echo "Example: ollama-code 'Write a Python function to sort a list'"
      exit 1
    fi
    
    echo "$PROMPT" | ${cfg.package}/bin/ollama run "$MODEL"
  '';
  
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      chatScript
      codeScript
    ];
    
    # Simple aliases
    home.shellAliases = mkIf cfg.shellAliases {
      ai-chat = mkDefault "ollama-chat";
      ai-code = mkDefault "ollama-code";
    };
  };
}