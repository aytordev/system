# OpenCode permissions configuration module
# Defines permissions for bash commands and tools.
#
# Matching semantics (verified against the pinned OpenCode 1.18.30:
# `@opencode-ai/core/util/wildcard` + `Permission.evaluate`):
#   - A rule matches when `Wildcard.match(value, pattern)` matches; `*` -> `.*`
#     and `?` -> `.`, anchored, case-sensitive on darwin/linux.
#   - `evaluate` uses `findLast`, so the LAST matching rule in the flattened
#     ruleset wins.
#   - The effective ruleset is `defaults ++ global ++ agent-specific`, and the
#     built-in `defaults` already contain `{permission = "*"; pattern = "*";
#     action = "allow";}`. Home Manager serializes this attrset with
#     `builtins.toJSON`, which sorts keys alphabetically.
#
# Consequences that must be preserved:
#   1. Do NOT add a broad `allow` pattern (e.g. `git branch*`) that also matches
#      a mutating subcommand: it would win and silently permit the mutation.
#   2. A `*` catch-all sorts before the `-`-prefixed specific read-only forms
#      (0x2a < 0x2d), so the specific `allow` forms override it (good). A bare
#      `git branch`/`git remote`/`git config` also matches the catch-all because
#      OpenCode treats a trailing ` *` as optional, so it asks (safe).
#   3. Unmatched shell commands fall through to the built-in `"*": allow`, so
#      every mutating form worth gating needs an explicit rule. This map is a
#      convenience filter, NOT a sandbox: `edit: deny` does not constrain shell
#      writes (see ADR 0015 and client-capabilities.md T10 mapping).
{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;
in {
  config = lib.mkIf cfg.enable {
    programs.opencode.settings.permission = {
      # File edits are never silent.
      edit = "ask";

      bash = {
        # ── Git read-only ─────────────────────────────────────────────────
        "git status*" = "allow";
        "git log*" = "allow";
        "git diff*" = "allow";
        "git show*" = "allow";
        "git rev-parse*" = "allow";
        "git ls-files*" = "allow";
        "git ls-remote*" = "allow";
        "git describe*" = "allow";
        "git blame*" = "allow";
        "git shortlog*" = "allow";
        "git reflog*" = "allow";
        "git tag --list*" = "allow";
        "git tag -l*" = "allow";

        # ── `git branch`: mutating by default, list forms allowed ─────────
        "git branch *" = "ask";
        "git branch --list*" = "allow";
        "git branch -a*" = "allow";
        "git branch -r*" = "allow";
        "git branch -v*" = "allow";
        "git branch -l*" = "allow";
        "git branch --show-current*" = "allow";
        "git branch --contains*" = "allow";
        "git branch --merged*" = "allow";
        "git branch --no-merged*" = "allow";
        "git branch --points-at*" = "allow";
        "git branch --format*" = "allow";
        "git branch --sort*" = "allow";

        # ── `git remote`: mutating by default, inspection forms allowed ───
        "git remote *" = "ask";
        "git remote -v*" = "allow";
        "git remote show*" = "allow";
        "git remote get-url*" = "allow";

        # ── `git config`: mutating by default, read forms allowed ─────────
        "git config *" = "ask";
        "git config --get*" = "allow";
        "git config --get-all*" = "allow";
        "git config --get-regexp*" = "allow";
        "git config --get-urlmatch*" = "allow";
        "git config --list*" = "allow";
        "git config -l*" = "allow";
        "git config --show-origin*" = "allow";
        "git config --show-scope*" = "allow";
        "git config --name-only*" = "allow";

        # `git tag` creation/mutation is not read-only.
        "git tag *" = "ask";

        # Staging mutates the index.
        "git add*" = "ask";

        # ── Safe Nix commands (read-only) ─────────────────────────────────
        "nix search*" = "allow";
        "nix eval*" = "allow";
        "nix show-config*" = "allow";
        "nix flake show*" = "allow";
        "nix flake check*" = "allow";
        "nix log*" = "allow";

        # ── Safe file system reads ────────────────────────────────────────
        "ls*" = "allow";
        "pwd*" = "allow";
        "find*" = "allow";
        "grep*" = "allow";
        "rg*" = "allow";
        "cat*" = "allow";
        "head*" = "allow";
        "tail*" = "allow";

        # ── Safe system info commands ─────────────────────────────────────
        "systemctl list-units*" = "allow";
        "systemctl list-timers*" = "allow";
        "systemctl status*" = "allow";
        "journalctl*" = "allow";
        "dmesg*" = "allow";
        "env*" = "allow";
        "nh search*" = "allow";

        # ── Audio system (read-only) ──────────────────────────────────────
        "pactl list*" = "allow";
        "pw-top*" = "allow";

        # ── Mutating git commands ─────────────────────────────────────────
        "git reset*" = "ask";
        "git commit*" = "ask";
        "git push*" = "ask";
        "git pull*" = "ask";
        "git merge*" = "ask";
        "git rebase*" = "ask";
        "git checkout*" = "ask";
        "git switch*" = "ask";
        "git stash*" = "ask";
        "git cherry-pick*" = "ask";
        "git apply*" = "ask";
        "git clean*" = "ask";

        # ── File deletion, creation and modification ──────────────────────
        "rm*" = "ask";
        "mv*" = "ask";
        "cp*" = "ask";
        "mkdir*" = "ask";
        "chmod*" = "ask";
        "chown*" = "ask";
        "ln*" = "ask";
        "touch*" = "ask";
        "tee*" = "ask";

        # ── System control operations ─────────────────────────────────────
        "systemctl start*" = "ask";
        "systemctl stop*" = "ask";
        "systemctl restart*" = "ask";
        "systemctl reload*" = "ask";
        "systemctl enable*" = "ask";
        "systemctl disable*" = "ask";

        # ── Network operations ────────────────────────────────────────────
        "curl*" = "ask";
        "wget*" = "ask";
        "ping*" = "ask";
        "ssh*" = "ask";
        "scp*" = "ask";
        "rsync*" = "ask";

        # ── Package management ────────────────────────────────────────────
        "sudo*" = "ask";
        "nixos-rebuild*" = "ask";

        # ── Process management ────────────────────────────────────────────
        "kill*" = "ask";
        "killall*" = "ask";
        "pkill*" = "ask";
      };

      # Reading is non-mutating. MCP resource reads reuse this key with
      # `metadata.server`; arbitrary MCP tool calls are filtered by tool name
      # against the merged ruleset and were not traced to a dedicated key
      # (client-capabilities.md blocker 7).
      read = "allow";
      list = "allow";
      glob = "allow";
      grep = "allow";
      webfetch = "ask";
      write = "ask";
      task = "allow";
      todowrite = "allow";
      todoread = "allow";
    };
  };
}
