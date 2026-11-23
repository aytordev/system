# Dev Shells

Per-project development environments provided by the flake. Each directory is
auto-discovered and exposed as `devShells.<system>.<name>`. Use with
`nix develop .#<name>` or `direnv`.

## Available Shells

| Shell | Stack |
| --- | --- |
| `default` | Generic tools (git, htop, etc.) |
| `nix` | Nix tooling + just runner (only shell that installs consumer Git hooks) |
| `python` | Python 3.13 + `uv` |
| `python-314` | Python 3.14 + `uv` only (no shared tools or Git hook installation) |
| `node-22-lts` | Node.js 22 LTS + yarn/pnpm |
| `node-24-lts` | Node.js 24 LTS + yarn/pnpm |
| `node-26` | Node.js 26 + yarn/pnpm |
| `node-27` | Node.js 27 (Current line, pre-release build in nixpkgs) + yarn/pnpm |
| `java-25` | Java 25 LTS + Maven + Gradle |
| `java-21` | Java 21 LTS + Maven + Gradle |
| `java-17` | Java 17 LTS + Maven + Gradle |
| `go` | Go (the single supported nixpkgs toolchain, from the catalog) |

The language shells listed above do not carry their own toolchain. The versions
and build tools come from the pure-data catalog in `modules/common/languages`, so
`java-21` and the Java language pack always agree. See
[ADR-0018](../docs/decisions/0018-language-pack-class.md).

The `python-314` shell uses direct `pkgs.mkShellNoCC` rather than the shared
wrapper. It exposes only its declared toolchain and does not install
system-repository Git hooks in consuming projects. Python still comes from the
language catalog; projects retain their own lint/format policy.

## Usage

```bash
nix develop .#node-27       # enter a shell
nix develop .#python --command "uv run my.py"   # run a command
nix develop .#python-314    # Python 3.14 and uv from the language catalog
just install-hooks          # install the consumer Git hooks (routes to .#nix)
```

Except for `python-314`, shells share a common wrapper
(`flake/dev/dev-shells`) that injects common tools. Git hook installation is
enforced centrally by shell name: the wrapper installs local pre-commit hooks in
the consuming Git checkout on shell entry, including on Darwin, for the shell
named `nix` only. Every other shell keeps the same common tools and touches
nothing in the consumer checkout. The `pkgs.pre-commit` package itself is
injected only on Linux; the installation script can still create hooks on
Darwin.

The `nix` shell installs through a fail-safe guard: when the checkout already
contains a Git hook (for example a managed `pre-push`) or custom hook routing
(a `core.hooksPath` pointing away from the default directory), the installer
skips and leaves those hooks untouched instead of overwriting or disabling
them. Only a clean checkout gets the hooks; `just install-hooks` runs the same
guarded path.

## Adding a New Shell

1. Create `dev-shells/{name}/default.nix` using `mkShell` (Git hook
   installation is decided centrally by shell name; no per-shell opt-out
   exists).
2. It is auto-discovered — no loader edits required.
3. Verify: `nix develop .#<name> --command echo ok`

See `AGENTS.md` in this directory for the full structure and template.
