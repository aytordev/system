# Custom Packages

Portable, nixpkgs-compatible package derivations for this flake. Each
directory under `packages/` is auto-discovered and built for the current
platform by `flake/packages/default.nix`.

## Available Packages

| Package | Description | Platforms |
| --- | --- | --- |
| `agentapi` | Coder's agent API binary (`agentapi` MCP/agent bridge) | linux + darwin (x86_64/aarch64) |
| `engram` | Persistent memory MCP server for AI coding agents (Gentleman-Programming) | linux + darwin (x86_64/aarch64) |
| `luaposix` | Lua 5.5-compatible `luaposix` build (upstream rockspec upper bound patched) | per nixpkgs |
| `pencil-dev` | Pencil dev macOS app (dmg → `/Applications`) | aarch64-darwin only |
| `sketchybar-app-font` | Ligature icon font + `icon_map.lua` for Sketchybar | per nixpkgs |

## How They Are Exposed

Packages are exposed in two ways:

1. **`flake.overlays.default`** — injects `pkgs.aytordev.<name>` into any
   consumer that applies the overlay:

   ```nix
   home.packages = [ pkgs.aytordev.engram ];
   ```

2. **`flake.packages.<system>.<name>`** — directly addressable for `nix run`
   / `nix build`:

   ```bash
   nix run .#packages.aarch64-darwin.engram
   nix build .#packages.x86_64-linux.sketchybar-app-font
   ```

Only packages whose `meta.platforms` (or null) match the current system are
exposed for that system.

## Structure

```
packages/
└── {name}/
    └── package.nix     # derivation; auto-discovered
```

## When to Add a Package

- A completely custom derivation used in this config (wallpapers, scripts,
  fetched binaries, wrappers).
- A package that cannot be expressed as an overlay of an existing nixpkgs
  package.

Prefer an **overlay** (in `overlays/`) when you only need to override or patch
an existing nixpkgs package.

## Adding a New Package

1. Create `packages/{name}/package.nix` with a standard derivation.
2. Set `meta.platforms` if it does not build everywhere.
3. Verify:

   ```bash
   nix build .#packages.$(nix eval --raw --impure --expr 'builtins.currentSystem').{name} --no-link
   ```
