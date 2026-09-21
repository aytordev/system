# Module Migration Checklist

Canonical module template: `modules/common/ai-tools/skills/dotfiles-coder/rules/patterns-module.md`
Contract: `docs/decisions/0008-module-contract-v1.md`

Goal: converge every module on the canonical shape — `options`/`config`
separation, `cfg` binding, `lib.mkIf cfg.enable`, `enable` + conditional
`package` (via `lib.mkPackageOption` unless a conditional default needs the
manual form), delegate to `programs.<tool>` when a Home Manager module exists
(no redundant `home.packages`), no `mkOpt`/`mkBoolOpt` in tools (use
`lib.mkOption` directly), `lib.getExe` for aliases/wrappers, shell
integration as `aytordev.*` options defaulting to `shellEnabled`, platform
guards `pkgs.stdenv.hostPlatform.isDarwin/isLinux`, no `with lib;`/`if-then-else`
for conditions, sibling files only `import`ed.

Legend: `[x]` migrated & committed · `[ok]` already conformant (verified, no
action needed)

## Tools (`modules/home/programs/terminal/tools/`)

- [x] agentapi
- [x] aider
- [x] atuin
- [x] bat
- [x] bitwarden-cli
- [x] bottom
- [x] carapace
- [x] eza
- [x] fzf
- [x] git
- [x] k9s
- [x] lazygit
- [x] lazydocker
- [x] litellm
- [x] lsd
- [ok] nh
- [x] ollama
- [x] ripgrep
- [x] run-as-service
- [ok] ssh
- [x] starship
- [ok] tmux
- [x] yazi
- [ok] zellij
- [x] zoxide

## Shells (`modules/home/programs/terminal/shells/`)

- [x] bash
- [x] fish
- [x] nu-shell
- [x] zsh
- [ok] shells/default (pure-data)

## Suites (`modules/home/suites/`)

- [ok] common
- [ok] development

## Desktop (`modules/home/programs/desktop/`)

- [x] sketchybar
- [x] aerospace

## Darwin (`modules/darwin/`)

- [x] darwin/programs/terminal/shells
- [x] darwin/user
- [x] darwin/suites/common
- [x] darwin/tools/homebrew

## Common (`modules/common/`)

- [x] common/nix
- [x] common/suites/common
- [ok] home/theme (pure-data reference)
- [ok] home/user (foundational reference)
- [x] home/system/xdg
