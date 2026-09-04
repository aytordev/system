# Module Migration Checklist

Canonical module template: `modules/common/ai-tools/skills/dotfiles-coder/rules/patterns-module.md`
Contract: `docs/decisions/0008-module-contract-v1.md`

Goal: converge every module on the canonical shape — `options`/`config`
separation, `cfg` binding, `lib.mkIf cfg.enable`, `enable` + conditional
`package` (via `lib.mkPackageOption` unless a conditional default needs the
manual form), delegate to `programs.<tool>` when a Home Manager module exists
(no redundant `home.packages`), `lib.getExe` for aliases/wrappers, shell
integration as `aytordev.*` options defaulting to `shellEnabled`, platform
guards `pkgs.stdenv.hostPlatform.isDarwin/isLinux`, no `with lib;`/`if-then-else`
for conditions, sibling files only `import`ed.

Legend: `[x]` migrated & committed · `[~]` in progress · `[ ]` pending ·
`[ok]` already conformant (verified, no action needed)

## Tools (`modules/home/programs/terminal/tools/`)

- [ ] agentapi
- [ ] aider
- [ ] atuin
- [ ] bat
- [ ] bitwarden-cli
- [x] bottom
- [x] carapace
- [ ] eza
- [ ] fzf
- [x] git
- [x] k9s
- [x] lazygit
- [ ] lazydocker
- [ ] litellm
- [x] lsd
- [ok] mcp
- [ ] nh
- [ ] ollama
- [ok] opencode
- [x] ripgrep
- [x] run-as-service
- [ok] ssh
- [ ] starship
- [ok] tmux
- [x] yazi
- [ ] zellij
- [ ] zoxide

## Shells (`modules/home/programs/terminal/shells/`)

- [ ] bash
- [ ] fish
- [ ] nu-shell
- [ ] zsh
- [ok] shells/default (pure-data)

## Suites (`modules/home/suites/`)

- [ok] common
- [ok] development

## Desktop (`modules/home/programs/desktop/`)

- [ ] sketchybar
- [ ] aerospace

## Darwin (`modules/darwin/`)

- [ ] darwin/programs/terminal/shells
- [ ] darwin/user
- [ ] darwin/suites/common
- [ ] darwin/tools/homebrew

## Common (`modules/common/`)

- [ ] common/nix
- [ ] common/suites/common
- [ok] home/theme (pure-data reference)
- [ok] home/user (foundational reference)
- [ ] home/system/xdg
