# Custom Library Functions

Reusable Nix functions extending nixpkgs.lib for aytordev-specific patterns.

## Library Structure

```
libraries/
├── default.nix     # Exports flake.lib
├── file/           # File system operations
├── identity/       # Identity normalization from secrets
├── module/         # Module creation utilities
├── overlay/        # Overlay helpers
└── system/         # System/host builders
```

## Core Principles

### 1. Pure Functions

All lib functions must be pure:

- No side effects
- Same inputs always produce same outputs
- No file I/O during evaluation (except via builtins)

### 2. Explicit Function Parameters

Lib functions accept `inputs` parameter and extract needed dependencies:

```nix
{ inputs }:
let
  # Extract only what this lib module needs
  inherit (inputs.nixpkgs.lib) mkOption types mapAttrs;
in
{
  # Function definitions using the inherited values
  myFunction = arg: /* ... */;
}
```

This keeps lib functions self-contained and makes dependencies explicit.

### 3. Namespaced Exports

Export via `flake.lib.{category}`:

```nix
# libraries/default.nix
{
  flake.lib = {
    file = import ./file { inputs = reusableInputs; inherit self; };
    identity = import ./identity {};
    module = import ./module { inputs = reusableInputs; };
    overlay = import ./overlay { inputs = reusableInputs; };
    system = import ./system { inputs = reusableInputs; };
  };
}
```

The `secrets` input is removed before reaching reusable lib code. Only the
normalized `identity` result is passed down.

## Library Categories

- **file**: File operations (getFile, importDir, scanDir, etc.)
- **identity**: Normalizes secret metadata into full/email/username
- **module**: Module helpers (enabled, mkOpt, mkBoolOpt, mkModule,
  shellIntegration)
- **system**: System builders (mkDarwin, mkHome)
- **overlay**: Overlay creation helpers

Function details are documented in the source code.

## Creating New Library Functions

### 1. Choose Category

Determine which category fits your function:

- File operations → `file/`
- Module utilities → `module/`
- System builders → `system/`
- Identity/metadata → `identity/`
- New category → Create new directory

### 2. Write Pure Function

```nix
{ inputs }:
let
  inherit (inputs.nixpkgs.lib) mapAttrs filterAttrs;
in
{
  # Document the function
  # @param arg1 Description of arg1
  # @param arg2 Description of arg2
  # @return Description of return value
  # @example myFunction "a" "b" => "ab"
  myFunction = arg1: arg2:
    # Pure implementation
    # No side effects
    # Deterministic output
    arg1 + arg2;
}
```

### 3. Document Function

Add clear documentation with:

- Brief description of what function does
- Parameter descriptions
- Return value description
- Usage example

### 4. Export in default.nix

```nix
# libraries/default.nix
{
  flake.lib = {
    # Existing categories...
    myCategory = import ./myCategory { inherit inputs; };
  };
}
```

### 5. Test Function

```bash
# Test in nix repl
nix repl
> :lf .
> lib.file.getFile "modules"
/nix/store/.../modules
```

Libs are exposed under `flake.lib` (e.g. `lib.file.*`, `lib.system.*`,
`lib.module.*`); the overlay also surfaces module helpers as `pkgs.aytordev.*`.

## When to Add Library Functions

**Add to lib when:**

- Function is reused across multiple modules
- Logic is complex and benefits from abstraction
- Pattern is common throughout codebase
- Function has no side effects

**Don't add when:**

- Used only once
- Module-specific logic
- Requires side effects
- Better expressed inline

## Common Patterns

### Option Creation

```nix
mkOpt = {...}: lib.mkOption {...};
```

### Safe Import

```nix
safeImport = fileName: ...
```

### Directory Import

```nix
importDir = path: args: ...;
```