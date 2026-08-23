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

See `docs/decisions/0008-module-contract-v1.md` for the complete contract.

## Module Categories

### AI Tools (`ai-tools/`)

Code agents, slash commands, and skills for this repository.

**Patterns:**

- Agents: Specialized sub-agents for complex tasks (Nix refactor, module
  scaffolding, etc.)
- Commands: Slash commands that expand to prompts (`/nix-check`,
  `/commit-changes`, etc.)
- Skills: Reusable skill definitions

**When adding new agents/commands:**

- Follow existing pattern in `agents/` or `commands/`
- Export via `default.nix`
- Document in `ai-tools/AGENTS.md`

### Nix Utilities (`nix/`)

Nix language helpers, custom lib functions, and build utilities.

**Patterns:**

- Pure functions for configuration generation
- Reusable abstractions to reduce repetition
- Use `lib.` prefix for all lib functions

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

When adding themed elements:

1. Check the pure-data theme module (`modules/home/theme`) for the palette and
   variant helpers first.
2. Use conditional paths based on the active theme variant:
   `if config.aytordev.theme.variant == "wave" then ...`
3. Fallback to an application default only when no aytordev theme option exists.

## Option Design

All options follow `aytordev.{category}.{subcategory}.{option}` structure.

**Example:**

```nix
aytordev.programs.terminal.tools.claude-code.enable = true;
```

**Reduce repetition:**

```nix
# Good: Shared pure data
config.aytordev.theme.palette.accent.hex

# Bad: Duplicating palette values in every module
```
