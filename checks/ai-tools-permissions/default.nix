# T10 integration check: role permission intent must map to each client's real
# enforcement boundary.
#
# It evaluates a synthetic Home Manager composition, then runs a disposable
# probe (a temp target) that applies OpenCode's actual permission-matching
# semantics to the effective map:
#   - an `ask`/`deny` edit is not silently written;
#   - a read-only shell command is allowed;
#   - a mutating git/config/remote (and other mutating shell) command is gated;
#   - MCP resource reads follow `read`;
#   - the two Pi judges receive an identical target envelope and isolated
#     sessions.
# Pi's configured deny rules are asserted, and the residual risk (the
# third-party gate is not provisioned by Nix) is reported explicitly.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "permissions-check";
    email = "permissions-check@example.test";
    fullName = "Permissions Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  home =
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "permissions-check";
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
              opencode.enable = true;
              pi.enable = true;
            };
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  opencodePermission = home.programs.opencode.settings.permission;
  opencodeAgents = home.programs.opencode.settings.agent;
  reviewAgent = opencodeAgents.sdd-review;
  piPermission = home.aytordev.programs.terminal.tools.pi.permissions.config;

  workflowSrc = ../../modules/home/programs/terminal/tools/pi/workflow;

  checks = {
    # The global file-edit gate is not `allow`.
    globalEditAsks = opencodePermission.edit == "ask";

    # The reviewer role is a hard read-only boundary (file and shell).
    reviewEditDenies = reviewAgent.permission.edit == "deny";
    reviewBashDenies = reviewAgent.permission.bash == "deny";
    reviewIsSubagent = reviewAgent.mode == "subagent";
    # The generated executor prompt was replaced by the reviewer prompt.
    reviewPromptOverridden =
      !(lib.hasInfix "SDD phase executor" reviewAgent.prompt)
      && lib.hasInfix "adversarial reviewer" reviewAgent.prompt;

    # The broad mutating-git `allow` patterns are gone.
    broadGitAllowsRemoved =
      !(opencodePermission.bash ? "git branch*")
      && !(opencodePermission.bash ? "git remote*")
      && !(opencodePermission.bash ? "git config*");
    stagingGated = opencodePermission.bash."git add*" == "ask";

    # Read-only git forms stay allowed.
    readOnlyGitAllowed =
      opencodePermission.bash."git status*"
      == "allow"
      && opencodePermission.bash."git branch -a*" == "allow"
      && opencodePermission.bash."git remote -v*" == "allow"
      && opencodePermission.bash."git config --get*" == "allow"
      && opencodePermission.bash."git tag --list*" == "allow";

    # Mutating git forms are gated.
    mutatingGitGated =
      opencodePermission.bash."git branch *"
      == "ask"
      && opencodePermission.bash."git remote *" == "ask"
      && opencodePermission.bash."git config *" == "ask"
      && opencodePermission.bash."git tag *" == "ask";

    # Non-git mutating shell forms are gated too.
    mutatingShellGated =
      opencodePermission.bash."mkdir*"
      == "ask"
      && opencodePermission.bash."chmod*" == "ask"
      && opencodePermission.bash."rm*" == "ask";

    # MCP resource reads reuse the `read` key.
    mcpReadAllowed = opencodePermission.read == "allow";
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);

  report = pkgs.writeText "ai-tools-permissions-report.json" (builtins.toJSON {
    opencode = {
      global = opencodePermission;
      reviewAgent = reviewAgent.permission;
      standardAgent = opencodeAgents.sdd-standard.permission;
    };
    pi = piPermission;
  });
in
  if failed != []
  then throw "ai-tools-permissions regression failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-permissions-check" {
      nativeBuildInputs = [pkgs.nodejs_22 pkgs.gnugrep];
      WORKFLOW_DIR = workflowSrc;
    } ''
      export NODE_NO_WARNINGS=1
      export HOME="$TMPDIR"
      set -eu

      test -f ${report}

      node ${./probe.mjs} ${report} | tee probe.log
      grep --quiet "PROBE OK" probe.log
      grep --quiet "residual risk: Pi permission enforcement" probe.log

      touch "$out"
    ''
