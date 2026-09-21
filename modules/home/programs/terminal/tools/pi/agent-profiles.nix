# Declarative gentle-pi agent-model profiles: publish the global store and, when
# asked, materialise the effective routing (`models.json`, `subagents.json`
# `model_profiles`, and the orchestrator keys in `settings.json`).
#
# Those four files are runtime-owned: gentle-pi rewrites them when a profile is
# applied from `/gentle:profiles`. Declaring them here makes the system
# authoritative, so a manual apply is reverted by the next `darwin-switch`; set
# `materialize = false` to serve the store only and leave the routing to the TUI.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.aytordev.programs.terminal.tools.pi.agent-profiles;

  # gentle-pi's export-envelope contract and the routing vocabulary it accepts.
  # Kept here (not in the profile file) so a bad envelope is rejected at
  # evaluation time, before any file is published.
  envelopeKind = "gentle-pi.agent_model_profile";
  storeKind = "gentle-pi.agent_model_profiles";
  thinkingLevels = ["off" "minimal" "low" "medium" "high" "xhigh" "max"];
  entryKeys = ["model" "thinking"];
  # `[A-Za-z0-9._~:@/+%-]+` as an unanchored POSIX extended regex; `match`
  # already requires a full-string match.
  modelIdPattern = "[A-Za-z0-9._~:@/+%-]+";
  # The review relay reads these two roles from `models.json`, so they must
  # never reach `subagents.json` (PROVIDER_REVIEW_ROLES).
  providerReviewRoles = ["review-refuter" "review-validator"];
  reservedRole = "orchestrator";

  failFor = profile: message: throw "pi agent-profiles (${profile}): ${message}";

  # Validate one routing entry. `unknown`, `modelOk` and `orchestratorModelOk`
  # are lazy, so they are only forced after the `isAttrs` guard has passed.
  validateEntry = profile: agent: entry: let
    fail = failFor profile;
    unknown = lib.subtractLists entryKeys (builtins.attrNames entry);
    hasModel = entry ? model;
    hasThinking = entry ? thinking;
    modelOk =
      builtins.isString entry.model
      && entry.model != ""
      && builtins.match modelIdPattern entry.model != null;
    orchestratorModelOk = let
      parts = lib.splitString "/" entry.model;
      provider = builtins.head parts;
      model = lib.concatStringsSep "/" (builtins.tail parts);
    in
      provider != "" && model != "";
  in
    if !(builtins.isAttrs entry)
    then fail "config.${agent} must be an object"
    else if unknown != []
    then fail "config.${agent} has unsupported key(s): ${lib.concatStringsSep ", " unknown}"
    else if hasModel && !modelOk
    then fail "config.${agent}.model must be a non-empty string matching the provider id charset"
    else if hasThinking && !(builtins.elem entry.thinking thinkingLevels)
    then fail "config.${agent}.thinking must be one of: ${lib.concatStringsSep ", " thinkingLevels}"
    else if agent == reservedRole && hasModel && !orchestratorModelOk
    then fail "config.${agent}.model must be a <provider>/<model> pair"
    else entry;

  validateConfig = profile: profileConfig: let
    fail = failFor profile;
    roles = builtins.attrNames profileConfig;
  in
    if !(builtins.isAttrs profileConfig)
    then fail "config must be an object"
    else if roles == []
    then fail "config must not be empty"
    else builtins.mapAttrs (agent: entry: validateEntry profile agent entry) profileConfig;

  validateEnvelope = name: path: let
    fail = failFor name;
    envelope = builtins.fromJSON (builtins.readFile path);
  in
    if !(builtins.isAttrs envelope)
    then fail "profile must be a JSON object"
    else if !(envelope ? kind) || envelope.kind != envelopeKind
    then fail "envelope kind must be \"${envelopeKind}\""
    else if !(envelope ? version) || envelope.version != 1
    then fail "envelope version must be 1"
    else if !(envelope ? name) || envelope.name != name
    then fail "envelope name must be \"${name}\""
    else if !(envelope ? config)
    then fail "envelope config is required"
    else envelope // {config = validateConfig name envelope.config;};

  profiles = builtins.mapAttrs validateEnvelope cfg.profiles;

  active =
    if cfg.active == null
    then null
    else if !(profiles ? ${cfg.active})
    then throw "pi agent-profiles (${cfg.active}): active profile is not declared"
    else cfg.active;

  # Cross-field check; forced whenever a rendered document is produced.
  materializeCheck =
    if cfg.materialize && active == null
    then throw "pi agent-profiles (active): active must not be null when materialize is true"
    else null;

  activeConfig =
    if active == null
    then {}
    else profiles.${active}.config;

  # Store document: every declared config, plus the active marker when set.
  storeDoc =
    {
      kind = storeKind;
      version = 1;
      profiles = builtins.mapAttrs (_: envelope: envelope.config) profiles;
    }
    // lib.optionalAttrs (active != null) {inherit active;};

  # Effective routing: the active config without the reserved orchestrator key.
  modelsDoc = builtins.removeAttrs activeConfig [reservedRole];

  # `subagents.json` shape: `{<agent>:{model?,effort?}}`, thinking -> effort,
  # excluding the orchestrator and the provider-review roles.
  subagentsDoc = {
    model_profiles = builtins.mapAttrs (
      _: entry:
        lib.optionalAttrs (entry ? model) {inherit (entry) model;}
        // lib.optionalAttrs (entry ? thinking) {effort = entry.thinking;}
    ) (builtins.removeAttrs activeConfig ([reservedRole] ++ providerReviewRoles));
  };

  orchestratorConfig = activeConfig.orchestrator or null;

  # Orchestrator keys: one `provider/model` id split on the first `/`.
  orchestratorDoc =
    if orchestratorConfig == null
    then {}
    else
      (
        lib.optionalAttrs (orchestratorConfig ? model) (
          let
            parts = lib.splitString "/" orchestratorConfig.model;
            provider = builtins.head parts;
            model = lib.concatStringsSep "/" (builtins.tail parts);
          in {
            defaultProvider = provider;
            defaultModel = model;
          }
        )
      )
      // lib.optionalAttrs (orchestratorConfig ? thinking) {
        defaultThinkingLevel = orchestratorConfig.thinking;
      };

  rendered = builtins.seq materializeCheck (builtins.mapAttrs (_: builtins.toJSON) {
    store = storeDoc;
    models = modelsDoc;
    subagents = subagentsDoc;
    orchestrator = orchestratorDoc;
  });

  # Declared documents handed to jq through `--slurpfile`.
  storeFile = pkgs.writeText "pi-agent-model-profiles.store.json" rendered.store;
  modelsFile = pkgs.writeText "pi-agent-model-profiles.models.json" rendered.models;
  subagentsFile = pkgs.writeText "pi-agent-model-profiles.subagents.json" rendered.subagents;
  orchestratorFile = pkgs.writeText "pi-agent-model-profiles.orchestrator.json" rendered.orchestrator;

  # Idempotent, surgical merge shared by the four targets. It:
  #   - publishes the declared document when the target is missing;
  #   - refuses to replace a target that does not parse (warns on stderr);
  #   - merges with jq and writes through a sibling mktemp + mv;
  #   - preserves the existing permission bits;
  #   - skips the write when the canonical result is unchanged;
  #   - never calls `exit`, so one failure cannot abort the other merges.
  agentProfilesActivation = ''
    piAgentModelProfiles_merge() {
      piAgentModelProfiles_target="$1"
      piAgentModelProfiles_declared="$2"
      piAgentModelProfiles_program="$3"

      if [ ! -f "$piAgentModelProfiles_declared" ]; then
        return 0
      fi

      piAgentModelProfiles_jq='${lib.getExe pkgs.jq}'
      if [ ! -x "$piAgentModelProfiles_jq" ]; then
        _iNote "pi agent-profiles: jq is unavailable; leaving %s untouched" "$piAgentModelProfiles_target"
        return 0
      fi

      if [ ! -f "$piAgentModelProfiles_target" ]; then
        piAgentModelProfiles_dir="$(dirname "$piAgentModelProfiles_target")"
        $DRY_RUN_CMD mkdir -p "$piAgentModelProfiles_dir" || return 0
        # Pretty-print through the same jq the merges use, so the first write and
        # every later merge produce the same canonical formatting. `mktemp` also
        # lands the new file owner-writable (0600), like every runtime writer of
        # these files, instead of the read-only mode a store `cp` would carry.
        piAgentModelProfiles_tmp="$(mktemp "$piAgentModelProfiles_target.XXXXXX")" || return 0
        if ! "$piAgentModelProfiles_jq" . "$piAgentModelProfiles_declared" > "$piAgentModelProfiles_tmp" 2>/dev/null; then
          $DRY_RUN_CMD rm -f "$piAgentModelProfiles_tmp"
          return 0
        fi
        $DRY_RUN_CMD mv "$piAgentModelProfiles_tmp" "$piAgentModelProfiles_target" || return 0
        return 0
      fi

      # Never replace a file we cannot read.
      if ! "$piAgentModelProfiles_jq" . "$piAgentModelProfiles_target" > /dev/null 2>&1; then
        _iNote "pi agent-profiles: %s is not valid JSON; leaving it untouched" "$piAgentModelProfiles_target"
        return 0
      fi

      piAgentModelProfiles_mode="$(${lib.getExe' pkgs.coreutils "stat"} -c '%a' "$piAgentModelProfiles_target" 2>/dev/null)" || piAgentModelProfiles_mode=""
      piAgentModelProfiles_tmp="$(mktemp "$piAgentModelProfiles_target.XXXXXX")" || return 0
      if ! "$piAgentModelProfiles_jq" --slurpfile declared "$piAgentModelProfiles_declared" "$piAgentModelProfiles_program" "$piAgentModelProfiles_target" > "$piAgentModelProfiles_tmp" 2>/dev/null; then
        $DRY_RUN_CMD rm -f "$piAgentModelProfiles_tmp"
        return 0
      fi

      piAgentModelProfiles_norm="$(mktemp "$piAgentModelProfiles_target.XXXXXX")" || {
        $DRY_RUN_CMD rm -f "$piAgentModelProfiles_tmp"
        return 0
      }
      if "$piAgentModelProfiles_jq" -S . "$piAgentModelProfiles_target" > "$piAgentModelProfiles_norm" 2>/dev/null \
        && "$piAgentModelProfiles_jq" -S . "$piAgentModelProfiles_tmp" 2>/dev/null | cmp -s - "$piAgentModelProfiles_norm"; then
        $DRY_RUN_CMD rm -f "$piAgentModelProfiles_tmp" "$piAgentModelProfiles_norm"
      else
        $DRY_RUN_CMD rm -f "$piAgentModelProfiles_norm"
        $DRY_RUN_CMD mv "$piAgentModelProfiles_tmp" "$piAgentModelProfiles_target" || return 0
        if [ -n "$piAgentModelProfiles_mode" ]; then
          $DRY_RUN_CMD chmod "$piAgentModelProfiles_mode" "$piAgentModelProfiles_target" || return 0
        fi
      fi
      return 0
    }

    # 1. Global profile store: keep runtime-created profiles, overwrite the
    #    declared ones, keep the existing active marker unless we declare one.
    piAgentModelProfiles_merge "${config.home.homeDirectory}/.pi/gentle-ai/profiles.json" "${storeFile}" '
      . as $cur
      | $declared[0] as $dec
      | {
          kind: "gentle-pi.agent_model_profiles",
          version: 1,
          profiles: (($cur.profiles // {}) + $dec.profiles)
        }
      | if ($dec | has("active")) then . + {active: $dec.active}
        elif ($cur | has("active")) then . + {active: $cur.active}
        else . end
    ' || true

    ${
      lib.optionalString cfg.materialize ''
        # 2. Effective routing map: declared agents win, unrelated keys survive.
        piAgentModelProfiles_merge "${config.home.homeDirectory}/.pi/gentle-ai/models.json" "${modelsFile}" '
          . as $cur | $cur + $declared[0]
        ' || true

        # 3. Subagent model profiles: declared agents win, every other key and
        #    every other agent survives.
        piAgentModelProfiles_merge "${config.home.homeDirectory}/.pi/agent/subagents.json" "${subagentsFile}" '
          . as $cur | $declared[0] as $dec
          | $cur + {model_profiles: (($cur.model_profiles // {}) + $dec.model_profiles)}
        ' || true
      ''
    }

    ${
      lib.optionalString (cfg.materialize && orchestratorConfig != null) ''
        # 4. Orchestrator keys: declared keys win, every unrelated key
        #    (`packages`, `theme`, `tuiMode`, the banner filter) survives.
        piAgentModelProfiles_merge "${config.home.homeDirectory}/.pi/agent/settings.json" "${orchestratorFile}" '
          . as $cur | $cur + $declared[0]
        ' || true
      ''
    }
  '';
in {
  options.aytordev.programs.terminal.tools.pi."agent-profiles" = {
    enable = mkEnableOption "declarative gentle-pi agent-model profiles";

    profiles = mkOption {
      type = types.attrsOf types.path;
      default = {opensource = ./profiles/opensource.json;};
      description = ''
        Export envelopes (`gentle-pi.agent_model_profile`) keyed by profile
        name. Each path is a JSON document with `kind`, `version`, `name` and a
        non-empty routing `config`.
      '';
    };

    active = mkOption {
      type = types.nullOr types.str;
      default = "opensource";
      description = "Declared profile whose routing is materialised.";
    };

    materialize = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Also publish the effective routing (`models.json`, `subagents.json`
        `model_profiles` and the orchestrator keys in `settings.json`); when
        false only the store is published.
      '';
    };

    rendered = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      internal = true;
      default = rendered;
      description = ''
        Internal: the JSON documents this module publishes, exposed so checks
        and the operator can inspect them without reading the activation script.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.activation.piAgentModelProfiles =
      lib.hm.dag.entryAfter ["writeBoundary"] agentProfilesActivation;
  };
}
