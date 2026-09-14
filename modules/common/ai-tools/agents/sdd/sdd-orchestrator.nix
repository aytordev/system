let
  # Role/model routing lives in roles.nix; the prompt renders the phase→role
  # table from that policy so it can never drift into a prompt-only model list.
  roles = import ../../roles.nix {};

  orchestratorContent = builtins.replaceStrings ["@SDD_ROLE_ROUTER_ROWS@"] [roles.roleRows] (
    builtins.readFile ./sdd-orchestrator.md
  );
in {
  sdd-orchestrator = {
    name = "sdd-orchestrator";
    content = orchestratorContent;
  };
}
