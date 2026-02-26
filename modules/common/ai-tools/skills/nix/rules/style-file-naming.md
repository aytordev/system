## File Naming

**Impact:** MEDIUM

Use `kebab-case` for all files and directories. This is standard in the Nix community and avoids case-sensitivity issues on some filesystems.

**Incorrect (Camel or Snake):**

```nix
# File structure:
# modules/home/myApp/default.nix
# modules/nixos/services/my_service.nix
# modules/darwin/programs/MyProgram/config.nix

# Inconsistent naming across the codebase
```

**Correct (kebab-case):**

```nix
# File structure:
# modules/home/programs/my-app/default.nix
# modules/nixos/services/my-service.nix
# modules/darwin/programs/my-program/config.nix

# Consistent, readable, and avoids filesystem issues
{
  imports = [
    ./modules/home/programs/my-app
    ./modules/nixos/services/my-service
  ];
}
```
