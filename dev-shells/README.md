# Dev Shells

Per-project development environments provided by the flake. Each directory is
auto-discovered and exposed as `devShells.<system>.<name>`. Use with
`nix develop .#<name>` or `direnv`.

## Available Shells

| Shell | Stack |
| --- | --- |
| `default` | Generic tools (git, htop, etc.) |
| `nix` | Nix tooling + just runner |
| `python` | Python 3.13 + `uv` |
| `python-314` | Python 3.14 + `uv` only (no shared tools or Git hook installation) |
| `node-22-lts` | Node.js 22 LTS + yarn/pnpm |
| `node-24-lts` | Node.js 24 LTS + yarn/pnpm |
| `node-26` | Node.js 26 + yarn/pnpm |
| `node-26-minimal` | Catalog Node.js 26 + yarn/pnpm, without shared tools or Git hook installation |
| `java-25` | Java 25 LTS + Maven + Gradle |
| `java-21` | Java 21 LTS + Maven + Gradle |
| `java-17` | Java 17 LTS + Maven + Gradle |
| `astro-hono` | Astro + Hono + Bun, pnpm workspaces, TypeScript + LSP |
| `react` | Node 22 + pnpm/yarn/bun, TypeScript + LSP |
| `brain` | Bun only (direct `mkShellNoCC`, no shared wrapper) |

The language shells listed above do not carry their own toolchain. The versions
and build tools come from the pure-data catalog in `modules/common/languages`, so
`java-21` and the Java language pack always agree. See
[ADR-0018](../docs/decisions/0018-language-pack-class.md).

The `brain`, `python-314` and `node-26-minimal` shells use direct `pkgs.mkShellNoCC`
rather than the shared wrapper. They expose only their declared toolchains and do
not install system-repository Git hooks in consuming projects. Python and Node
still come from the language catalog; projects retain their own lint/format policy.

## Usage

```bash
nix develop .#react          # enter a shell
nix develop .#python --command "uv run my.py"   # run a command
nix develop .#python-314    # Python 3.14 and uv from the language catalog
nix develop .#node-26-minimal # Node 26 toolchain without consumer hook injection
```

Except for the direct minimal shells listed above, shells share a common wrapper
(`flake/dev/dev-shells`) that injects common
tools and installs local pre-commit hooks in the consuming Git checkout on shell
entry, including on Darwin. The `pkgs.pre-commit` package itself is injected only
on Linux; the installation script can still create hooks on Darwin.

## Adding a New Shell

1. Create `dev-shells/{name}/default.nix` using `mkShell`.
2. It is auto-discovered — no loader edits required.
3. Verify: `nix develop .#<name> --command echo ok`

See `AGENTS.md` in this directory for the full structure and template.
