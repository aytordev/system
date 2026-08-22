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

  warmupScript = pkgs.writeShellScriptBin "ai-warmup" ''
    set -e
    ${shellUtils.colors}
    ${shellUtils.errorHandling}

    echo -e "''${CYAN}Warming up AI models...''${NC}"

    wait_for_service

    for model in ${lib.concatStringsSep " " cfg.models}; do
      echo -e "''${BLUE}Loading: $model''${NC}"
      echo "" | ${cfg.package}/bin/ollama run "$model" >/dev/null 2>&1 &
    done
    wait

    echo -e "''${GREEN}All models loaded into VRAM''${NC}"
    ${cfg.package}/bin/ollama ps
  '';

  unloadScript = pkgs.writeShellScriptBin "ai-unload" ''
    ${shellUtils.colors}

    echo -e "''${YELLOW}Unloading all models from VRAM...''${NC}"

    running=$(${cfg.package}/bin/ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$running" ]; then
      echo -e "''${YELLOW}No models currently loaded''${NC}"
      exit 0
    fi

    for model in $running; do
      echo -e "''${BLUE}Unloading: $model''${NC}"
      ${cfg.package}/bin/ollama stop "$model" 2>/dev/null || true
    done

    echo -e "''${GREEN}All models unloaded''${NC}"
  '';
in {
  config = mkIf cfg.enable {
    home.packages = [
      chatScript
      codeScript
      warmupScript
      unloadScript
    ];

    home.shellAliases = mkIf cfg.shellAliases {
      ai-chat = mkDefault "ollama-chat";
      ai-code = mkDefault "ollama-code";
      ai-fast = mkDefault "ollama run qwen3:30b-a3b";
    };
  };
}
