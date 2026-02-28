## Auto-Discovery

**Impact:** MEDIUM

Modules are automatically imported via `importModulesRecursive`. Never add manual imports for modules already in the discovery tree. Just place the file correctly and enable it via options.

**Incorrect (Manual Imports):**

```nix
# Adding explicit imports for auto-discovered modules
{ ... }:
{
  imports = [
    ../../modules/home/programs/terminal/tools/git/default.nix
    ../../modules/home/programs/graphical/browsers/firefox/default.nix
  ];

  # These are already auto-discovered!
}
```

**Correct (Option Enablement):**

```nix
# Just enable the module - it's already imported
{ ... }:
{
  aytordev.programs.terminal.tools.git.enable = true;
  aytordev.programs.graphical.browsers.firefox.enable = true;

  # Only use manual imports for modules/common/ from platform modules
}
```
