{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit (lib) getExe mkIf;

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
in {
  options.aytordev.programs.terminal.tools.mcp = {
    enable = lib.mkEnableOption "MCP (Model Context Protocol) servers";
  };

  config = mkIf cfg.enable {
    programs.mcp = {
      enable = true;
      servers = {
        filesystem = {
          command = getExe filesystemServer;
          args = lib.mkDefault [
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
          };
        };
      };
    };
  };
}
