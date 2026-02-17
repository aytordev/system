{
  config,
  lib,
  ...
}: let
  ollamaCfg = config.aytordev.programs.terminal.tools.ollama;
  litellmCfg = config.aytordev.programs.terminal.tools.litellm;
in {
  config = {
    programs.opencode.settings.provider = {
      ollama = lib.mkIf ollamaCfg.enable {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://${ollamaCfg.host}:${toString ollamaCfg.port}/v1";
        };
        models = {
          "qwen2.5-coder:32b" = {
            name = "Qwen 2.5 Coder 32B";
          };
          "qwen3:30b-a3b" = {
            name = "Qwen 3 30B MoE";
          };
        };
      };

      litellm = lib.mkIf litellmCfg.enable {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM Proxy";
        options = {
          baseURL = "http://${litellmCfg.host}:${toString litellmCfg.port}/v1";
        };
        models = {
          "local-coder" = {
            name = "Local Coder (via LiteLLM)";
          };
          "local-fast" = {
            name = "Local Fast (via LiteLLM)";
          };
        };
      };
    };
  };
}
