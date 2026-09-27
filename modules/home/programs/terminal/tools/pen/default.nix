{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.aytordev.programs.terminal.tools.pen;

  # Pen ships its MCP server inside the app bundle instead of as a standalone
  # package, so the wrapper derives the binary from the app derivation itself.
  # Reading it from the store (rather than from /Applications or /run) keeps a
  # real dependency edge: bumping the app rebuilds the wrapper.
  penMcpServer = "${cfg.package}/Applications/Pen.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64";

  # Pen writes exactly this argv into every client it supports
  # (`["--app", "desktop"]`); the flag names the app instance, and the server
  # derives `~/.pencil/socket/pencil-desktop.sock` from it. Baking the flag into
  # the wrapper keeps the registry entry a bare `command`, so the argv contract
  # lives in one place and a Pen release that changes it is a single-file fix.
  penMcp =
    pkgs.runCommand "pen-mcp" {
      nativeBuildInputs = [pkgs.makeWrapper];
      meta = {
        mainProgram = "pen-mcp";
        description = "Pen (pen.dev) desktop MCP server over stdio";
      };
    } ''
      mkdir -p $out/bin
      makeWrapper ${lib.escapeShellArg penMcpServer} $out/bin/pen-mcp \
        --add-flags "--app desktop"
    '';
in {
  options.aytordev.programs.terminal.tools.pen = {
    enable = mkEnableOption "the Pen (pen.dev) desktop MCP bridge";

    package = mkOption {
      type = types.package;
      default = pkgs.aytordev.pen-dev;
      defaultText = lib.literalExpression "pkgs.aytordev.pen-dev";
      description = ''
        The Pen desktop app (bundle name `Pen.app`) whose bundled MCP server the
        `pen-mcp` wrapper exposes. The app stays a system package
        (`aytordev.suites.development` on darwin); this module only bridges it
        into the user profile.
      '';
    };

    mcp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Publish the `pen-mcp` server to the user-global MCP registry
          (`aytordev.programs.terminal.tools.mcp.servers`) so MCP clients can
          reach the document open in the Pen app.
        '';
      };

      serverName = mkOption {
        type = types.str;
        default = "pencil";
        description = "Registry key for the server; `pencil` is the name Pen itself writes into every supported client.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "aytordev.programs.terminal.tools.pen is macOS-only: the Pen desktop app ships for aarch64-darwin, so this bridge has no Linux target.";
      }
    ];

    home.packages = [penMcp];

    aytordev.programs.terminal.tools.mcp.servers = mkIf cfg.mcp.enable {
      ${cfg.mcp.serverName} = {
        command = "${penMcp}/bin/pen-mcp";
        type = "stdio";
      };
    };
  };
}
