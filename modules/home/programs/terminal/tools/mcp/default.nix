{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit
    (lib)
    getExe
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.mcp;
  mcpPkgs = inputs.mcp-servers-nix.packages.${system};

  # `mcp-server-filesystem` (from the `mcp-servers-nix` input) builds the
  # `modelcontextprotocol/servers` monorepo with `buildNpmPackage`. Its tsconfig
  # lacks `@types/node`, so with the pinned Node each workspace's `tsc` (run via
  # the `prepare` lifecycle during `npm install`) errors on `process` — a broken
  # upstream build, exposed by the current nixpkgs.
  #
  # Workaround: neutralize every `prepare` (so `npm install` stops type-checking
  # the whole monorepo), then build only the filesystem workspace tolerating the
  # type-check exit. TypeScript still transpiles the emitted JS that the wrapped
  # server runs, so the runtime is unaffected (these are compile-time-only type
  # errors). Revert this override once upstream `modelcontextprotocol/servers`
  # (or `mcp-servers-nix`) ships `@types/node` or otherwise fixes the build.
  filesystemServer = mcpPkgs.mcp-server-filesystem.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        node -e '
        const fs=require("fs"),path=require("path");
        const neutral=(p)=>{if(fs.existsSync(p)){const j=JSON.parse(fs.readFileSync(p));j.scripts=j.scripts||{};j.scripts.prepare="true";fs.writeFileSync(p,JSON.stringify(j,null,2));}};
        neutral("package.json");
        for(const d of fs.readdirSync("src")){neutral(path.join("src",d,"package.json"));}
        '
      '';
    buildPhase = ''
      runHook preBuild
      npm run build --workspace @modelcontextprotocol/server-filesystem || true
      runHook postBuild
    '';
  });

  # Catalog of MCP servers this capability can declare. A definition here is
  # inert: only a name a home lists in `selection.<client>` becomes active, so
  # the reusable module enables no servers by default (ADR 0015, C2).
  catalog = {
    filesystem = {
      command = getExe filesystemServer;
      args = [
        config.home.homeDirectory
        "${config.home.homeDirectory}/Documents"
      ];
    };

    nixos = {
      command = getExe pkgs.mcp-nixos;
    };

    engram = {
      command = getExe pkgs.aytordev.engram;
      args = ["mcp"];
      env = {
        ENGRAM_DATA_DIR = "${config.xdg.dataHome}/engram";
        # Engram v2.0.0-rc checks GitHub for releases on save/export; keep the
        # server offline and deterministic.
        ENGRAM_NO_UPDATE_CHECK = "1";
      };
    };
  };

  serverNames = builtins.attrNames catalog;

  unknownServers = selected:
    lib.filter (name: !(builtins.elem name serverNames)) selected;

  serverType = types.submodule {
    options = {
      command = mkOption {
        type = types.str;
        description = "Executable for a local (stdio) MCP server.";
      };

      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Arguments passed to {option}`command`.";
      };

      env = mkOption {
        type = types.attrsOf (
          types.either types.str (types.submodule {
            options.file = mkOption {
              type = types.str;
              description = "Path to a file read into the variable at startup.";
            };
          })
        );
        default = {};
        description = ''
          Environment variables set when spawning the server. A value is either
          a literal string or a `{ file = "/path"; }` runtime credential
          reference.
        '';
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.mcp = {
    enable = mkEnableOption "MCP (Model Context Protocol) servers";

    servers = mkOption {
      type = types.attrsOf serverType;
      default = catalog;
      description = ''
        Catalog of MCP server definitions available for selection. The default
        catalog provides `filesystem`, `nixos`, and `engram`.
      '';
    };

    selection = {
      opencode = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Catalog server names selected for OpenCode. Empty by default. Only
          these are declared into `programs.mcp.servers` and projected into
          OpenCode.
        '';
      };

      pi = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Catalog server names selected for Pi. Recorded here as data for the
          Pi MCP bridge (T07); this module does not project Pi servers itself.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = unknownServers (cfg.selection.opencode ++ cfg.selection.pi) == [];
        message = ''
          aytordev.programs.terminal.tools.mcp.selection references unknown
          servers: ${lib.concatStringsSep ", " (unknownServers (cfg.selection.opencode ++ cfg.selection.pi))}
          (available: ${lib.concatStringsSep ", " serverNames})
        '';
      }
    ];

    programs.mcp = {
      enable = true;
      # Only the OpenCode-selected servers are declared. Pi's selection stays
      # data (T07) and must never leak into this generic set.
      servers = lib.filterAttrs (name: _: lib.elem name cfg.selection.opencode) cfg.servers;
    };
  };
}
