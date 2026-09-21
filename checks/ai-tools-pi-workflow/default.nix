# T05 integration check: the Pi SDD workflow adapter must materialize only when
# Pi (and the workflow sub-feature) is enabled, must derive its commands and
# role -> model mapping from the shared `aiTools.roles` policy, must wire the
# `aytordev-sdd` engine adapter only when gentle-ai is enabled, and must pass the
# scripted bounded-child-worker proof (dispatch with resolved role model, native
# session id, result envelope, cancellation without orphans, honest failure).
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "pi-workflow-check";
    email = "pi-workflow-check@example.test";
    fullName = "Pi Workflow Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  workflowKey = "${homeDirectory}/.pi/agent/extensions/sdd-workflow";
  workflowSrc = ../../modules/home/programs/terminal/tools/pi/workflow;

  mkHome = {
    pi ? true,
    workflow ? true,
    roleModels ? {},
    gentleAi ? false,
    commands ? null,
  }:
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "pi-workflow-check";
      extraSpecialArgs = {inherit identity;};
      modules = [
        {
          aytordev = {
            user = {
              enable = true;
              name = identity.username;
              inherit (identity) email fullName;
              home = homeDirectory;
            };
            programs.terminal.tools = {
              pi = {
                enable = pi;
                workflow =
                  {
                    enable = workflow;
                    inherit roleModels;
                  }
                  // (
                    if commands == null
                    then {}
                    else {inherit commands;}
                  );
              };
              gentle-ai.enable = gentleAi;
            };
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  hasWorkflow = home: builtins.hasAttr workflowKey home.home.file;
  workflowSource = home: home.home.file.${workflowKey}.source;

  enabledHome = mkHome {};
  disabledPiHome = mkHome {pi = false;};
  disabledWorkflowHome = mkHome {workflow = false;};
  overriddenHome = mkHome {roleModels = {sdd-design = "anthropic/claude-sonnet-4-6";};};
  engineHome = mkHome {gentleAi = true;};
  subsetHome = mkHome {commands = ["sdd-design" "sdd-apply"];};

  # `tryEval` only forces to WHNF, so the role-policy validation deferred inside
  # `piWorkflowConfig` (behind the deployed derivation) never surfaces. Force the
  # value deeply so the throw is observed.
  throws = expr: !(builtins.tryEval (builtins.deepSeq expr true)).success;

  checks = {
    enabledMaterializes = hasWorkflow enabledHome;
    disabledPiEmitsNothing = !hasWorkflow disabledPiHome;
    disabledWorkflowEmitsNothing = !hasWorkflow disabledWorkflowHome;

    # An unknown role/model override fails evaluation with the policy's error.
    unknownModelRejected =
      throws (workflowSource (mkHome {roleModels = {sdd-design = "unknown/model";};}));
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);

  piExecModule = "${pkgs.pi-coding-agent}/lib/node_modules/pi-monorepo/dist/core/exec.js";
in
  if failed != []
  then throw "ai-tools-pi-workflow regression failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-pi-workflow-check" {
      nativeBuildInputs = [pkgs.nodejs_22 pkgs.gnugrep];
    } ''
      export NODE_NO_WARNINGS=1
      export HOME="$TMPDIR"
      set -eu

      # --- extension materializes with the policy-derived commands ----------
      enabled="${workflowSource enabledHome}"
      for phase in sdd-init sdd-onboard sdd-explore sdd-propose sdd-spec sdd-design sdd-tasks sdd-apply sdd-verify sdd-archive; do
        grep --quiet "\"$phase\"" "$enabled/config.ts"
      done
      # All ten phases are exposed as commands by default.
      test "$(grep -o '"phase":"sdd-' "$enabled/config.ts" | wc -l | tr -d ' ')" -eq 10
      # Phase -> role routing comes from aiTools.roles.phaseRoles.
      grep --quiet '"sdd-onboard":"sdd-onboard"' "$enabled/config.ts"
      grep --quiet '"sdd-explore":"sdd-standard"' "$enabled/config.ts"
      grep --quiet '"sdd-archive":"sdd-archive"' "$enabled/config.ts"
      # Role -> native model mapping comes from aiTools.roles (tiered policy).
      grep --quiet 'openai/gpt-6-astra' "$enabled/config.ts"
      grep --quiet 'openai/gpt-5.6-sol' "$enabled/config.ts"
      grep --quiet 'nan/glm5.3-flash' "$enabled/config.ts"
      grep --quiet 'nan/deepseek-v4-flash' "$enabled/config.ts"
      # No role routes to the neutral Anthropic defaults anymore.
      ! grep --quiet 'anthropic/claude-' "$enabled/config.ts"
      # No engine configured -> the status command is not exposed and the marker
      # stays null.
      ! grep --quiet 'aytordev-sdd' "$enabled/config.ts"

      # --- override changes exactly the overridden role ---------------------
      overridden="${workflowSource overriddenHome}"
      grep --quiet '"sdd-design":"anthropic/claude-sonnet-4-6"' "$overridden/config.ts"
      grep --quiet '"sdd-orchestrator":"openai/gpt-6-astra"' "$overridden/config.ts"
      grep --quiet '"sdd-standard":"nan/glm5.3-flash"' "$overridden/config.ts"
      grep --quiet '"sdd-archive":"nan/deepseek-v4-flash"' "$overridden/config.ts"

      # --- selection subset only exposes the selected phases ----------------
      subset="${workflowSource subsetHome}"
      grep --quiet '"sdd-design"' "$subset/config.ts"
      grep --quiet '"sdd-apply"' "$subset/config.ts"
      # Only the selected phases become commands; phaseRoles keeps every phase.
      test "$(grep -o '"phase":"sdd-' "$subset/config.ts" | wc -l | tr -d ' ')" -eq 2
      ! grep --quiet '"phase":"sdd-archive"' "$subset/config.ts"

      # --- engine adapter wired only when gentle-ai is enabled --------------
      engine="${workflowSource engineHome}"
      grep --quiet 'aytordev-sdd' "$engine/config.ts"

      # --- scripted bounded-child-worker proof ------------------------------
      cp -r ${workflowSrc} work
      chmod -R u+w work
      (
        cd work
        PI_EXEC_MODULE="${piExecModule}" node test/proof.mjs
      ) > proof.log 2>&1
      cat proof.log
      grep --quiet "exec: pinned-pi" proof.log
      grep --quiet "PROOF OK" proof.log

      touch "$out"
    ''
