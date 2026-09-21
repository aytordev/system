{
  config,
  lib,
  ...
}: let
  inherit (lib) listToAttrs mkEnableOption mkIf;
  cfg = config.aytordev.programs.terminal.tools.ai-skills;
  tools = config.aytordev.programs.terminal.tools;
  skills = ./skills;
  names = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
  leaves = root:
    listToAttrs (map (name: {
        name = "${root}/${name}";
        value = {
          source = skills + "/${name}";
          # Keep real skill directories, matching OpenCode's existing HM layout.
          recursive = true;
        };
      })
      names);
in {
  # File-publication capability: no primary executable or profile ownership.
  options.aytordev.programs.terminal.tools.ai-skills.enable =
    mkEnableOption "the four local knowledge skills";

  config = mkIf cfg.enable {
    # Client-independent collection; each folder includes all its support files.
    xdg.dataFile."aytordev/skills".source = skills;
    home.file = mkIf tools.pi.enable (leaves ".pi/agent/skills");
    xdg.configFile = mkIf tools.opencode.enable (leaves "opencode/skills");
  };
}
