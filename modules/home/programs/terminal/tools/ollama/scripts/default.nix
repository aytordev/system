{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;

  cfg = config.aytordev.programs.terminal.tools.ollama;
  inherit (config._module.args.ollamaUtils) shellUtils;

  chatScript = pkgs.writeShellScriptBin "ollama-chat" ''
    set -e

    ${shellUtils.colors}
    ${shellUtils.errorHandling}

    MODEL=''${1:-qwen3:30b-a3b}

    echo -e "''${CYAN}Starting chat with $MODEL''${NC}"
    echo -e "''${YELLOW}Type 'exit' to quit''${NC}"
    echo ""

    ${cfg.package}/bin/ollama run "$MODEL"
  '';

  codeScript = pkgs.writeShellScriptBin "ollama-code" ''
    set -e

    MODEL=''${1:-qwen2.5-coder:32b}
    shift 2>/dev/null || true
    PROMPT="$*"

    if [ -z "$PROMPT" ]; then
      echo "Usage: ollama-code [model] <prompt>"
      echo "Default model: qwen2.5-coder:32b"
      exit 1
    fi

    echo "$PROMPT" | ${cfg.package}/bin/ollama run "$MODEL"
  '';
in {
  config = mkIf cfg.enable {
    home.packages = [
      chatScript
      codeScript
    ];

    home.shellAliases = mkIf cfg.shellAliases {
      ai-chat = mkDefault "ollama-chat";
      ai-code = mkDefault "ollama-code";
      ai-fast = mkDefault "ollama run qwen3:30b-a3b";
    };
  };
}
