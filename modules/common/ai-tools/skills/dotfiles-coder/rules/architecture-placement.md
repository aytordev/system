## Home Module Categories

**Impact:** HIGH

Organize user modules (Home Manager) into semantic categories: `programs/terminal/`, `programs/desktop/`, `services/`, `suites/`, `theme/`, `system/`, `user/`, or `host/`. The auto-discovery system expects this structure.

**Incorrect (Flat Structure):**

```nix
# Everything dumped in modules/home/
# modules/home/firefox.nix
# modules/home/git.nix
# modules/home/yabai.nix
# No distinction between GUI, CLI, services
```

**Correct (Semantic Categories):**

```nix
# modules/home/
# ├── programs/
# │   ├── desktop/          # GUI: browsers, editors, tools
# │   │   └── browsers/firefox/default.nix
# │   └── terminal/         # CLI: editors, shells, tools
# │       └── tools/git/default.nix
# ├── services/             # User services
# ├── suites/               # Grouped functionality
# ├── theme/                # Pure-data theming
# ├── system/               # User-level system config
# ├── user/                 # User identity metadata
# └── host/                 # Host identity metadata

# Correct: terminal tool in the right category
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.terminal.tools.git;
in
{
  options.aytordev.programs.terminal.tools.git = {
    enable = lib.mkEnableOption "git";
    package = lib.mkPackageOption pkgs "git" {};
  };

  config = lib.mkIf cfg.enable {
    programs.git.enable = true;
    inherit (cfg) package;
  };
}
```
