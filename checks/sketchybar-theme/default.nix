# Runtime theme manager tests.
# Loads the real helpers/theme.lua with a stubbed nix_constants + sbar and
# asserts apply/follow_nix/palette/persistence behavior, including the
# persistence-failure path that must not report success.
{pkgs, ...}: let
  configDir = ../../modules/home/programs/desktop/bars/sketchybar/config;

  mkHarness = name: body:
    pkgs.writeText "${name}.lua" ''
      package.path = os.getenv("LUA_WORK") .. "/?.lua;" .. os.getenv("LUA_WORK") .. "/?/init.lua;" .. package.path
      sbar = { execs = {}, exec = function(cmd) table.insert(sbar.execs, cmd) end }
      local function check(cond, msg)
        if not cond then error(msg, 2) end
      end
      local theme = require("helpers.theme")
      ${body}
    '';

  successHarness = mkHarness "success" ''
    theme.init()
    check(theme.current == "kanagawa/dragon", "init should use declarative theme")
    check(theme.palette().accent == "0xffaaaaaa", "palette should be declarative")
    check(theme.is_following_nix() == true, "should follow nix initially")

    check(theme.apply("catppuccin/mocha") == true, "apply known theme returns true")
    check(theme.current == "catppuccin/mocha", "current updated after apply")
    check(theme.palette().accent == "0xffbbbbbb", "palette switches after apply")
    check(theme.is_following_nix() == false, "override active after apply")
    check(#sbar.execs == 1, "apply emits exactly one reload")

    local persisted = io.open(os.getenv("HOME") .. "/.config/sketchybar/.theme_variant", "r")
    check(persisted ~= nil, "apply persists the selection to disk")
    if persisted then persisted:close() end

    check(theme.apply("does-not-exist") == false, "apply unknown theme returns false")
    check(theme.current == "catppuccin/mocha", "current unchanged after rejection")
    check(#sbar.execs == 1, "rejection does not reload")

    theme.current = nil
    theme.init()
    check(theme.current == "catppuccin/mocha", "persisted theme survives re-init")

    check(theme.follow_nix() == true, "follow_nix returns true")
    check(theme.is_following_nix() == true, "follow_nix clears override")
    check(theme.current == "kanagawa/dragon", "follow_nix restores declarative theme")
    check(#sbar.execs == 2, "apply + follow_nix emitted two reloads")
  '';

  failureHarness = mkHarness "failure" ''
    check(theme.apply("catppuccin/mocha") == false, "persistence failure must return false")
    check(#sbar.execs == 0, "no reload when persistence fails")
  '';
in
  pkgs.runCommand "sketchybar-theme-tests"
  {
    nativeBuildInputs = [pkgs.lua];
  }
  ''
    export LUA_WORK="$TMPDIR/work"
    mkdir -p "$LUA_WORK/helpers"

    cat > "$LUA_WORK/nix_constants.lua" <<'EOF'
    return {
      colors = { accent = "0xff000000" },
      themes = {
        ["kanagawa/dragon"] = { accent = "0xffaaaaaa" },
        ["catppuccin/mocha"] = { accent = "0xffbbbbbb" },
      },
      active_theme = "kanagawa/dragon",
    }
    EOF

    cp ${configDir}/helpers/theme.lua "$LUA_WORK/helpers/theme.lua"
    cp ${configDir}/helpers/log.lua "$LUA_WORK/helpers/log.lua"

    # Success scenario: HOME has a writable config dir.
    mkdir -p "$TMPDIR/home-success/.config/sketchybar"
    HOME="$TMPDIR/home-success" lua ${successHarness}

    # Failure scenario: HOME exists but has no .config/sketchybar, so the
    # persist write fails. Note: theme.lua resolves PERSIST_FILE at require
    # time, so this must run in a separate process with a different HOME.
    mkdir -p "$TMPDIR/home-failure"
    HOME="$TMPDIR/home-failure" lua ${failureHarness}

    touch "$out"
  ''
