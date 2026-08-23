# Terminal Programs

CLI tools, shells, emulators, and editors exposed under
`aytordev.programs.terminal.*`. This is the largest home manager category and
has the most conventions.

## Categories

```
terminal/
├── tools/       # CLI tools and utilities (largest; ~50 entries)
├── shells/      # bash, fish, nu-shell, zsh
├── emulators/   # ghostty, warp
└── editors/     # neovim
```

## Directory Layout per Tool

`tools/{tool}/` (and `shells/{shell}/`, `emulators/{emulator}/`) owns the
namespace `aytordev.programs.terminal.{category}.{tool}`.

Large tools may use contained sibling files (see ollama, litellm, opencode,
bitwarden-cli). The directory's `default.nix` remains the only auto-discovered
module and owns the option namespace; containment files are `import`ed from it.

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
integration options instead (see bitwarden-cli, ollama).

### Shell Integration

When a tool offers shell integration, wrap it behind an option and pass owner
/`enable*Integration` flags to Home Manager modules (see atuin, zoxide,
carapace, starship).

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
(`service.nix`) and expose `cfg.service.enable`/`autoStart` (see ollama,
litellm). Runtime cacheable services load secret files at start, not build
time.

### Runtime Secrets

Tools that authenticate at runtime read credentials from individual secret
files and fail with a named error when the file is unreadable. Never export
token values into `home.sessionVariables` (they become visible in the env of
every child process).

Example contract: `checks/home-identity` asserts secrets are file-based and
wrappers fail closed without real tokens in env.

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
5. Wire aliases/integrations through options so the tool stays reusable.
   Add a check under `checks/` when the behavior deserves regression
   coverage (example: `checks/home-module` covers ollama/litellm service wiring).

## Testing Terminal Changes

```bash
nix flake check --no-build        # evaluation-only
nix build .#homeConfigurations.aytordev@wang-lin.activationPackage --no-link
```