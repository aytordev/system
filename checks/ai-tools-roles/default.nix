{
  lib,
  pkgs,
  inputs,
  ...
}: let
  # ai-tools imports call `lib.importSubdirs`, which only exists on the
  # extended aytordev lib.
  extendedLib = lib.extend inputs.self.lib.overlay;
  aiTools = import ../../modules/common/ai-tools {lib = extendedLib;};
  inherit (aiTools) roles;
  inherit (roles) models;

  defaultModels = roles.resolveAll {};
  overriddenPolicy = roles.resolveAll {sdd-design = models.sonnet;};

  overridden = import ../../modules/common/ai-tools {
    lib = extendedLib;
    roleOverrides = {sdd-design = models.sonnet;};
  };

  throws = expr: !(builtins.tryEval expr).success;

  checks = {
    designIsOpus = defaultModels.sdd-design == models.opus;
    archiveIsHaiku = defaultModels.sdd-archive == models.haiku;
    standardInheritsSonnet = defaultModels.sdd-standard == models.sonnet;
    orchestratorInheritsSonnet = defaultModels.sdd-orchestrator == models.sonnet;

    # Overriding one role leaves every other role untouched.
    overrideIsIsolated =
      overriddenPolicy.sdd-design
      == models.sonnet
      && overriddenPolicy.sdd-standard == models.sonnet
      && overriddenPolicy.sdd-archive == models.haiku
      && overriddenPolicy.sdd-orchestrator == models.sonnet;

    # Effective OpenCode agents expose real per-role models.
    opencodeAgentsAreReal =
      aiTools.opencode.agents.sdd-design.model
      == models.opus
      && aiTools.opencode.agents.sdd-archive.model == models.haiku
      && aiTools.opencode.agents.sdd-standard.model == models.sonnet
      && aiTools.opencode.agents.sdd-orchestrator.model == models.sonnet;

    # The override reaches the generated agent and only that agent.
    overrideChangesOnlyOneAgentModel =
      overridden.opencode.agents.sdd-design.model
      == models.sonnet
      && overridden.opencode.agents.sdd-standard.model == models.sonnet
      && overridden.opencode.agents.sdd-archive.model == models.haiku
      && overridden.opencode.agents.sdd-orchestrator.model == models.sonnet;

    unknownRoleRejected = throws (roles.resolveRoleModel {} "sdd-nonexistent");
    unknownOverrideRoleRejected = throws (roles.validate {sdd-nonexistent = models.sonnet;});
    unknownModelRejected = throws (roles.resolveRoleModel {sdd-design = "unknown/model";} "sdd-design");
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);
in
  if failed != []
  then throw "ai-tools role policy failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-roles-check" {} ''
      touch "$out"
    ''
