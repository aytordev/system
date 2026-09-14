{
  lib,
  roleOverrides ? {},
  ...
}: let
  roles = import ./roles.nix {inherit lib;};
  agents = lib.importSubdirs ./agents {};

  # Remove only a leading `---` frontmatter block; any later `---` (e.g. a
  # Markdown separator) stays in the body.
  stripFrontmatter = content: let
    lines = lib.splitString "\n" content;
    startsWithDelimiter = lines != [] && lib.trim (builtins.head lines) == "---";
    step = front: rest:
      if rest == []
      then {
        inherit front;
        body = [];
        closed = false;
      }
      else if lib.trim (builtins.head rest) == "---"
      then {
        inherit front;
        body = lib.tail rest;
        closed = true;
      }
      else step (front ++ [(builtins.head rest)]) (lib.tail rest);
    split =
      if startsWithDelimiter
      then step [] (lib.tail lines)
      else {
        front = [];
        body = lines;
        closed = false;
      };
  in
    if startsWithDelimiter && split.closed
    then lib.trim (lib.concatStringsSep "\n" split.body)
    else lib.trim content;

  resolveContent = agent: agent // {content = stripFrontmatter agent.content;};
  resolvedAgents = lib.mapAttrs (_: resolveContent) agents;

  # The single effective OpenCode representation. `mode`, `model`, `permission`,
  # and `description` come from the role policy (roles.nix); the authored agent
  # owns its prompt. OpenCode's Task tool has no `model` parameter, so per-phase
  # routing is expressed by registering each role as an agent.
  toOpenCodeAgent = name: agent: {
    inherit (roles.roles.${name}) mode permission description;
    model = roles.resolveRoleModel roleOverrides name;
    prompt = lib.trim agent.content;
  };

  # Delegatable roles are projected from the same policy rather than authored
  # per skill. The orchestrator passes the concrete phase task through the Task
  # prompt; the child reads the matching phase skill at runtime.
  executorPrompt = ''
    You are an SDD phase executor launched by the sdd-orchestrator. Work only on
    the phase task in the prompt you received. Read the referenced phase skill
    under the configured skills directory, follow its execution steps in order,
    and honor the artifact-store mode and write policy given to you. Return the
    structured envelope requested by the orchestrator.
  '';

  generatedRoles = builtins.filter (name: name != "sdd-orchestrator") (builtins.attrNames roles.roles);

  toOpenCodeRoleAgent = name: {
    inherit (roles.roles.${name}) mode permission description;
    model = roles.resolveRoleModel roleOverrides name;
    prompt = lib.trim executorPrompt;
  };

  toOpenCodeAgents =
    lib.mapAttrs toOpenCodeAgent resolvedAgents
    // builtins.listToAttrs (
      map (name: {
        inherit name;
        value = toOpenCodeRoleAgent name;
      })
      generatedRoles
    );
in {
  inherit
    agents
    toOpenCodeAgents
    ;
}
