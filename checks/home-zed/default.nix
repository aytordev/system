{
  inputs,
  lib,
  pkgs,
  ...
}: let
  # Evaluate the pinned, real HM modules; never build or activate the home.
  package = pkgs.runCommand "zed-fixture" {meta.mainProgram = "fixture-zed";} ''
    mkdir -p "$out/bin"
    printf '#!/bin/sh\nexit 0\n' > "$out/bin/fixture-zed"
    chmod +x "$out/bin/fixture-zed"
  '';
  evaluate = evaluateWith null;
  evaluateWith = homeModules: extra:
    (inputs.self.lib.system.mkHome {
      inherit homeModules;
      username = "zed-test";
      hostname = "zed-test";
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        {
          home = {
            username = "zed-test";
            homeDirectory =
              if pkgs.stdenv.hostPlatform.isDarwin
              then "/Users/zed-test"
              else "/home/zed-test";
            stateVersion = "25.11";
          };
          aytordev.programs.desktop.editors.zed = {
            enable = lib.mkDefault true;
            inherit package;
          };
        }
        extra
      ];
    }).config;
  base = evaluate {};
  multiplexed = evaluate {
    aytordev.programs.terminal.tools.zellij.enable = true;
    programs.zed-editor.mutableUserSettings = false;
  };
  tmuxTerminal = evaluate {
    aytordev.programs.desktop.editors.zed.terminal.multiplexer = "tmux";
    aytordev.programs.terminal.tools.tmux.enable = true;
    programs.zed-editor.mutableUserSettings = false;
  };
  systemTerminal = evaluate {
    aytordev.programs.desktop.editors.zed.terminal.multiplexer = "system";
    aytordev.programs.terminal.tools = {
      zellij.enable = true;
      tmux.enable = true;
    };
    programs.zed-editor.mutableUserSettings = false;
  };
  fallbackTerminal = evaluate {
    aytordev.programs.terminal.tools.zellij.enable = false;
    programs.zed-editor.mutableUserSettings = false;
  };
  tmuxFallback = evaluate {
    aytordev.programs.desktop.editors.zed.terminal.multiplexer = "tmux";
    aytordev.programs.terminal.tools = {
      tmux.enable = false;
      zellij.enable = true;
    };
  };
  nullTmux = evaluate {
    aytordev.programs.desktop.editors.zed.terminal.multiplexer = "tmux";
    aytordev.programs.terminal.tools.tmux = {
      enable = true;
      package = null;
    };
  };
  absentCapabilities = evaluateWith [
    ../../modules/home/theme
    ../../modules/home/programs/desktop/editors/zed
  ] {};
  terminalOverride = evaluate {
    aytordev.programs.terminal.tools.zellij.enable = true;
    programs.zed-editor.userSettings.terminal.shell.program = lib.getExe package;
  };
  # The real generated settings keep the actual selected package references.
  terminalHomes = {
    default = multiplexed;
    tmux = tmuxTerminal;
    system = systemTerminal;
    fallback = fallbackTerminal;
  };
  sessionFactories =
    lib.genAttrs ["zellij" "tmux"] (name:
      import (../../modules/home/programs/terminal/tools + "/${name}/session.nix") {inherit lib;});
  sessionFor = name: home:
    sessionFactories.${name}.build {
      inherit pkgs;
      inherit (home.aytordev.programs.terminal.tools.${name}) package;
    };
  # Independent of HM's composed shell value: construct the helpers directly
  # and pin the executable names, while fallback cases require a literal string.
  expectedTerminalShells = {
    default.program = "${sessionFor "zellij" multiplexed}/bin/zellij-session";
    tmux.program = "${sessionFor "tmux" tmuxTerminal}/bin/tmux-session";
    system = "system";
    fallback = "system";
  };
  # Execute wrappers against a harmless argument recorder, never a TTY/server.
  recorder = pkgs.writeShellScriptBin "multiplexer-recorder" ''
    printf '%s\n' "$@"
  '';
  sessionFixtures = lib.mapAttrs (_: factory:
    factory.build {
      inherit pkgs;
      package = recorder;
    })
  sessionFactories;
  custom = evaluate {
    programs.zed-editor.userSettings = {
      which_key.delay_ms = 250;
      languages.Python.language_servers = ["custom-python"];
      buffer_font_size = 20;
    };
  };
  additions = [
    {
      context = "OwnedTest";
      bindings."ctrl-t" = "workspace::NewFile";
    }
  ];
  added = evaluate {
    programs.zed-editor = {
      extensions = ["test-extension"];
      userKeymaps = lib.mkAfter additions;
    };
  };
  replaced = evaluate {
    programs.zed-editor = {
      extensions = lib.mkForce ["replacement-extension"];
      userKeymaps = lib.mkForce additions;
      userSettings.agent.default_profile = lib.mkForce "user-profile";
      userSettings.telemetry.metrics = lib.mkForce true;
    };
  };
  disabled = evaluate {aytordev.programs.desktop.editors.zed.enable = false;};
  none = evaluate {aytordev.programs.desktop.editors.zed.theme.mode = "none";};
  manual = evaluate {aytordev.programs.desktop.editors.zed.theme = "Custom Theme";};
  generated = evaluate {
    aytordev.theme = {
      name = "sora";
      variant = "light";
    };
  };
  immutable = evaluate {
    programs.zed-editor = {
      mutableUserSettings = false;
      mutableUserKeymaps = false;
      userSettings = {
        which_key.delay_ms = 250;
        languages.Python.language_servers = ["custom-python"];
      };
      extensions = ["test-extension"];
      userKeymaps = lib.mkAfter additions;
    };
  };
  profile = import ../../modules/home/programs/desktop/editors/zed/profile.nix {inherit lib;};
  # Producer-shaped selected profile with genuine integrity hashes. Globals may
  # omit context; repeated scoped blocks must retain their relative positions.
  schemaKeymap = [
    {
      bindings = {
        global = "Global";
        override = "OldGlobal";
        remove = "Remove";
      };
    }
    {
      context = "Editor";
      bindings = {
        first = ["Action" 42];
        override = "Old";
        remove = "Remove";
      };
    }
    {
      context = "Editor && menu";
      bindings.override = "Intervening";
    }
    {
      context = "Editor";
      bindings = {
        last = ["Action" [1 true null]];
        removeLater = "Remove";
      };
    }
    {
      context = null;
      bindings = {
        text = ["Action" "text"];
        boolean = ["Action" true];
        nothing = ["Action" null];
        removeLater = "Remove";
      };
    }
  ];
  schemaProfile = {
    schema = 1;
    target_version = "1.21.0";
    settings = {};
    keymap = schemaKeymap;
  };
  schemaProfileText = builtins.toJSON schemaProfile;
  schemaManifestText = builtins.toJSON {
    schema = 1;
    target_version = "1.21.0";
    source = {
      repository = "jellydn/zed-101-setup";
      revision = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    };
    artifacts."profile.json" = builtins.hashString "sha256" schemaProfileText;
  };
  schemaManifestHash = builtins.hashString "sha256" schemaManifestText;
  schemaSource = profile.validate {
    pointer = {
      schema = 1;
      generation = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-${schemaManifestHash}";
      manifest_sha256 = schemaManifestHash;
    };
    manifestText = schemaManifestText;
    profileText = schemaProfileText;
  };
  schemaComposed = profile.compose {
    source = schemaSource;
    excludedBindings = [
      {
        context = null;
        chords = ["remove" "removeLater"];
      }
      {
        context = "Editor";
        chords = ["remove" "removeLater"];
      }
    ];
    ownedKeymaps = [
      {
        bindings = {
          override = ["Owned" false];
          disable = null;
        };
      }
      {
        context = "Editor";
        bindings.override = ["Owned" {new = true;}];
      }
      {
        context = "New";
        bindings.new = "New";
      }
    ];
  };
  schemaExpected = [
    {bindings.global = "Global";}
    {
      context = "Editor";
      bindings.first = ["Action" 42];
    }
    {
      context = "Editor && menu";
      bindings.override = "Intervening";
    }
    {
      context = "Editor";
      bindings = {
        last = ["Action" [1 true null]];
        override = ["Owned" {new = true;}];
      };
    }
    {
      context = null;
      bindings = {
        text = ["Action" "text"];
        boolean = ["Action" true];
        nothing = ["Action" null];
        override = ["Owned" false];
        disable = null;
      };
    }
    {
      context = "New";
      bindings.new = "New";
    }
  ];
  schemaHome = evaluate {
    programs.zed-editor = {
      mutableUserKeymaps = false;
      userKeymaps = lib.mkForce schemaComposed.keymaps;
    };
  };
  firstContext = (builtins.head profile.upstream.keymap).context;
  normalContext = (builtins.elemAt profile.upstream.keymap 1).context;
  sourceEdits = profile.compose {
    excludedBindings = [
      {
        context = firstContext;
        chords = ["g f"];
      }
    ];
    ownedKeymaps = [
      {
        context = firstContext;
        bindings = {
          "space t i" = null;
          "space m p" = ["NewAction" {value = 1;}];
        };
      }
      {
        context = "Last";
        bindings.a = "LastAction";
      }
    ];
  };
  sourceHome = evaluate {programs.zed-editor.userKeymaps = lib.mkForce sourceEdits.keymaps;};
  s = base.programs.zed-editor.userSettings;
  k = base.programs.zed-editor.userKeymaps;
  noForbiddenSettings = value:
    builtins.all (name: !(builtins.hasAttr name value)) [
      "assistant"
      "language_models"
      "agent_servers"
      "context_servers"
      "session"
      "profiles"
      "sandbox"
      "trust_all_worktrees"
      "notification_panel"
      "chat_panel"
      "tasks"
    ];
  succeeds = value: (builtins.tryEval (builtins.deepSeq value value)).value == true;
  tests = {
    defaultZellijTerminal = let
      shell = multiplexed.programs.zed-editor.userSettings.terminal.shell;
    in
      builtins.isAttrs shell
      && lib.hasPrefix "/nix/store/" shell.program
      && lib.hasSuffix "/bin/zellij-session" shell.program;
    tmuxTerminalSelection =
      tmuxTerminal.programs.zed-editor.userSettings.terminal.shell
      == {
        program = lib.getExe (sessionFor "tmux" tmuxTerminal);
      };
    defaultUsesSharedSession =
      multiplexed.programs.zed-editor.userSettings.terminal.shell
      == {
        program = lib.getExe (sessionFor "zellij" multiplexed);
      };
    systemTerminalSelection = systemTerminal.programs.zed-editor.userSettings.terminal.shell == "system";
    disabledCapabilityFallback = builtins.all (home: home.programs.zed-editor.userSettings.terminal.shell == "system") [fallbackTerminal tmuxFallback nullTmux];
    absentCapabilityFallback =
      builtins.all (name: !(lib.hasAttrByPath ["aytordev" "programs" "terminal" "tools" name] absentCapabilities)) ["zellij" "tmux"]
      && absentCapabilities.programs.zed-editor.userSettings.terminal.shell == "system";
    packageLessFallbackHasNoHelpers = builtins.all (
      home:
        home.programs.zed-editor.userSettings.terminal.shell
        == "system"
        && lib.intersectLists ["zellij-session" "tmux-session"] (map lib.getName home.home.packages) == []
    ) [nullTmux absentCapabilities];
    terminalProgramIsDefaultLeaf = terminalOverride.programs.zed-editor.userSettings.terminal.shell.program == lib.getExe package;
    terminalIsolation = builtins.all (
      home:
        home.programs.zed-editor.userSettings.terminal.env.EDITOR
        == "${lib.getExe package} --wait"
        && home.programs.zed-editor.userKeymaps == k
        && builtins.removeAttrs home.programs.zed-editor.userSettings ["terminal"] == builtins.removeAttrs s ["terminal"]
        && home.programs.zed-editor.userTasks == []
        && !(home.home.activation ? zedTasksActivation)
        && !(home.xdg.configFile ? "zed/tasks.json")
        && home.programs.zed-editor.extraPackages == []
        && !(home.home.sessionVariables ? EDITOR)
        && !(home.home.sessionVariables ? SHELL)
    ) (builtins.attrValues terminalHomes);
    sessionPackagesShared =
      builtins.elem (sessionFor "zellij" multiplexed) multiplexed.home.packages
      && builtins.elem (sessionFor "tmux" tmuxTerminal) tmuxTerminal.home.packages;
    zellijAliasesPreserved =
      builtins.intersectAttrs {
        zns = null;
        zas = null;
        zo = null;
      }
      multiplexed.home.shellAliases
      == {
        zns = "zellij-session new";
        zas = "zellij-session attach";
        zo = "zellij-session open";
      };
    producerSchemaAccepted = succeeds (schemaSource == schemaProfile);
    producerCompositionPreserved = succeeds (schemaHome.programs.zed-editor.userKeymaps == schemaExpected);
    auditedKeys = let
      s = base.programs.zed-editor.userSettings;
    in
      !(s ? notification_panel || s ? chat_panel)
      && !(s ? vim.enable_vim_sneak)
      && !(s.agent ? agent_follow)
      && !(s.project_panel ? folder_icons)
      && s.project_panel.folder_indicator == "icon";
    nestedPreferenceOverride = succeeds (
      custom.programs.zed-editor.userSettings.which_key
      == {
        enabled = true;
        delay_ms = 250;
      }
      && custom.programs.zed-editor.userSettings.buffer_font_size == 20
      && custom.programs.zed-editor.userSettings.languages.Python.language_servers == ["custom-python"]
      && custom.programs.zed-editor.userSettings.languages.Python.formatter.language_server.name == "ruff"
    );
    ownedDefaults =
      s.buffer_font_size
      == 18
      && s.ui_font_size == 16
      && s.buffer_font_family == "MonaspiceNe Nerd Font Mono"
      && s.terminal.font_family == s.buffer_font_family
      && s.project_panel.dock == "right";
    privacyPolicy =
      s.telemetry
      == {
        diagnostics = false;
        metrics = false;
      }
      && s.redact_private_values
      && s.agent.default_profile == "ask"
      && s.agent.tool_permissions.default == "confirm";
    explicitSafetyOverride =
      replaced.programs.zed-editor.userSettings.agent.default_profile
      == "user-profile"
      && replaced.programs.zed-editor.userSettings.telemetry.metrics;
    extensionAddition =
      lib.sort builtins.lessThan added.programs.zed-editor.extensions
      == ["kanagawa-themes" "sora-theme" "test-extension"];
    extensionReplacement = replaced.programs.zed-editor.extensions == ["replacement-extension"];
    keymapAddition = added.programs.zed-editor.userKeymaps == k ++ additions;
    keymapReplacement = replaced.programs.zed-editor.userKeymaps == additions;
    keymapSourceEdits = let
      blocks = sourceHome.programs.zed-editor.userKeymaps;
      first = (builtins.head blocks).bindings;
    in
      map (entry: entry.context) blocks
      == [firstContext normalContext "Last"]
      && !(first ? "g f")
      && first ? "space t i"
      && first."space t i" == null
      && first."space m p" == ["NewAction" {value = 1;}]
      && first."space g s" == "git_panel::ToggleFocus";
    keymapUniqueOrder =
      builtins.length k
      == builtins.length (lib.unique (map (entry: entry.context) k))
      && (builtins.head k).context == firstContext
      && (builtins.elemAt k 1).context == normalContext
      && (builtins.elemAt k 2).context == "(EmptyPane || SharedScreen) && !menu && !VimWaiting";
    noUnsafeSourceActions = builtins.all (entry:
      builtins.all (
        action: let
          name =
            if builtins.isList action
            then builtins.head action
            else action;
        in
          name == null || !(lib.hasPrefix "task::" name || lib.hasInfix "fff" name)
      ) (builtins.attrValues entry.bindings))
    k;
    allSelectedBindingsConsumed =
      builtins.all (
        entry: let
          actual = (lib.findFirst (block: block.context == entry.context) null k).bindings;
        in
          builtins.all (chord: actual.${chord} == entry.bindings.${chord}) (builtins.attrNames entry.bindings)
      )
      profile.upstream.keymap;
    disabledOutputs =
      !disabled.programs.zed-editor.enable
      && disabled.programs.zed-editor.userSettings == {}
      && disabled.programs.zed-editor.userKeymaps == []
      && disabled.programs.zed-editor.extensions == []
      && !(builtins.elem package disabled.home.packages)
      && !(disabled.home.activation ? zedSettingsActivation)
      && !(disabled.xdg.configFile ? "zed/themes/aytordev.json");
    packageContract =
      base.programs.zed-editor.package
      == package
      && builtins.elem package base.home.packages
      && s.terminal.env.EDITOR == "${lib.getExe package} --wait"
      && s.terminal.shell == "system";
    noGlobalEditorOrTasks =
      !base.programs.zed-editor.defaultEditor
      && !(base.home.sessionVariables ? EDITOR)
      && !(base.home.sessionVariables ? VISUAL)
      && base.programs.zed-editor.userTasks == []
      && !(base.home.activation ? zedTasksActivation);
    mutableDefaults =
      base.programs.zed-editor.mutableUserSettings
      && base.programs.zed-editor.mutableUserKeymaps
      && base.home.activation ? zedSettingsActivation
      && base.home.activation ? zedKeymapActivation
      && !(base.xdg.configFile ? "zed/settings.json");
    noProviderPolicy =
      noForbiddenSettings s
      && !(s.agent ? default_model || s.agent ? profiles || s.agent ? agent_servers);
    themeOwned =
      s.theme
      == "Kanagawa Dragon"
      && manual.programs.zed-editor.userSettings.theme == "Custom Theme"
      && !(none.programs.zed-editor.userSettings ? theme)
      && !(none.xdg.configFile ? "zed/themes/aytordev.json")
      && generated.xdg.configFile ? "zed/themes/aytordev.json";
    themeExclusion =
      (profile.compose {
        source = {
          settings = {
            theme = "Unowned";
            icon_theme = "Unowned";
          };
          keymap = [];
        };
        inherit ((import ../../modules/home/programs/desktop/editors/zed/preferences.nix {inherit lib package;})) excludedSettings;
      }).settings
      == {};
  };
  failures = builtins.attrNames (lib.filterAttrs (_: pass: !pass) tests);
in
  assert lib.assertMsg (failures == []) "home-zed failed: ${lib.concatStringsSep ", " failures}";
    pkgs.runCommand "home-zed-tests" {nativeBuildInputs = [pkgs.jq];} ''
      # Inspect the actual HM-generated files in the store. Only this fixture is
      # immutable; no activation fragments or live-home mutations are executed.
      settings=${immutable.xdg.configFile."zed/settings.json".source}
      keymap=${immutable.xdg.configFile."zed/keymap.json".source}
      jq -e '
        .which_key == {enabled: true, delay_ms: 250} and
        .languages.Python.language_servers == ["custom-python"] and
        .languages.Python.formatter.language_server.name == "ruff" and
        .auto_install_extensions == {"kanagawa-themes": true, "sora-theme": true, "test-extension": true} and
        .project_panel.folder_indicator == "icon" and
        (.project_panel | has("folder_icons") | not) and
        (.agent | has("agent_follow") | not) and
        (has("vim") | not) and (has("notification_panel") | not) and (has("chat_panel") | not) and
        (has("context_servers") | not) and (has("language_models") | not) and
        .agent.tool_permissions.default == "confirm" and .telemetry.metrics == false and
        .theme == "Kanagawa Dragon"
      ' "$settings"
      jq -e '
        .[0].bindings.space == null and (.[0].bindings | has("space")) and
        .[0].bindings.s == ["vim::PushSneak", {}] and
        .[0].bindings["space a i"] == "assistant::InlineAssist" and
        .[1].bindings["space f f"] == "file_finder::Toggle" and
        .[-1] == {context: "OwnedTest", bindings: {"ctrl-t": "workspace::NewFile"}} and
        ([.[].context] | length == (unique | length))
      ' "$keymap"
      jq -e --slurpfile expected ${pkgs.writeText "zed-schema-expected.json" (builtins.toJSON schemaExpected)} '
        . == $expected[0]
      ' ${schemaHome.xdg.configFile."zed/keymap.json".source}
      mkdir -p "$out"
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: home: ''
          mkdir -p "$out/${name}"
          cp ${home.xdg.configFile."zed/settings.json".source} "$out/${name}/settings.json"
          jq -e --argjson expected ${lib.escapeShellArg (builtins.toJSON expectedTerminalShells.${name})} \
            --arg editor ${lib.escapeShellArg "${lib.getExe package} --wait"} '
            .terminal.shell == $expected and .terminal.env.EDITOR == $editor and
            (has("tasks") | not) and .file_finder == {modal_max_width: "medium"}
          ' "$out/${name}/settings.json"
        '')
        terminalHomes)}

      # Both factories preserve argument boundaries, select the provided binary,
      # default to open, and reject unknown modes without launching a server.
      mkdir -p 'project.name:with space'
      cd 'project.name:with space'
      cwd="$PWD"
      zellij=${lib.getExe sessionFixtures.zellij}
      tmux=${lib.getExe sessionFixtures.tmux}
      test "$("$zellij")" = "$(printf '%s\n' attach --create 'project.name:with space' options --default-cwd "$cwd")"
      test "$("$zellij" open)" = "$("$zellij")"
      test "$("$zellij" new)" = "$(printf '%s\n' -s 'project.name:with space' options --default-cwd "$cwd")"
      test "$("$zellij" attach)" = "$(printf '%s\n' a 'project.name:with space')"
      test "$("$tmux")" = "$(printf '%s\n' new-session -A -s 'project_name_with space' -c "$cwd")"
      test "$("$tmux" open)" = "$("$tmux")"
      test "$("$tmux" new)" = "$(printf '%s\n' new-session -s 'project_name_with space' -c "$cwd")"
      test "$("$tmux" attach)" = "$(printf '%s\n' attach-session -t '=project_name_with space')"
      for helper in "$zellij" "$tmux"; do
        if "$helper" invalid > invalid.out 2> invalid.err; then
          echo "Unexpected success for an invalid session mode" >&2
          exit 1
        else
          status=$?
        fi
        test "$status" -eq 1
        test ! -s invalid.out
        grep -q 'usage:' invalid.err
      done
      echo '${toString (builtins.length (builtins.attrNames tests))} real-HM Zed checks, generated-JSON and session-runtime assertions passed'
    ''
