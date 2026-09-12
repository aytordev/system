# Common Modules Context

Cross-platform shared modules used by both NixOS and nix-darwin systems.

## Module Contract V1

- Classify each module as foundational, capability, platform adapter, suite,
  archetype, or pure data before adding outputs.
- Shared capabilities expose `aytordev.*.enable` and a replaceable `package`
  when they own a primary package.
- Keep shared behavior platform-neutral. Platform adapters belong under
  `modules/darwin/` (or a future `modules/nixos/`).
- Suites compose with `lib.mkDefault`; they never use `lib.mkForce`.
- Do not place host identity, secret values, or concrete home paths in reusable
  modules.

See `docs/decisions/0008-module-contract-v1.md` for the complete contract. The
canonical module template (per-class variants + style rules) lives in the
**`dotfiles-coder` skill**
(`modules/common/ai-tools/skills/dotfiles-coder/rules/patterns-module.md`).

## Module Categories

### AI Tools (`ai-tools/`)

Code agents, slash commands, and skills for this repository.

**Patterns:**

- Agents: Specialized sub-agents for complex tasks (Nix refactor, module
  scaffolding, etc.)
- Commands: Slash commands that expand to prompts (`/nix-check`,
  `/commit-changes`, etc.)
- Skills: Reusable skill definitions

**When adding new agents/commands/skills:**

- Follow existing pattern in `agents/`, `commands/`, or `skills/`
- Export via `commands.nix`/`agents.nix`/skill directory
- Document in `ai-tools/AGENTS.md` Current Inventory
- The `unit-ai-tools-inventory` check fails if the documented inventory
  diverges from the on-disk tree (`skills/*/SKILL.md`, `commands/*/*.nix`,
  `agents/*/*.nix`), so the doc can never go stale silently.

### Nix (`nix/`)

A cross-platform capability module that configures the Nix daemon/install
(not lib helpers). It owns `aytordev.nix`, gated on `mkIf cfg.enable`:

- `enable` — whether to apply the common Nix configuration.
- `package` — the Nix instance to use (replaceable; defaults to nixpkgs
  `nixVersions.latest`).
- `extraTrustedUsers` — additional users allowed and trusted by the Nix daemon.

It applies `nix.settings` (sandbox, gc, optimise, trusted users, experimental
features, etc.) and installs essential CLI packages.

### programs (`programs/`)

Application configurations shared across platforms.

**Patterns:**

- Generic configs that work on both NixOS and macOS
- Terminal tools, shells, editors
- Platform-specific overrides in `modules/darwin/programs/` (or a future
  `modules/nixos/programs/`)

### Suites (`suites/`)

Configuration bundles that enable multiple related modules.

**Examples:**

- `common`: Base system tools and utilities shared by both platforms

**Pattern:**

```nix
{
  aytordev.suites.common.enable = true;
  # Enables: git, ssh, essential CLI tools, etc.
}
```

### System (`system/`)

System-level shared configuration (fonts, localization, etc.).

**Patterns:**

- Shared fonts and system settings consumed across programs
- Cross-platform defaults that platforms can override

## Theming

**Prefer module-specific theme customizations over default application themes.**

The pure-data theme module (`modules/home/theme`) is the single source of
truth. When adding themed elements:

1. Generate colors from the semantic palette (`config.aytordev.theme.palette`)
   so the app follows every family and variant automatically.
2. Resolve named native themes through `lib.aytordev.resolveApp`; never branch
   on variant names or hardcode hex values.
3. If the app needs a native theme resource (extension, flavor, plugin),
   declare it once in the provider's `integrations` (the single source of
   native resources) with `source.provenance`
   (`official-upstream`/`community-port`), a concrete pinned
   `source.ref.{url,rev}`, an SRI `hash` when the resource is `vendored`, the
   exact per-variant `id` and a `complete` flag. Resolve through
   `lib.aytordev.resolveApp` with the policy **explicit override > official
   exact (app + family + variant) > generated fallback > none**, otherwise
   leave the app default and expose a nullable `theme` override.

See `modules/common/ai-tools/skills/dotfiles-coder/rules/specialization-themes.md`,
the [theme guide](docs/theme-system.md), the generated
[support matrix](docs/theme-support-matrix.md),
[ADR-0010](docs/decisions/0010-multi-family-theme-providers.md),
[ADR-0011](docs/decisions/0011-native-theme-resources.md) and
[ADR-0012](docs/decisions/0012-theme-resolution-policy.md).

## Option Design

All options follow `aytordev.{category}.{subcategory}.{option}` structure.

**Example:**

```nix
aytordev.programs.terminal.tools.opencode.enable = true;
```

**Reduce repetition:**

```nix
# Good: Shared pure data
config.aytordev.theme.palette.accent.hex

# Bad: Duplicating palette values in every module
```
