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

  agents = aiTools.opencode.agents;

  throws = expr: !(builtins.tryEval expr).success;

  checks = {
    tenRoles = builtins.length (builtins.attrNames roles.roles) == 10;
    tenPhases = builtins.length roles.phases == 10;

    # Every phase routes to its tiered role; sdd-standard covers the four
    # production phases and research is a collector, not a phase.
    phaseRouting =
      roles.phaseRoles
      == {
        sdd-init = "sdd-init";
        sdd-onboard = "sdd-onboard";
        sdd-explore = "sdd-standard";
        sdd-propose = "sdd-propose";
        sdd-spec = "sdd-standard";
        sdd-design = "sdd-design";
        sdd-tasks = "sdd-standard";
        sdd-apply = "sdd-standard";
        sdd-verify = "sdd-verify";
        sdd-archive = "sdd-archive";
      };

    designIsAstra = defaultModels.sdd-design == models.astra;
    archiveIsDeepseek = defaultModels.sdd-archive == models.nan-deepseek;
    standardIsGlm = defaultModels.sdd-standard == models.nan-glm;
    orchestratorIsAstra = defaultModels.sdd-orchestrator == models.astra;
    initAndOnboardAreSol =
      defaultModels.sdd-init
      == models.sol
      && defaultModels.sdd-onboard == models.sol;
    researchIsAstra = defaultModels.sdd-research == models.astra;

    # Overriding one role leaves every other role untouched.
    overrideIsIsolated =
      overriddenPolicy.sdd-design
      == models.sonnet
      && overriddenPolicy.sdd-standard == models.nan-glm
      && overriddenPolicy.sdd-archive == models.nan-deepseek
      && overriddenPolicy.sdd-orchestrator == models.astra;

    # Every OpenCode agent is a role projection carrying the resolved model.
    agentsMatchRoles = builtins.attrNames agents == builtins.attrNames roles.roles;
    agentsUseResolvedModels =
      lib.mapAttrs (name: _: agents.${name}.model) roles.roles
      == defaultModels;

    # The override reaches exactly the overridden agent and no other.
    overrideChangesOnlyOneAgentModel =
      overridden.opencode.agents.sdd-design.model
      == models.sonnet
      && lib.mapAttrs (name: _: overridden.opencode.agents.${name}.model) roles.roles
      == overriddenPolicy;

    # Effort projects as OpenCode's reasoningEffort on the OpenAI models only;
    # the nan flash models take no effort knob, so the attribute is absent.
    openaiEffortProjected =
      agents.sdd-orchestrator.reasoningEffort or null
      == "medium"
      && agents.sdd-init.reasoningEffort or null == "medium"
      && agents.sdd-onboard.reasoningEffort or null == "medium"
      && agents.sdd-propose.reasoningEffort or null == "high"
      && agents.sdd-design.reasoningEffort or null == "high"
      && agents.sdd-verify.reasoningEffort or null == "high"
      && agents.sdd-review.reasoningEffort or null == "high"
      && agents.sdd-research.reasoningEffort or null == "high";
    nanEffortAbsent =
      !(builtins.hasAttr "reasoningEffort" agents.sdd-standard)
      && !(builtins.hasAttr "reasoningEffort" agents.sdd-archive);

    # The research collector is output-only: web access allowed, file and
    # shell writes denied, and it keeps its authored prompt instead of the
    # generated executor prompt.
    researchCollectorProfile =
      agents.sdd-research.permission
      == {
        edit = "deny";
        bash = "deny";
        webfetch = "allow";
        websearch = "allow";
      }
      && agents.sdd-research.mode == "subagent"
      && agents.sdd-research.model == models.astra
      && lib.hasInfix "external evidence collector" agents.sdd-research.prompt;

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
