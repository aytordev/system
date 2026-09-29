{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.aytordev.programs.terminal.tools.ai-skills;
  tools = config.aytordev.programs.terminal.tools;
  catalog = import ./catalog.nix;
  # Authored metadata/contracts stay in ./skills; upstream is never rewritten.
  sources = lib.mapAttrs (_: entry:
    if entry.kind == "upstream"
    then "${pkgs.aytordev.${entry.source.package}}/${entry.source.subdir}"
    else entry.source.path)
  catalog;
  collection = pkgs.linkFarm "aytordev-skills" (lib.mapAttrsToList (name: path: {inherit name path;}) sources);
  leaves = root:
    lib.mapAttrs' (name: source: {
      name = "${root}/${name}";
      value = {
        inherit source;
        # Keep real skill directories and link files, never the client root.
        recursive = true;
      };
    })
    sources;
in {
  # File-publication capability: no primary executable or profile ownership.
  options.aytordev.programs.terminal.tools.ai-skills.enable =
    mkEnableOption "the authored and upstream knowledge skills";

  config = mkIf cfg.enable {
    # Client-independent collection; each folder includes all its support files.
    xdg.dataFile."aytordev/skills".source = collection;
    home.file = mkIf tools.pi.enable (leaves ".pi/agent/skills");
  };
}
