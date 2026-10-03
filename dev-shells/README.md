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
| `node-22-lts` | Node.js 22 LTS + yarn/pnpm |
| `node-24-lts` | Node.js 24 LTS + yarn/pnpm |
| `node-26` | Node.js 26 + yarn/pnpm |
| `java-25` | Java 25 LTS + Maven + Gradle |
| `java-21` | Java 21 LTS + Maven + Gradle |
| `java-17` | Java 17 LTS + Maven + Gradle |
| `astro-hono` | Astro + Hono + Bun, pnpm workspaces, TypeScript + LSP |
| `react` | Node 22 + pnpm/yarn/bun, TypeScript + LSP |

The language shells listed above do not carry their own toolchain. The versions
and build tools come from the pure-data catalog in `modules/common/languages`, so
`java-21` and the Java language pack always agree. See
[ADR-0018](../docs/decisions/0018-language-pack-class.md).

## Usage

```bash
nix develop .#react          # enter a shell
nix develop .#python --command "uv run my.py"   # run a command
```

All shells share a common wrapper (`flake/dev/dev-shells`) that injects common
tools and handles pre-commit integration. Pre-commit hooks are disabled on
Darwin due to a broken Swift dependency in nixpkgs.

## Adding a New Shell

1. Create `dev-shells/{name}/default.nix` using `mkShell`.
2. It is auto-discovered — no loader edits required.
3. Verify: `nix develop .#<name> --command echo ok`

See `AGENTS.md` in this directory for the full structure and template.
