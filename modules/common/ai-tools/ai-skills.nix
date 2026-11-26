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
  # Authored sources are local paths; each packaged skill names its own subdir.
  sources = lib.mapAttrs (_: {source, ...}:
    source.path or "${pkgs.aytordev.${source.package}}/${source.subdir}")
  catalog;
  runtimePackages = lib.unique (lib.concatMap (entry:
    lib.optional (entry ? runtimePackage) pkgs.aytordev.${entry.runtimePackage})
  (builtins.attrValues catalog));
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
  # Skill publication and its declared runtime dependencies; no profile ownership.
  options.aytordev.programs.terminal.tools.ai-skills.enable =
    mkEnableOption "the authored and upstream knowledge skills";

  config = mkIf cfg.enable {
    # Client-independent collection; each folder includes all its support files.
    xdg.dataFile."aytordev/skills".source = collection;
    home.file = mkIf tools.pi.enable (leaves ".pi/agent/skills");
    home.packages = mkIf tools.pi.enable runtimePackages;
  };
}
