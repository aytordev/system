# Custom Packages

Portable, nixpkgs-compatible package derivations for this flake. Each
directory under `packages/` is auto-discovered and built for the current
platform by `flake/packages/default.nix`.

## Available Packages

| Package | Description | Platforms |
| --- | --- | --- |
| `engram` | Persistent memory MCP server for AI coding agents (Gentleman-Programming) | linux + darwin (x86_64/aarch64) |
| `impeccable-engine` | Official Impeccable engine 0.1.6, byte-preserved release binary | aarch64-darwin + x86_64-linux |
| `impeccable-skills` | Complete upstream Impeccable Pi skill 4.4.0 with sibling engine | aarch64-darwin + x86_64-linux |
| `luaposix` | Lua 5.5-compatible `luaposix` build (upstream rockspec upper bound patched) | per nixpkgs |
| `pen-dev` | Pen canvas app (rebranded Pencil; dmg → `/Applications`) | aarch64-darwin only |
| `sketchybar-app-font` | Ligature icon font + `icon_map.lua` for Sketchybar | per nixpkgs |

## Impeccable: faithful upstream bundle

Both `impeccable-{engine,skills}/package.nix` files are direct-import adapters.
The [AI skill catalog](../modules/common/ai-tools/catalog.nix) owns the upstream
skill/engine versions, source revision, hashes, and dependency relationship;
[private recipes](../modules/common/ai-tools/upstream/impeccable/) prepare the
packages without Home Manager. Keep these adapters thin so `callPackage` can
inspect the imported functions. No loader or overlay changes are needed.

`impeccable-skills/share/impeccable` contains all 54 upstream files (including
42 references), unchanged, from the catalog-pinned `pbakaus/impeccable` source.
No flake input, local metadata, frontmatter edits, or launcher wrappers are added.

The only additions inside the skill are upstream root `LICENSE` and `NOTICE.md`
and a link to engine 0.1.6 under the launcher's supported
`scripts/bin/<platform>/impeccable` path. Copy the **whole skill directory**,
dereferencing links when distributing it outside the Nix store, to retain the
engine, resources, and applicable notices. The original `/bin/sh` shebang and
release executable bytes are preserved by disabling fixups.

| Nix platform | Official `engine-v0.1.6` asset |
| --- | --- |
| `aarch64-darwin` | `impeccable-darwin-arm64` |
| `x86_64-linux` | `impeccable-linux-x64` |

The exact hashes live in `catalog.nix`, not in these public adapters.

These are fixed-hash downloads from the official GitHub release, not local
engine builds. Inspection with `file` identifies Linux as x86-64 static PIE;
Darwin is arm64 Mach-O and `otool -L` lists Security, CoreFoundation, libiconv,
and libSystem dependencies. Linux runtime verification still requires a Linux
builder; evaluating its derivations or inspecting its binary is not execution.

`integration-impeccable` checks thin adapters, standalone recipe arguments,
adapter/private-function identity parity on both platforms, source fidelity,
exact permitted additions, both platform pins, bundled resources, and
`engine-probe` from both the store
bundle and an isolated dereferenced copy. It uses an empty temporary HOME and
failing network/PATH fallback fixtures: no cache, engine override, or download
is needed. It does not run initialization, updates, or browser operations.

```bash
nix build path:.#checks.aarch64-darwin.integration-impeccable --override-input secrets path:./checks/fixtures/secrets --no-write-lock-file --no-link
```

Packaging alone does not publish or activate this skill. Do not run an upstream
updater against Nix-owned files; manually update the skill/engine pins and hashes
in the catalog together, preserving their compatibility and all notices. See
[skill ownership and updates](../modules/common/ai-tools/README.md#skill-ownership-and-updates).

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
