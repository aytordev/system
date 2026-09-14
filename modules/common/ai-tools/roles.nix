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

  # Native OpenCode model ids. Add a model here to make it selectable; a bare
  # provider/model string keeps the policy client-Nix-agnostic.
  models = {
    haiku = "anthropic/claude-haiku-4-5-20251001";
    sonnet = "anthropic/claude-sonnet-4-6";
    opus = "anthropic/claude-opus-4-7";
  };

  modelIds = attrValues models;

  # Explicit inheritance for roles without a specific model.
  defaults = {
    model = "sonnet";
  };

  # The smallest role set justified by differing models, permissions, or
  # execution responsibilities. `model = null` inherits `defaults.model`.
  roles = {
    sdd-orchestrator = {
      model = null;
      mode = "primary";
      permission = {
        edit = "ask";
        bash = "ask";
      };
      description = "SDD Orchestrator - delegates spec-driven development to role subagents via the Task tool";
    };
    sdd-standard = {
      model = null;
      mode = "subagent";
      permission = {};
      description = "SDD phase executor for init, explore, propose, spec, tasks, apply, and verify.";
    };
    sdd-design = {
      model = "opus";
      mode = "subagent";
      permission = {};
      description = "SDD design-phase executor for architecture and technical design.";
    };
    sdd-archive = {
      model = "haiku";
      mode = "subagent";
      permission = {};
      description = "SDD archive-phase executor for spec sync and change closure.";
    };
    # Read-only adversarial reviewer (T10). `edit: deny` alone does not
    # constrain shell writes (ADR 0015), so `bash` is denied too; the reviewer
    # reads files and reports findings, and never writes. The correction lane
    # is a separate delegation (orchestrator/executor), so judges and fixers
    # never share a context.
    sdd-review = {
      model = null;
      mode = "subagent";
      permission = {
        edit = "deny";
        bash = "deny";
      };
      description = "Read-only adversarial reviewer for judgment-day; file edits and shell are denied.";
    };
  };

  # Ordered phase → role mapping (order is the workflow order, used for the
  # orchestrator prompt table).
  phases = [
    {
      phase = "sdd-init";
      role = "sdd-standard";
    }
    {
      phase = "sdd-explore";
      role = "sdd-standard";
    }
    {
      phase = "sdd-propose";
      role = "sdd-standard";
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
      role = "sdd-standard";
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
in {
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
