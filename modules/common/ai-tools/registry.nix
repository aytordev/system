{lib, ...}: let
  inherit
    (lib)
    attrNames
    attrValues
    concatMap
    concatStringsSep
    count
    elem
    filter
    hasSuffix
    removeSuffix
    unique
    ;
  inherit (builtins) readDir;

  aiCommands = import ./commands.nix {inherit lib;};
  aiAgents = import ./agents.nix {inherit lib;};

  # A command/agent identifier is its file basename. `importSubdirs` merges the
  # category subdirectories with `//`, so a repeated basename would otherwise be
  # dropped silently; collecting the declared names lets the contract reject it.
  declaredNames = dir:
    concatMap (
      category: let
        entries = readDir (dir + "/${category}");
      in
        map (file: removeSuffix ".nix" file) (
          filter (file: entries.${file} == "regular" && hasSuffix ".nix" file) (attrNames entries)
        )
    ) (attrNames (readDir dir));

  duplicateNames = names:
    unique (filter (name: count (other: other == name) names > 1) names);

  commandNames = declaredNames ./commands;
  agentNames = declaredNames ./agents;

  rawCommands = aiCommands.normalizedCommands;
  rawAgents = aiAgents.agents;

  # Every declared file must produce exactly the identifier it is named after,
  # and every produced identifier must have a declaration file.
  keyProblems =
    map (name: "command '${name}' is declared in a file but returns a different identifier") (
      filter (name: !(elem name (attrNames rawCommands))) commandNames
    )
    ++ map (name: "command '${name}' has no declaration file") (
      filter (name: !(elem name commandNames)) (attrNames rawCommands)
    )
    ++ map (name: "agent '${name}' is declared in a file but returns a different identifier") (
      filter (name: !(elem name (attrNames rawAgents))) agentNames
    )
    ++ map (name: "agent '${name}' has no declaration file") (
      filter (name: !(elem name agentNames)) (attrNames rawAgents)
    );

  unresolvedAgents =
    filter (command: command.agent != null && !(elem command.agent (attrNames rawAgents))) (attrValues rawCommands);

  problem = let
    parts =
      map (name: "duplicate command identifier '${name}'") (duplicateNames commandNames)
      ++ map (name: "duplicate agent identifier '${name}'") (duplicateNames agentNames)
      ++ keyProblems
      ++ map (command: "command '${command.commandName}' references unknown agent '${command.agent}'") unresolvedAgents;
  in
    if parts == []
    then null
    else throw ("ai-tools contract violations:\n" + concatStringsSep "\n" (map (part: "  - ${part}") parts));
in {
  inherit duplicateNames commandNames agentNames;

  # Forcing either field evaluates `problem`, so an invalid registry throws.
  commands = lib.seq problem rawCommands;
  agents = lib.seq problem rawAgents;
}
