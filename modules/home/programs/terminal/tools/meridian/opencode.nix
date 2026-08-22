{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.meridian;
  opencodeEnabled = config.aytordev.programs.terminal.tools.opencode.enable;
in {
  config = lib.mkIf cfg.enable {
    programs.opencode.settings = lib.mkIf opencodeEnabled {
      plugin = lib.mkIf cfg.opencode.plugin [
        "${cfg.package}/lib/meridian/plugin/meridian.ts"
      ];

      model = cfg.opencode.defaultModel;

      provider.anthropic.options = {
        baseURL = "http://${cfg.proxy.host}:${toString cfg.proxy.port}";
        apiKey = "dummy";
      };
    };

    xdg.configFile."meridian/plugins.json" = lib.mkIf cfg.opencode.scrubPlugin.enable {
      text = builtins.toJSON {
        plugins = [
          {
            path = "${pkgs.aytordev.meridian-plugin-opencode-scrub}/lib/dist/index.js";
            enabled = true;
          }
        ];
      };
    };
  };
}
