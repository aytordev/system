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
| `astro-hono` | Astro + Hono + Bun, pnpm workspaces, TypeScript + LSP |
| `react` | Node 22 + pnpm/yarn/bun, TypeScript + LSP |

## Usage

```bash
nix develop .#react          # enter a shell
nix develop .#python --command "uv run my.py"   # run a command
```

All shells share a common wrapper (`flake/dev/devshells`) that injects common
tools and handles pre-commit integration. Pre-commit hooks are disabled on
Darwin due to a broken Swift dependency in nixpkgs.

## Adding a New Shell

1. Create `dev-shells/{name}/default.nix` using `mkShell`.
2. It is auto-discovered — no loader edits required.
3. Verify: `nix develop .#<name> --command echo ok`

See `AGENTS.md` in this directory for the full structure and template.
