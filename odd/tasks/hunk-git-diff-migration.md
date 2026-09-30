# Feature: hunk-git-diff-migration

## Objective

Make `hunk` the git diff surface for the local user: `git diff`, `git show`,
`git log -p` and `git blame` page through `hunk pager`, and `git difftool`
reviews pairs with `hunk difftool`. git-delta's git integration is disabled
(delta stays installed as a plain binary) and difftastic's inert git
integration is retired.

## Why

The user asked for a full migration to hunk for the git diff. Hunk 0.22.0 is
already installed and themed (`modules/home/programs/terminal/tools/hunk/`)
but participates in git nowhere; meanwhile git-delta owns
`pager.diff/show/log/blame` and `interactive.difffilter` via
`programs.delta.enableGitIntegration = true`, and
`programs.difftastic.git.enable = true (mode = "both")` produces **no**
effective git config at all (no `[diff]` / `[difftool]` sections in
`~/.config/git/config`) — it is dead declaration.

## Verified facts (2026, this machine)

- `hunk pager` is "general Git pager wrapper with diff detection".
- Piped, non-TTY: `hunk pager` passes non-diff content through unchanged and
  exits 0 (`git log --oneline | hunk pager` reproduced).
- PTY probe with non-diff content: no alternate-screen TUI
  (`\e[?1049h` count = 0), so `pager.log` / `pager.blame` keep plain pager
  behavior.
- PTY probe with diff content: TUI launch (command aborts without an
  interactive terminal), which is the intended behavior for `git diff`.
- Effective git config today: `[delta]` (themed), `[interactive] difffilter =
  delta --color-only`, `[pager] diff/show/log/blame = delta`. No `[diff]`, no
  `[difftool]`.
- No check or test under `checks/` or `tests/` asserts the old pager wiring
  (grep over `home-integration`, `synthetic-home`, `home-module`,
  `activation-dry-run`, `tests/apps/*` returned nothing).

## Design

All git wiring stays in `modules/home/programs/terminal/tools/git/extras.nix`
(the module that already owns delta/difftastic/mergiraf integrations), gated on
`config.aytordev.programs.terminal.tools.hunk.enable`:

- `programs.git.settings.pager = { diff = "hunk pager"; show = "hunk pager";
  log = "hunk pager"; blame = "hunk pager"; }`
- `programs.git.settings.difftool = { prompt = false; hunk.cmd = "hunk difftool
  \"$LOCAL\" \"$REMOTE\" \"$MERGED\""; }`
- `programs.delta.enableGitIntegration = false`; `programs.delta.enable = true`
  stays so the binary remains available ad hoc (`git diff | delta`).
  The `[delta]` gitconfig section and `interactive.difffilter` disappear;
  `git add -p` falls back to git's default diff filter. Accepted tradeoff of
  the total migration.
- `programs.difftastic` block removed (inert).
- `hunk` is invoked by bare name: it is on PATH via the hunk module's
  `home.packages`.

The delta theme adapter (`delta-theme.nix`), its tests and the theme catalog
entry stay untouched: they describe the delta binary's theming, which remains
true even with git integration off.

## Tasks

- [x] Task 1 — Wire hunk into git in `extras.nix` (pager, difftool, delta
      integration off, difftastic block removed). DONE: delegated to
      `gentle-ai-worker`; single-file edit, `nix fmt` applied,
      `nix-instantiate --parse` OK. Deviation: top-level `mkMerge` branches
      (`mkIf cfg.enable` / `mkIf (cfg.enable && hunk.enable)`) instead of a
      literal nested `mkIf` — standard module-system equivalent.
- [x] Task 2 — Verify evaluation. DONE: `nix build
      .#darwinConfigurations.wang-lin.system` OK;
      `nix flake check --override-input secrets path:./checks/fixtures/secrets`
      — all checks passed. Generated
      `home-files/.config/git/config` (home-manager-generation
      `309b7mrw…`): `[pager]` diff/show/log/blame = `"hunk pager"`,
      `[difftool] prompt = false`, `[difftool "hunk"] cmd = "hunk difftool
      \"$LOCAL\" \"$REMOTE\" \"$MERGED\""`; zero `delta`/`difft`/`difffilter`
      references. Fallback note: `gentle-ai-explore` failed twice and
      `gentle-ai-verify` once (subagent runtime errors), so mapping and
      verification ran inline.
- [x] Task 2b — Independent verifier (RDD declined-review fallback). The
      candidate's START consent was declined (no lineage created) and the
      native `assess` was `unassessable` (clean tree / committed range), so
      the plan re-enabled a separate independent verifier. `gentle-ai-verify`
      failed a second time (subagent runtime), so the parent ran it inline
      from clean HEAD: structural readback of the committed diff (correct
      keys, no `with lib;`), rebuild `v1am5l6j…` (home-manager-generation
      `309b7mrw…`), generated-config readback identical, and
      `nix flake check` (CI-style) — all checks passed. PASS.
- [x] Task 3 — Documentation touch-up. DONE, no edits required:
      `docs/theme-support-matrix.md` is generated and describes theme-resource
      resolution (the delta adapter remains, dormant); no AGENTS.md/README
      claims delta as the diff pager. Delta's themed options are currently
      unconsumed (git integration off); retained for reversibility.
- [x] Task 4 — Work-unit commit(s) on feature branch `feat/hunk-git-diff`
      (branched off `main`).

## Evidence

- Code work unit: `feat(git): route git diff paging through hunk` — `ecf65417`
- Docs work unit: `docs(odd): record hunk-git-diff-migration evidence`
- Open follow-ups (user decisions): activate with `just darwin-switch
  wang-lin`; hunk-review skill adoption analyzed, not installed (see close
  report).
