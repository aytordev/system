# Role/model policy for the SDD workflow.
#
# Pure data and pure resolution: `models` are native OpenCode model
# identifiers, each role either names a model or inherits `defaults.model`, and
# every SDD phase maps to one delegatable role. The OpenCode adapter projects a
# role into `agent.<role>.model`; T05 will project the same policy at Pi session
# level (`pi.setModel`) because Pi has no per-agent model.
#
# No provider preference is invented here: the catalogue is the single source
# of truth and a home override must name one of its ids.
_: let
  inherit
    (builtins)
    attrNames
    attrValues
    concatStringsSep
    elem
    filter
    hasAttr
    listToAttrs
    map
    mapAttrs
    ;

  # Model catalogue — the single source of truth a home override may name.
  # Anthropic keeps the neutral defaults; the owner's providers (OpenAI Codex
  # subscription + nan.builders) are registered so the role policy can select
  # them under the catalogue contract.
  models = {
    haiku = "anthropic/claude-haiku-4-5-20251001";
    sonnet = "anthropic/claude-sonnet-4-6";
    opus = "anthropic/claude-opus-4-7";
    astra = "openai-codex/gpt-6-astra";
    sol = "openai-codex/gpt-5.6-sol";
    nan-glm = "nan/glm5.3-flash";
    nan-deepseek = "nan/deepseek-v4-flash";
  };

  modelIds = attrValues models;

  # Explicit inheritance for roles without a specific model.
  defaults = {
    model = "sonnet";
  };

  # Role set sized by Alan's tiered assignment: one role per (model × effort ×
  # permission) combination the workflow needs. `model` names a catalogue key;
  # `effort` is projected as OpenCode's reasoningEffort (OpenAI models only —
  # the nan flash models take no effort knob, so it stays null there).
  roles = {
    sdd-orchestrator = {
      model = "astra";
      effort = "medium";
      mode = "primary";
      permission = {
        edit = "ask";
        bash = "ask";
      };
      description = "SDD Orchestrator - delegates spec-driven development to role subagents via the Task tool";
    };
    sdd-init = {
      model = "sol";
      effort = "medium";
      mode = "subagent";
      permission = {};
      description = "Procedural init executor: stack detection, testing capabilities, and registry bootstrap.";
    };
    sdd-onboard = {
      model = "sol";
      effort = "medium";
      mode = "subagent";
      permission = {};
      description = "Guided end-to-end SDD walkthrough executor (teaching flow, user-paced).";
    };
    sdd-standard = {
      model = "nan-glm";
      effort = null;
      mode = "subagent";
      permission = {};
      description = "SDD workhorse executor for explore, spec, tasks, and apply.";
    };
    sdd-propose = {
      model = "astra";
      effort = "high";
      mode = "subagent";
      permission = {};
      description = "SDD proposal executor; proposal quality gates everything downstream.";
    };
    sdd-design = {
      model = "astra";
      effort = "high";
      mode = "subagent";
      permission = {};
      description = "SDD design-phase executor for architecture and technical design.";
    };
    sdd-verify = {
      model = "astra";
      effort = "high";
      mode = "subagent";
      permission = {};
      description = "SDD verify executor; the C11 quality gate before archive.";
    };
    # Read-only adversarial reviewer (T10). `edit: deny` alone does not
    # constrain shell writes (ADR 0015), so `bash` is denied too; the reviewer
    # reads files and reports findings, and never writes. The correction lane
    # is a separate delegation (orchestrator/executor), so judges and fixers
    # never share a context.
    sdd-review = {
      model = "astra";
      effort = "high";
      mode = "subagent";
      permission = {
        edit = "deny";
        bash = "deny";
      };
      description = "Read-only adversarial reviewer for judgment-day; file edits and shell are denied.";
    };
    # Output-only external evidence collector (T22 contract): web access only —
    # no local artifact reads, no persistence calls, no repository mutation.
    sdd-research = {
      model = "astra";
      effort = "high";
      mode = "subagent";
      permission = {
        edit = "deny";
        bash = "deny";
        webfetch = "allow";
        websearch = "allow";
      };
      description = "Output-only external evidence collector; returns the research-evidence envelope for the orchestrator to validate and persist.";
    };
    sdd-archive = {
      model = "nan-deepseek";
      effort = null;
      mode = "subagent";
      permission = {};
      description = "SDD archive executor for spec sync, closure, and change archiving.";
    };
  };

  # Ordered phase → role mapping (order is the workflow order, used for the
  # orchestrator prompt table). Research is a delegable collector, not a
  # lifecycle phase, so it is not routed here.
  phases = [
    {
      phase = "sdd-init";
      role = "sdd-init";
    }
    {
      phase = "sdd-onboard";
      role = "sdd-onboard";
    }
    {
      phase = "sdd-explore";
      role = "sdd-standard";
    }
    {
      phase = "sdd-propose";
      role = "sdd-propose";
    }
    {
      phase = "sdd-spec";
      role = "sdd-standard";
    }
    {
      phase = "sdd-design";
      role = "sdd-design";
    }
    {
      phase = "sdd-tasks";
      role = "sdd-standard";
    }
    {
      phase = "sdd-apply";
      role = "sdd-standard";
    }
    {
      phase = "sdd-verify";
      role = "sdd-verify";
    }
    {
      phase = "sdd-archive";
      role = "sdd-archive";
    }
  ];

  phaseRoles = listToAttrs (map (entry: {
      name = entry.phase;
      value = entry.role;
    })
    phases);

  roleRows = concatStringsSep "\n" (map (entry: "| ${entry.phase} | `${entry.role}` |") phases);

  # `overrides` maps a role name to a native model id. Unknown roles and
  # unknown model ids fail evaluation with a named error; an unavailable model
  # is never silently substituted.
  validate = overrides: let
    unknownRoles = filter (name: !(hasAttr name roles)) (attrNames overrides);
    unknownModels =
      filter (name: !(elem overrides.${name} modelIds))
      (filter (name: hasAttr name roles) (attrNames overrides));
    problems =
      map (name: "unknown role '${name}' in agentModels") unknownRoles
      ++ map (name: "unknown model '${overrides.${name}}' for role '${name}'") unknownModels;
  in
    if problems == []
    then overrides
    else throw ("ai-tools role policy violations:\n" + concatStringsSep "\n" (map (problem: "  - ${problem}") problems));

  resolveRoleModel = overrides: role:
    if !(hasAttr role roles)
    then throw "ai-tools role policy: unknown role '${role}'"
    else let
      valid = validate overrides;
      roleModel = roles.${role}.model;
      inherited =
        if roleModel == null
        then defaults.model
        else roleModel;
    in
      valid.${role} or models.${inherited};

  resolveAll = overrides: mapAttrs (role: _: resolveRoleModel overrides role) roles;

  # Effort is projected as OpenCode's reasoningEffort (an OpenAI-model option);
  # a typo would surface at runtime as a provider error, so fail at evaluation.
  effortValues = ["low" "medium" "high"];
  effortProblems = let
    invalid =
      filter
      (name: let
        e = roles.${name}.effort;
      in
        e != null && !(elem e effortValues))
      (attrNames roles);
  in
    if invalid == []
    then null
    else throw ("ai-tools role policy: invalid effort for: " + concatStringsSep ", " invalid);
in
  assert effortProblems == null; {
    inherit
      models
      modelIds
      defaults
      roles
      phases
      phaseRoles
      roleRows
      validate
      resolveRoleModel
      resolveAll
      ;
  }
