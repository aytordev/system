{
  lib,
  pkgs,
  ...
}: let
  # Source of truth is the on-disk skill tree under modules/common/ai-tools.
  skillsDir = ../../modules/common/ai-tools/skills;
  entries = builtins.readDir skillsDir;

  skillNames =
    lib.filter
    (name: entries.${name} == "directory" && builtins.pathExists (skillsDir + "/${name}/SKILL.md"))
    (builtins.attrNames entries);

  validTargets = skillNames;

  # --- Declared dependencies ----------------------------------------------

  # `dependencies` is an optional array in a skill's metadata.json. Each entry
  # names another skill. It is the only declared
  # dependency surface; prose mentions are deliberately not parsed.
  metadataOf = name: let
    file = skillsDir + "/${name}/metadata.json";
    attempt =
      if builtins.pathExists file
      then builtins.tryEval (builtins.fromJSON (builtins.readFile file))
      else {
        success = false;
        value = null;
      };
  in
    if attempt.success && builtins.isAttrs attempt.value
    then attempt.value
    else {};

  rawDeps = name: (metadataOf name).dependencies or null;

  parsedDeps = name: let
    deps = rawDeps name;
  in
    if builtins.isList deps && lib.all builtins.isString deps
    then deps
    else [];

  # --- Pure validation helpers --------------------------------------------

  referenceProblemsIn = depsOf: valid: names:
    lib.concatMap (
      name: let
        deps = depsOf name;
      in
        if deps == null
        then []
        else if !(builtins.isList deps)
        then ["${name}: 'dependencies' must be a JSON array of skill names"]
        else
          lib.concatMap (
            dep:
              if !(builtins.isString dep)
              then ["${name}: dependency entry is not a string"]
              else if !(lib.elem dep valid)
              then ["${name}: unknown dependency '${dep}'"]
              else if dep == name
              then ["${name}: skill cannot depend on itself"]
              else []
          )
          deps
    )
    names;

  # Transitive members reachable from `start`, following declared edges.
  reachable = graph: start:
    lib.converge (acc: lib.unique (acc ++ lib.concatMap (name: graph.${name} or []) acc)) start;

  # A node is on a cycle when it is reachable from its own dependencies.
  cyclicNodesIn = graph: names:
    builtins.filter (name: lib.elem name (reachable graph (graph.${name} or []))) names;

  # Skills reachable from the selected set but not themselves selected.
  missingClosureIn = graph: names: selected:
    builtins.filter
    (name: !(lib.elem name selected) && lib.elem name names)
    (lib.unique (lib.concatMap (name: reachable graph [name]) selected));

  # --- Apply to the real graph --------------------------------------------

  graph = builtins.listToAttrs (builtins.map (name: {
      inherit name;
      value = builtins.filter (dep: builtins.isString dep && lib.elem dep validTargets) (parsedDeps name);
    })
    skillNames);

  referenceProblems = referenceProblemsIn rawDeps validTargets skillNames;
  cycleProblems = builtins.map (name: "skill '${name}' participates in a dependency cycle") (cyclicNodesIn graph skillNames);

  # The capability publishes exactly these individual leaves for each client.
  clients = {
    collection = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
    opencode = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
    pi = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
  };

  closureProblems =
    lib.concatMap
    (client: builtins.map (name: "client '${client}' selects an incomplete dependency closure: missing '${name}'") (missingClosureIn graph skillNames clients.${client}))
    (builtins.attrNames clients);

  # Self-tests (pure) proving the helpers detect each failure mode. They run at
  # evaluation time, so the check fails if the logic regresses.
  fixtureCycleGraph = {
    a = ["b"];
    b = ["a"];
    c = [];
  };
  fixtureClosureGraph = {
    a = ["b"];
    b = [];
    c = [];
  };
  selfTests = {
    detectsUnresolved =
      referenceProblemsIn (name:
        if name == "a"
        then ["ghost"]
        else null) ["a" "b"] ["a"]
      != [];
    acceptsResolved =
      referenceProblemsIn (name:
        if name == "a"
        then ["b"]
        else null) ["a" "b"] ["a"]
      == [];
    detectsCycle = cyclicNodesIn fixtureCycleGraph ["a" "b" "c"] == ["a" "b"];
    acceptsAcyclic = cyclicNodesIn fixtureClosureGraph ["a" "b" "c"] == [];
    detectsOpenClosure = missingClosureIn fixtureClosureGraph ["a" "b" "c"] ["a"] == ["b"];
    acceptsClosedClosure = missingClosureIn fixtureClosureGraph ["a" "b" "c"] ["a" "b"] == [];
  };
  failedSelfTests = builtins.attrNames (lib.filterAttrs (_: ok: !ok) selfTests);

  # Each exported folder must also work on its own, outside any collection.
  standaloneProblems =
    map (name: "skill '${name}' requires a sibling package; bundle its required support instead")
    (lib.filter (name: parsedDeps name != []) skillNames);
  problems = referenceProblems ++ cycleProblems ++ closureProblems ++ standaloneProblems;
in
  if failedSelfTests != []
  then throw "ai-tools dependency self-test failures: ${lib.concatStringsSep ", " failedSelfTests}"
  else if problems == []
  then
    pkgs.runCommand "ai-tools-dependencies-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["AI tooling dependency violations in modules/common/ai-tools/skills:"]
      ++ builtins.map (problem: "  - ${problem}") problems
      ++ ["Fix the skill metadata or update the dependency contract in checks/ai-tools-dependencies."]
    ))
