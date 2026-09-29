{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  # Pure module evaluation with recursive JSON definition handling. Real pinned
  # HM semantics/artifacts are checked separately in checks/home-zed.
  jsonType = lib.types.nullOr (lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
    (lib.types.listOf jsonType)
    (lib.types.attrsOf jsonType)
  ]);
  profile = import ../../modules/home/programs/desktop/editors/zed/profile.nix {inherit lib;};
  package = {
    type = "derivation";
    name = "zed-test";
    outPath = "/nix/store/zed-test";
    meta.mainProgram = "zeditor";
  };
  evaluate = overrides:
    (lib.evalModules {
      specialArgs = {
        lib = lib // {aytordev = self.lib.module;};
        pkgs.zed-editor = package;
      };
      modules = [
        ../../modules/home/programs/desktop/editors/zed
        {
          options = {
            aytordev.theme = lib.mkOption {
              type = lib.types.attrs;
              default = context.themeConfig {};
            };
            programs.zed-editor = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              package = lib.mkOption {
                type = lib.types.nullOr lib.types.package;
                default = null;
              };
              extensions = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
              };
              userSettings = lib.mkOption {
                type = jsonType;
                default = {};
              };
              userKeymaps = lib.mkOption {
                type = jsonType;
                default = [];
              };
            };
            xdg.configFile = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
          };
          config.aytordev.programs.desktop.editors.zed.enable = lib.mkDefault true;
        }
        overrides
      ];
    }).config;
  enabled = evaluate {};
  settings = enabled.programs.zed-editor.userSettings;
  keymaps = enabled.programs.zed-editor.userKeymaps;
  normalContext = "Editor && vim_mode == normal && !VimWaiting && !menu";
  bindingsFor = contextName:
    (lib.findFirst (entry: entry.context == contextName) {bindings = {};} keymaps).bindings;
  normal = bindingsFor normalContext;
  sharedContext = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
  shared = bindingsFor sharedContext;
  empty = bindingsFor "(EmptyPane || SharedScreen) && !menu && !VimWaiting";
  fixtureProfile = {
    schema = 1;
    target_version = "1.21.0";
    settings = {
      nested = {
        keep = true;
        remove = false;
        list = [1 2];
      };
    };
    keymap = [
      {
        context = "First";
        bindings = {
          keep = "Keep";
          remove = "Remove";
          disable = "Disable";
          action = ["Old" {old = true;}];
        };
      }
      {
        context = "Second";
        bindings.a = "Second";
      }
    ];
  };
  fixture = selected: let
    profileText = builtins.toJSON selected;
    manifestText = builtins.toJSON {
      schema = 1;
      target_version = "1.21.0";
      source = {
        repository = "jellydn/zed-101-setup";
        revision = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      };
      artifacts."profile.json" = builtins.hashString "sha256" profileText;
    };
    manifestHash = builtins.hashString "sha256" manifestText;
  in {
    inherit profileText manifestText;
    pointer = {
      schema = 1;
      generation = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-${manifestHash}";
      manifest_sha256 = manifestHash;
    };
  };
  validFixture = fixture fixtureProfile;
  validateKeymap = keymap: profile.validate (fixture (fixtureProfile // {inherit keymap;}));
  forced = value: builtins.tryEval (builtins.deepSeq value value);
  globalBlocks = [
    {
      bindings = {
        keep = "Global";
        override = "Old";
        remove = "Remove";
      };
    }
    {
      context = "Editor";
      bindings.override = "Scoped";
    }
    {
      context = null;
      bindings = {
        later = "Later";
        removeLater = "Remove";
      };
    }
  ];
  repeatedBlocks = [
    {
      context = "Editor";
      bindings = {
        keep = "First";
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
        later = "Last";
        removeLater = "Remove";
      };
    }
  ];
  actionParameters = ["text" 42 1.5 true false null [1 "nested" {value = null;}] {nested = [true null];}];
  orderedCompose = blocks:
    profile.compose {
      source = validateKeymap blocks;
      excludedBindings = [
        {
          context = (builtins.head blocks).context or null;
          chords = ["remove" "removeLater"];
        }
      ];
      ownedKeymaps = [
        {
          context = (builtins.head blocks).context or null;
          bindings = {
            override = ["Owned" false];
            disable = null;
          };
        }
        {
          context = "New";
          bindings.new = "New";
        }
      ];
    };
  composedFixture = profile.compose {
    source = fixtureProfile;
    excludedSettings = [["nested" "remove"] ["absent"]];
    ownedSettings.nested = {
      list = [3];
      extra = "owned";
    };
    excludedBindings = [
      {
        context = "First";
        chords = ["remove"];
      }
    ];
    ownedKeymaps = [
      {
        context = "First";
        bindings = {
          disable = null;
          action = ["New" {new = true;}];
        };
      }
      {
        context = "Third";
        bindings.a = "Third";
      }
      {
        context = "Second";
        bindings.b = "Added";
      }
    ];
  };
in {
  testZedProfileIntegrityAndSchema = {
    expr = {
      valid = profile.validate validFixture == fixtureProfile;
      profileHash = context.throws (profile.validate (validFixture // {profileText = validFixture.profileText + " ";}));
      manifestHash = context.throws (profile.validate (validFixture // {manifestText = validFixture.manifestText + " ";}));
      traversal = context.throws (profile.validate (validFixture // {pointer = validFixture.pointer // {generation = "../outside";};}));
      identity = context.throws (profile.validate (validFixture // {pointer = validFixture.pointer // {generation = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-${validFixture.pointer.manifest_sha256}";};}));
      schema = context.throws (profile.validate (fixture (fixtureProfile // {schema = 2;})));
      version = context.throws (profile.validate (fixture (fixtureProfile // {target_version = "9.0.0";})));
      shape = context.throws (profile.validate (fixture (fixtureProfile
        // {
          keymap = [
            {
              context = "X";
              bindings.a = ["MissingParameters"];
            }
          ];
        })));
    };
    expected = {
      valid = true;
      profileHash = true;
      manifestHash = true;
      traversal = true;
      identity = true;
      schema = true;
      version = true;
      shape = true;
    };
  };

  testZedProducerGlobalContextsValidate = {
    expr = forced (validateKeymap globalBlocks).keymap;
    expected = {
      success = true;
      value = globalBlocks;
    };
  };

  testZedProducerRepeatedDisjointContextsValidate = {
    expr = forced (validateKeymap repeatedBlocks).keymap;
    expected = {
      success = true;
      value = repeatedBlocks;
    };
  };

  testZedProducerJsonActionParametersValidate = {
    expr = forced (map (parameter:
      (validateKeymap [
        {
          context = "Editor";
          bindings.action = ["Action" parameter];
        }
      ]).keymap)
    actionParameters);
    expected = {
      success = true;
      value =
        map (parameter: [
          {
            context = "Editor";
            bindings.action = ["Action" parameter];
          }
        ])
        actionParameters;
    };
  };

  testZedGlobalCompositionPreservesOrderAndOverrides = {
    expr = forced (orderedCompose globalBlocks).keymaps;
    expected = {
      success = true;
      value = [
        {bindings.keep = "Global";}
        {
          context = "Editor";
          bindings.override = "Scoped";
        }
        {
          context = null;
          bindings = {
            later = "Later";
            override = ["Owned" false];
            disable = null;
          };
        }
        {
          context = "New";
          bindings.new = "New";
        }
      ];
    };
  };

  testZedRepeatedCompositionPreservesInterveningPrecedence = {
    expr = forced (orderedCompose repeatedBlocks).keymaps;
    expected = {
      success = true;
      value = [
        {
          context = "Editor";
          bindings.keep = "First";
        }
        {
          context = "Editor && menu";
          bindings.override = "Intervening";
        }
        {
          context = "Editor";
          bindings = {
            later = "Last";
            override = ["Owned" false];
            disable = null;
          };
        }
        {
          context = "New";
          bindings.new = "New";
        }
      ];
    };
  };

  testZedSourceOnlyPreservesRepeatedBlocks = {
    expr = (profile.compose {source = fixtureProfile // {keymap = repeatedBlocks;};}).keymaps;
    expected = repeatedBlocks;
  };

  testZedGlobalOwnedFormsPreserveSourceRepresentation = {
    expr =
      map (
        sourceBlock:
          (profile.compose {
            source = validateKeymap [sourceBlock];
            ownedKeymaps = [
              {bindings.action = ["Intermediate" [1 2]];}
              {
                context = null;
                bindings.action = null;
              }
            ];
          }).keymaps
      ) [
        {bindings.action = "Old";}
        {
          context = null;
          bindings.action = "Old";
        }
      ];
    expected = [
      [{bindings.action = null;}]
      [
        {
          context = null;
          bindings.action = null;
        }
      ]
    ];
  };

  testZedActiveOutputMatchesPreFixComposition = {
    expr = {inherit settings keymaps;};
    expected = let
      preferences = import ../../modules/home/programs/desktop/editors/zed/preferences.nix {inherit lib package;};
      owned = import ../../modules/home/programs/desktop/editors/zed/keymaps.nix;
      # Freeze the pre-F1 algorithm ONLY for the active unique-context snapshot.
      # Compare all emitted values, not a subset of representative settings.
      merge = blocks: next:
        if builtins.any (entry: entry.context == next.context) blocks
        then
          map (entry:
            if entry.context == next.context
            then entry // {bindings = entry.bindings // next.bindings;}
            else entry)
          blocks
        else blocks ++ [next];
    in
      assert owned.excludedBindings == []; {
        settings =
          lib.recursiveUpdate
          (lib.recursiveUpdate (builtins.removeAttrs profile.upstream.settings ["theme" "icon_theme"]) preferences.settings)
          preferences.safety
          // {theme = "Kanagawa Dragon";};
        keymaps = builtins.foldl' merge [] (profile.upstream.keymap ++ owned.blocks);
      };
  };

  testZedMalformedSelectedBlocksRejected = {
    expr = map (keymap: context.throws (validateKeymap keymap)) [
      [null]
      ["not a block"]
      [
        {
          context = 1;
          bindings.a = "Action";
        }
      ]
      [
        {
          context = false;
          bindings.a = "Action";
        }
      ]
      [
        {
          context = [];
          bindings.a = "Action";
        }
      ]
      [
        {
          context = {};
          bindings.a = "Action";
        }
      ]
      [{context = "Editor";}]
      [{bindings = [];}]
      [
        {
          bindings.a = "Action";
          extra = true;
        }
      ]
      [{bindings.a = ["Action"];}]
      [{bindings.a = ["Action" {} null];}]
      [{bindings.a = [1 {}];}]
      [{bindings.a = true;}]
      [{bindings.a = 1;}]
      [{bindings.a = {};}]
      [{bindings."" = "Action";}]
      [
        {bindings.a = "First";}
        {
          context = null;
          bindings.a = "Duplicate";
        }
      ]
      [
        {
          context = "Editor";
          bindings.a = "First";
        }
        {
          context = "Editor";
          bindings.a = "Duplicate";
        }
      ]
    ];
    expected = lib.replicate 18 true;
  };

  testZedCompositionReplacesListsAndDeletesSourcePaths = {
    expr = composedFixture.settings;
    expected.nested = {
      keep = true;
      list = [3];
      extra = "owned";
    };
  };

  testZedKeymapCompositionIsOrderedAndAtomic = {
    expr = composedFixture.keymaps;
    expected = [
      {
        context = "First";
        bindings = {
          keep = "Keep";
          disable = null;
          action = ["New" {new = true;}];
        };
      }
      {
        context = "Second";
        bindings = {
          a = "Second";
          b = "Added";
        };
      }
      {
        context = "Third";
        bindings.a = "Third";
      }
    ];
  };

  testZedLeafDefaultsPreservePriorityWrappers = {
    expr = profile.defaultLeaves {
      scalar = 1;
      list = [1 2];
      nested.value = false;
      explicit = lib.mkForce 3;
    };
    expected = {
      scalar = lib.mkDefault 1;
      list = lib.mkDefault [1 2];
      nested.value = lib.mkDefault false;
      explicit = lib.mkForce 3;
    };
  };

  testZedConsumesEverySelectedBinding = {
    expr =
      builtins.all (
        entry:
          builtins.all (chord: (bindingsFor entry.context).${chord} == entry.bindings.${chord}) (builtins.attrNames entry.bindings)
      )
      profile.upstream.keymap;
    expected = true;
  };

  testZedAuditedUnsupportedKeysAreAbsent = {
    expr = {
      sneak = settings.vim.enable_vim_sneak or null;
      follow = settings.agent.agent_follow or null;
      notification = settings.notification_panel or null;
      chat = settings.chat_panel or null;
      folderIcons = settings.project_panel.folder_icons or null;
    };
    expected = {
      sneak = null;
      follow = null;
      notification = null;
      chat = null;
      folderIcons = null;
    };
  };

  testZedErgonomicsUseModernSettings = {
    expr = {
      relative = settings.relative_line_numbers;
      whichKey = settings.which_key or null;
      brackets = settings.colorize_brackets or null;
      codeLens = settings.code_lens or null;
      signatureHelp = settings.auto_signature_help or null;
      signatureAfterEdits = settings.show_signature_help_after_edits or null;
      privateValues = settings.redact_private_values or null;
      cli = settings.cli_default_open_behavior or null;
      predictionProvider = settings.edit_predictions.provider or null;
      finderWidth = settings.file_finder.modal_max_width or null;
      legacyFeatures = settings ? features;
      legacyFinderWidth = settings.file_finder ? modal_width;
    };
    expected = {
      relative = "enabled";
      whichKey = {
        enabled = true;
        delay_ms = 500;
      };
      brackets = true;
      codeLens = "menu";
      signatureHelp = false;
      signatureAfterEdits = false;
      privateValues = true;
      cli = "existing_window";
      predictionProvider = "zed";
      finderWidth = "medium";
      legacyFeatures = false;
      legacyFinderWidth = false;
    };
  };

  testZedAgentRequiresConfirmationWithoutProviderDefaults = {
    expr = {
      legacy = settings ? assistant;
      agent = settings.agent or null;
    };
    expected = {
      legacy = false;
      agent = {
        dock = "right";
        sidebar_side = "right";
        default_profile = "ask";
        notify_when_agent_waiting = "primary_screen";
        play_sound_when_agent_done = "never";
        single_file_review = true;
        tool_permissions.default = "confirm";
      };
    };
  };

  testZedTerminalEditorUsesSelectedPackage = {
    expr =
      (evaluate {
        aytordev.programs.desktop.editors.zed.package =
          package
          // {
            outPath = "/nix/store/zed-override";
            meta.mainProgram = "custom-zed";
          };
      }).programs.zed-editor.userSettings.terminal.env.EDITOR;
    expected = "/nix/store/zed-override/bin/custom-zed --wait";
  };

  testZedCapabilityDisabledEmitsNothing = {
    expr = let
      disabled = evaluate {aytordev.programs.desktop.editors.zed.enable = false;};
    in {
      program = disabled.programs.zed-editor;
      files = disabled.xdg.configFile;
    };
    expected = {
      program = {
        enable = false;
        package = null;
        extensions = [];
        userSettings = {};
        userKeymaps = [];
      };
      files = {};
    };
  };

  testZedPreservesOwnershipAndAppearance = {
    expr = {
      inherit (settings) telemetry buffer_font_family buffer_font_size ui_font_size;
      inherit (settings) theme;
      extensions = enabled.programs.zed-editor.extensions;
      packagePath = enabled.programs.zed-editor.package.outPath;
    };
    expected = {
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      buffer_font_family = "MonaspiceNe Nerd Font Mono";
      buffer_font_size = 18;
      ui_font_size = 16;
      theme = "Kanagawa Dragon";
      extensions = ["kanagawa-themes" "sora-theme"];
      packagePath = package.outPath;
    };
  };

  testZedGitAndNavigationDecorations = {
    expr = {
      toolbar = settings.toolbar.code_actions or null;
      vertical = settings.vertical_scroll_margin or null;
      horizontal = settings.horizontal_scroll_margin or null;
      whitespace = settings.show_whitespaces or null;
      blame = settings.git.inline_blame.enabled or null;
      panel = settings.git_panel;
      project = settings.project_panel;
      inherit (settings) tabs;
    };
    expected = {
      toolbar = true;
      vertical = 4;
      horizontal = 8;
      whitespace = "all";
      blame = true;
      panel = {
        dock = "right";
        collapse_untracked_diff = true;
        show_count_badge = true;
        diff_stats = true;
        file_icons = true;
        tree_view = true;
      };
      project = {
        button = true;
        dock = "right";
        git_status = true;
        file_icons = true;
        folder_indicator = "icon";
        show_diagnostics = "all";
      };
      tabs = {
        git_status = true;
        file_icons = true;
        show_diagnostics = "all";
      };
    };
  };

  testZedLanguageLocalIndentationAndFormatters = {
    expr = {
      globalTabs = settings.hard_tabs or null;
      python = settings.languages.Python;
      go = settings.languages.Go or null;
      rust = settings.languages.Rust or null;
      json = settings.languages.JSON or null;
      markdown = settings.languages.Markdown or null;
    };
    expected = {
      globalTabs = null;
      python = {
        language_servers = ["ty" "ruff" "!basedpyright" "!pyright" "!pyrefly" "!pylsp"];
        format_on_save = "on";
        formatter.language_server.name = "ruff";
        code_actions_on_format."source.organizeImports.ruff" = true;
      };
      go = {
        hard_tabs = true;
        formatter.language_server.name = "gopls";
        format_on_save = "on";
      };
      rust = {
        hard_tabs = false;
        formatter.language_server.name = "rust-analyzer";
        format_on_save = "on";
      };
      json.hard_tabs = false;
      markdown = {
        format_on_save = "off";
        preferred_line_length = 80;
      };
    };
  };

  testZedDoesNotImportProviderTrustOrTaskPolicy = {
    expr = {
      forbidden = builtins.filter (key: builtins.hasAttr key settings) [
        "assistant"
        "language_models"
        "agent_servers"
        "context_servers"
        "session"
        "profiles"
        "sandbox"
        "trust_all_worktrees"
      ];
      shell = settings.terminal.shell or "system";
      tailwind = settings.lsp."tailwindcss-language-server".settings.classAttributes;
      typescript = settings.languages.TypeScript.inlay_hints.enabled;
    };
    expected = {
      forbidden = [];
      shell = "system";
      tailwind = ["class" "className" "ngClass" "styles"];
      typescript = true;
    };
  };

  testZedNativeSearchAndBufferChords = {
    expr = map (key: normal.${key} or null) ["space f f" "space f g" "space s b" "[ b" "] b" "space c f"];
    expected = [
      "file_finder::Toggle"
      "pane::DeploySearch"
      "buffer_search::Deploy"
      "pane::ActivatePreviousItem"
      "pane::ActivateNextItem"
      "editor::Format"
    ];
  };

  testZedEmptyPaneUsesNativeSearch = {
    expr = map (key: empty.${key} or null) ["space f f" "space f g" "space f n" "space q q"];
    expected = ["file_finder::Toggle" "pane::DeploySearch" "workspace::NewFile" "workspace::CloseWindow"];
  };

  testZedDiagnosticSeverityNavigation = {
    expr = map (key: normal.${key} or null) ["] e" "[ e" "] w" "[ w" "] i" "[ i"];
    expected = [
      ["editor::GoToDiagnostic" {severity = "error";}]
      ["editor::GoToPreviousDiagnostic" {severity = "error";}]
      ["editor::GoToDiagnostic" {severity = "warning";}]
      ["editor::GoToPreviousDiagnostic" {severity = "warning";}]
      ["editor::GoToDiagnostic" {severity = "hint";}]
      ["editor::GoToPreviousDiagnostic" {severity = "hint";}]
    ];
  };

  testZedGitAndWindowActions = {
    expr = {
      git = map (key: shared.${key} or null) ["space g d" "space g b" "space g h e"];
      window = map (key: normal.${key} or null) [
        "space w v"
        "space w s"
        "space w h"
        "space w j"
        "space w k"
        "space w l"
        "space w >"
        "space w <"
        "space w +"
        "space w -"
      ];
      lines = map (key: shared.${key} or null) ["alt-j" "alt-k"];
    };
    expected = {
      git = ["git::Diff" "editor::ToggleGitBlameInline" "editor::ExpandAllDiffHunks"];
      window = [
        "pane::SplitRight"
        "pane::SplitDown"
        "workspace::ActivatePaneLeft"
        "workspace::ActivatePaneDown"
        "workspace::ActivatePaneUp"
        "workspace::ActivatePaneRight"
        "vim::ResizePaneRight"
        "vim::ResizePaneLeft"
        "vim::ResizePaneUp"
        "vim::ResizePaneDown"
      ];
      lines = ["editor::MoveLineDown" "editor::MoveLineUp"];
    };
  };

  testZedLeaderAndSneakAvoidAmbiguousPrefixes = {
    expr = {
      leaderDisabled = shared ? space && shared.space == null;
      symbols = map (key: normal.${key} or null) ["space s s" "space s S"];
      oldPrefixes = normal ? "s s" || normal ? "s S";
      sneak = map (key: shared.${key} or null) ["s" "S"];
      malformed = builtins.any (entry: entry.bindings ? "[b" || entry.bindings ? "]b") keymaps;
      uniqueContexts = builtins.length keymaps == builtins.length (lib.unique (map (entry: entry.context) keymaps));
      # Every Vim-sensitive entry, including task and change-operator mappings,
      # must allow menus and pending motions to own their input.
      guarded =
        builtins.all (
          entry:
            !(lib.hasInfix "vim_" entry.context)
            || (lib.hasInfix "!menu" entry.context && lib.hasInfix "!VimWaiting" entry.context)
        )
        keymaps;
    };
    expected = {
      leaderDisabled = true;
      symbols = ["outline::Toggle" "project_symbols::Toggle"];
      oldPrefixes = false;
      sneak = [["vim::PushSneak" {}] ["vim::PushSneakBackward" {}]];
      malformed = false;
      uniqueContexts = true;
      guarded = true;
    };
  };

  testZedAgentActionsStayInTheirDispatchContexts = {
    expr = {
      editor = map (key: shared.${key} or null) ["space a c" "space a a" "space a i"];
      panel = bindingsFor "AgentPanel && !menu && !VimWaiting";
      model = (bindingsFor "(AcpThread || InlineAssistant) && !menu && !VimWaiting")."cmd-alt-/" or null;
      diff = (bindingsFor "Editor && editor_agent_diff && vim_mode == normal && !VimWaiting && !menu")."space a d" or null;
      misplaced =
        builtins.any (
          entry:
            lib.hasPrefix "Editor" entry.context
            && builtins.any (action: builtins.elem action ["agent::NewThread" "agent::OpenSettings" "agent::ToggleModelSelector"]) (builtins.attrValues entry.bindings)
        )
        keymaps;
    };
    expected = {
      editor = ["agent::ToggleFocus" "agent::AddSelectionToThread" "assistant::InlineAssist"];
      panel = {
        "cmd-n" = "agent::NewThread";
        "cmd-alt-c" = "agent::OpenSettings";
      };
      model = "agent::ToggleModelSelector";
      diff = "agent::OpenAgentDiff";
      misplaced = false;
    };
  };
}
