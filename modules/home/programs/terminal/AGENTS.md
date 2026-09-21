# Terminal Programs

CLI tools, shells, emulators, and editors exposed under
`aytordev.programs.terminal.*`. This is the largest home manager category and
has the most conventions.

## Categories

```
terminal/
├── tools/       # CLI tools and utilities (largest; ~50 entries)
├── shells/      # bash, fish, nu-shell, zsh
├── emulators/   # ghostty
└── editors/     # neovim
```

## Directory Layout per Tool

`tools/{tool}/` (and `shells/{shell}/`, `emulators/{emulator}/`) owns the
namespace `aytordev.programs.terminal.{category}.{tool}`.

Large tools may use contained sibling files (see opencode, bitwarden-cli).
The directory's `default.nix` remains the only auto-discovered module and owns
the option namespace; containment files are `import`ed from it.

## Option Namespace

- category: `tools` | `shells` | `emulators` | `editors`
- tool: kebab-case directory name

```nix
aytordev.programs.terminal.tools.gh.enable = true;
aytordev.programs.terminal.shells.zsh.enable = true;
```

## Module Contract V1

Each tool is a capability module:

- Owns **one** program or user service; exposes `enable` and a replaceable
  `package` when it owns a package.
- Guards every output with `lib.mkIf cfg.enable` (or `lib.mkIf` on the relevant
  subfeature).
- Platform-only outputs use `pkgs.stdenv.hostPlatform.isDarwin`/`isLinux`
  guards — never deprecated `pkgs.stdenv.isDarwin`.

See `docs/decisions/0008-module-contract-v1.md`.

## Common Recurring Patterns

### Shell Aliases

Short aliases live in `home.shellAliases`. When a tool provides several
commands, prefer shell-agnostic aliases there (one entry per alias behaves the
same in bash/zsh/fish/nushell). For per-shell concerns, use the shell-specific
integration options instead (see bitwarden-cli, opencode).

Rules for `home.shellAliases` values (they fan out to every shell, and nushell
renders them verbatim):

- Must be a single, simple command. A value containing `;`, `$(`, `command `,
  `|`, `&&`, `||`, or a newline breaks or silently misbehaves in nushell.
- Never define the same alias again in a `bash/conf.d/*.sh` drop-in — it is
  sourced first and then overridden, so it is dead (or diverges).
- If the behavior needs command substitution, a pipeline, or args/logic, put it
  in a `writeShellApplication`/`writeShellScriptBin` bin and make the alias a
  thin forward (or skip the alias; the bin name can equal the command name).
- If the shell integration for a tool already defines the command (e.g.
  `programs.lazygit`'s `lg`), do not add a manual alias that would shadow it.

### Shell Integration

When a tool offers shell integration, expose it as `aytordev.*` options that
default to `(lib.aytordev.shellIntegration config).shellEnabled "<shell>"`, then
pass them through to the Home Manager module (see atuin, starship). If you merge
the `enable*Integration` flags directly with
`// (lib.aytordev.shellIntegration config).flags`, add a comment proving every
flag is valid (see carapace, zoxide). Some tools intentionally exclude a shell —
eza keeps nushell's built-in `ls`.

### `writeShellScript` / `writeShellApplication` Helpers

Tools that need a runtime wrapper use `pkgs.writeShellScript{,Bin}` or
`pkgs.writeShellApplication`, stored path referenced through `lib.getExe`.
Prefer `writeShellApplication` for strict `set -euo pipefail` and shellcheck.

Examples in repo:

- run-as-service: sources `hm-session-vars.sh` from the active generation.
- bitwarden-cli: shell wrappers plus a scoped pinentry adapter.
- gh/hcloud: runtime credential wrappers that read token files and exec the
  real binary.

### Services (User)

Long-running user daemons use Home Manager unit form:

- launchd agents on macOS
- `systemd.user.services` on Linux

When a tool is service-capable, keep the service in the same directory
(`service.nix`) and expose `cfg.service.enable`/`autoStart` when applicable.
Runtime cacheable services load secret files at start, not build
time.

### Runtime Secrets

Tools that authenticate at runtime read credentials from individual secret
files and fail with a named error when the file is unreadable. Never export
token values into `home.sessionVariables` (they become visible in the env of
every child process).

Example contract: `checks/home-identity` asserts secrets are file-based and
wrappers fail closed without real tokens in env.

### Runtime-Managed Agent Integrations

Pi is package-only. The official `gentle-ai install --agent pi` owns its native
profile, Shell package/private engine, extensions, and workflow. Nix owns the
public CLI, Pi, Engram, Node/npm, and runtime environment. The separate guarded
shared `modules/common/ai-tools/ai-skills.nix` capability exports four self-contained folders at
`$XDG_DATA_HOME/aytordev/skills` even without clients, plus recursive file links
for enabled Pi/OpenCode clients; never link a whole client profile or skills root. See
`modules/common/ai-tools/README.md` for onboarding and updater ownership.

Some tools ship integrations that write into *another* app's config at runtime
and own those files. Never vendor them in Nix: a store symlink would block the
tool's own installer and updater, and the artifact is versioned to the tool.

herdr is the reference case (see `tools/herdr`). `herdr integration install
opencode` writes `~/.config/opencode/plugins/herdr-agent-state.js`,
`~/.config/opencode/herdr-tui-session.js`, and `~/.config/opencode/tui.jsonc`.
OpenCode auto-loads the plugin directory and merges `tui.json` with
`tui.jsonc`, so the Home-Manager-managed `tui.json` (theme) and herdr's plugin
coexist. Keep the runtime targets (`opencode/plugins`, `tui.jsonc`) out of the
managed set.

## Platform Notes

- Some tools are macOS/GUI-specific (sketchybar, ghostty). Keep generic config
  cross-platform when the tool exists on both.
- gh/hcloud/bitwarden use `GH_TOKEN`, `HCLOUD_TOKEN`, or API-key file paths as
  host values, i.e. set at host/home boundary, not in shared modules.

## Adding a New Tool

1. Create `tools/{tool}/default.nix`.
2. Define `aytordev.programs.terminal.tools.{tool}` with `enable` + `package`.
3. Guard outputs with `mkIf`.
4. If needed, split helpers into contiguous `*.nix` files and `import` them.
5. Wire integrations through `lib.aytordev.shellIntegration config` (so they
   follow `enabledNames`). Add shell aliases as shell-agnostic strings in
   `home.shellAliases` — never duplicate them in a bash `conf.d` drop-in, and
   put logic/pipelines in a `writeShellApplication`/`writeShellScriptBin` bin
   with a thin forward. Add a check under `checks/` when the behavior deserves
   regression coverage (example: `checks/home-module` covers opencode/pi
   wiring).

## Testing Terminal Changes

```bash
nix flake check --no-build        # evaluation-only
nix build .#homeConfigurations.aytordev@wang-lin.activationPackage --no-link
```
