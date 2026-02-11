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
in {
  options.aytordev.programs.terminal.tools.mcp = {
    enable = lib.mkEnableOption "MCP (Model Context Protocol) servers";
  };

  config = mkIf cfg.enable {
    programs.mcp = {
      enable = true;
      servers = {
        filesystem = {
          command = getExe mcpPkgs.mcp-server-filesystem;
          args = lib.mkDefault [
            config.home.homeDirectory
            "${config.home.homeDirectory}/Documents"
          ];
        };

        nixos = {
          command = getExe pkgs.mcp-nixos;
        };
      };
    };
  };
}
